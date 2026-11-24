public with sharing class P07_DedicacionService {
    private static final Integer MAX_CAMBIOS = 140;
    private static final Integer MAX_PROYECTOS_POR_PETICION = 20;
    private static final String CAMPOS_SEMANA = 'Id,Name,OwnerId,Usuario__c,Inicio__c,Clave__c,Revision__c,TotalMinutos__c';
    private static final String CAMPOS_LINEA = 'Id,Name,Semana__c,Proyecto__c,Fecha__c,Minutos__c,Clave__c';
    private static String paso;
    private static Id cabeceraPermitida;
    private static Decimal revisionPermitida;
    private static SemanaDedicacion__c cabeceraNueva;
    private static Map<String,DedicacionDiaria__c> filasPermitidas = new Map<String,DedicacionDiaria__c>();
    @TestVisible private static Integer falloDespuesDml;
    @TestVisible private static Integer escriturasObservadas = 0;
    @TestVisible private static Decimal totalAntesDelFallo;
    @TestVisible private static Decimal revisionAntesDelFallo;

    private class GuardadoException extends Exception {
        String codigo;
        Id proyecto;
        Date fecha;
    }
    private class Cambio {
        Id proyecto;
        Date fecha;
        Integer minutos;
    }
    private class Peticion {
        Date inicio;
        Decimal revision;
        List<Cambio> cambios = new List<Cambio>();
        Set<Id> proyectos = new Set<Id>();
    }

    @AuraEnabled
    public static String leerSemana(String inicioSemana) {
        try {
            autorizar(false);
            Date hoy = Date.today();
            Date inicio = fechaIso(inicioSemana);
            exigirLunes(inicio);
            SemanaDedicacion__c semana = bloquearSemana(inicio);
            return correcto(estado(inicio, hoy, semana));
        } catch (Exception e) {
            return respuestaError(e);
        }
    }

    @AuraEnabled
    public static String guardarSemana(String peticionJson) {
        Savepoint punto;
        try {
            if (paso != null) throw fallo('ACCESO_DENEGADO', 'No se admite un guardado anidado.', null, null);
            autorizar(true);
            Date hoy = Date.today();
            Peticion p = interpretar(peticionJson, hoy);
            escriturasObservadas = 0;
            totalAntesDelFallo = null;
            revisionAntesDelFallo = null;
            punto = Database.setSavepoint();
            SemanaDedicacion__c semana = bloquearSemana(p.inicio);
            Decimal vigente = semana == null ? 0 : semana.Revision__c;
            if (p.revision != vigente) throw fallo('REVISION_DESACTUALIZADA', 'La semana ha cambiado. Recarga antes de guardar.', null, null);
            List<DedicacionDiaria__c> anteriores = lineas(semana);
            Map<Id,ProyectoDedicacion__c> proyectos = bloquearProyectos(p.proyectos);
            for (Cambio cambio : p.cambios) {
                if (!proyectos.containsKey(cambio.proyecto)) throw fallo('ACCESO_DENEGADO', 'No se puede utilizar el proyecto indicado.', cambio.proyecto, cambio.fecha);
                if (!proyectos.get(cambio.proyecto).Activo__c) throw fallo('VALIDACION', 'El histórico de un proyecto inactivo no se puede modificar.', cambio.proyecto, cambio.fecha);
            }
            Map<String,DedicacionDiaria__c> porCelda = new Map<String,DedicacionDiaria__c>();
            Map<String,Integer> valores = new Map<String,Integer>();
            Map<String,Date> fechas = new Map<String,Date>();
            for (DedicacionDiaria__c fila : anteriores) {
                String celda = claveCelda(fila.Proyecto__c, fila.Fecha__c);
                if (fila.Clave__c != claveLinea(fila.Semana__c, fila.Proyecto__c, fila.Fecha__c)) throw fallo('FALLO_TECNICO', 'No se puede procesar esta semana.', null, null);
                porCelda.put(celda, fila);
                valores.put(celda, fila.Minutos__c.intValue());
                fechas.put(celda, fila.Fecha__c);
            }
            List<DedicacionDiaria__c> altas = new List<DedicacionDiaria__c>();
            List<DedicacionDiaria__c> cambios = new List<DedicacionDiaria__c>();
            List<DedicacionDiaria__c> bajas = new List<DedicacionDiaria__c>();
            for (Cambio cambio : p.cambios) {
                String celda = claveCelda(cambio.proyecto, cambio.fecha);
                DedicacionDiaria__c anterior = porCelda.get(celda);
                if (cambio.minutos == 0) {
                    valores.remove(celda);
                    if (anterior != null) bajas.add(anterior);
                } else {
                    valores.put(celda, cambio.minutos);
                    fechas.put(celda, cambio.fecha);
                    if (anterior == null) {
                        altas.add(new DedicacionDiaria__c(Proyecto__c=cambio.proyecto, Fecha__c=cambio.fecha, Minutos__c=cambio.minutos));
                    } else if (anterior.Minutos__c != cambio.minutos) {
                        DedicacionDiaria__c editada = anterior.clone(true, false, false, false);
                        editada.Minutos__c = cambio.minutos;
                        cambios.add(editada);
                    }
                }
            }
            Map<Date,Integer> diarios = new Map<Date,Integer>();
            for (String celda : valores.keySet()) {
                Date fecha = fechas.get(celda);
                Integer total = (diarios.containsKey(fecha) ? diarios.get(fecha) : 0) + valores.get(celda);
                diarios.put(fecha, total);
                if (total > 1440) throw fallo('VALIDACION', 'La suma del día supera 24 horas.', null, fecha);
            }
            if (altas.isEmpty() && cambios.isEmpty() && bajas.isEmpty()) return correcto(estado(p.inicio, hoy, semana));
            if (vigente >= 999999999999999999L) throw fallo('VALIDACION', 'La revisión ha alcanzado su límite.', null, null);
            revisionPermitida = vigente;
            if (semana == null) {
                semana = new SemanaDedicacion__c(OwnerId=UserInfo.getUserId(), Usuario__c=UserInfo.getUserId(), Inicio__c=p.inicio, Clave__c=claveSemana(p.inicio), Revision__c=0);
                cabeceraNueva = semana.clone(false, false, false, false);
                paso = 'CABECERA';
                Database.insert(new List<SemanaDedicacion__c>{semana}, true, AccessLevel.SYSTEM_MODE);
                cabeceraPermitida = semana.Id;
                despuesDml();
            } else {
                cabeceraPermitida = semana.Id;
            }
            for (DedicacionDiaria__c fila : altas) {
                fila.Semana__c = semana.Id;
                fila.Clave__c = claveLinea(semana.Id, fila.Proyecto__c, fila.Fecha__c);
            }
            aplicarLineas('BAJAS', bajas);
            aplicarLineas('CAMBIOS', cambios);
            aplicarLineas('ALTAS', altas);
            paso = 'REVISION';
            Database.update(new List<SemanaDedicacion__c>{new SemanaDedicacion__c(Id=semana.Id, Revision__c=vigente+1)}, true, AccessLevel.SYSTEM_MODE);
            despuesDml();
            return correcto(estado(p.inicio, hoy, releerSemana(semana.Id)));
        } catch (Exception e) {
            if (punto != null) Database.rollback(punto);
            return respuestaError(e);
        } finally {
            paso = null;
            cabeceraPermitida = null;
            cabeceraNueva = null;
            revisionPermitida = null;
            filasPermitidas.clear();
            if (punto != null) Database.releaseSavepoint(punto);
        }
    }

    private static void autorizar(Boolean escritura) {
        if (!FeatureManagement.checkPermission('P07_Consultar') || (escritura && !FeatureManagement.checkPermission('P07_GuardarPropia'))) {
            throw fallo('ACCESO_DENEGADO', 'No tienes permiso para esta operación.', null, null);
        }
        Map<Schema.SObjectType,Set<String>> requisitos = new Map<Schema.SObjectType,Set<String>>{
            ProyectoDedicacion__c.SObjectType => new Set<String>{'Id','Name','Codigo__c','Activo__c'},
            SemanaDedicacion__c.SObjectType => new Set<String>{'Id','Name','OwnerId','Usuario__c','Inicio__c','Clave__c','Revision__c','TotalMinutos__c'},
            DedicacionDiaria__c.SObjectType => new Set<String>{'Id','Name','Semana__c','Proyecto__c','Fecha__c','Minutos__c','Clave__c'}
        };
        for (Schema.SObjectType tipo : requisitos.keySet()) {
            Schema.DescribeSObjectResult descripcion = tipo.getDescribe();
            if (!descripcion.isAccessible()) throw fallo('ACCESO_DENEGADO', 'No tienes acceso al esquema de dedicación.', null, null);
            Map<String,Schema.SObjectField> campos = descripcion.fields.getMap();
            for (String nombre : requisitos.get(tipo)) {
                if (!campos.get(nombre).getDescribe().isAccessible()) throw fallo('ACCESO_DENEGADO', 'Falta acceso de lectura a los campos de dedicación.', null, null);
            }
        }
    }

    private static Peticion interpretar(String json, Date hoy) {
        if (String.isBlank(json) || json.length() > 60000) throw fallo('VALIDACION', 'La petición está vacía o supera el tamaño permitido.', null, null);
        Object bruto;
        try { bruto = System.JSON.deserializeUntyped(json); }
        catch (Exception e) { throw fallo('VALIDACION', 'La petición no contiene JSON válido.', null, null); }
        if (!(bruto instanceof Map<String,Object>)) throw fallo('VALIDACION', 'Se esperaba un objeto de guardado.', null, null);
        Map<String,Object> datos = (Map<String,Object>)bruto;
        exigirClaves(datos, new Set<String>{'semana','revisionEsperada','cambios'});
        Peticion p = new Peticion();
        p.inicio = fechaIso(datos.get('semana'));
        exigirLunes(p.inicio);
        Object revision = datos.get('revisionEsperada');
        if (!(revision instanceof String) || !Pattern.matches('^(0|[1-9][0-9]{0,17})$', (String)revision)) throw fallo('VALIDACION', 'La revisión esperada debe ser un entero no negativo expresado como texto.', null, null);
        p.revision = Decimal.valueOf((String)revision);
        if (!(datos.get('cambios') instanceof List<Object>)) throw fallo('VALIDACION', 'Los cambios deben ser una lista.', null, null);
        List<Object> lista = (List<Object>)datos.get('cambios');
        if (lista.size() > MAX_CAMBIOS) throw fallo('VALIDACION', 'La petición supera 140 celdas.', null, null);
        Set<String> vistas = new Set<String>();
        for (Object elemento : lista) {
            if (!(elemento instanceof Map<String,Object>)) throw fallo('VALIDACION', 'Una celda no tiene el formato esperado.', null, null);
            Map<String,Object> dato = (Map<String,Object>)elemento;
            exigirClaves(dato, new Set<String>{'proyectoId','fecha','horas'});
            Cambio cambio = new Cambio();
            try {
                if (!(dato.get('proyectoId') instanceof String)) throw new IllegalArgumentException();
                cambio.proyecto = (Id)(String)dato.get('proyectoId');
                if (cambio.proyecto == null || cambio.proyecto.getSObjectType() != ProyectoDedicacion__c.SObjectType) throw new IllegalArgumentException();
            } catch (Exception e) { throw fallo('VALIDACION', 'El identificador de proyecto no es válido.', null, null); }
            cambio.fecha = fechaIso(dato.get('fecha'));
            if (cambio.fecha < p.inicio || cambio.fecha > p.inicio.addDays(6)) throw fallo('VALIDACION', 'La fecha está fuera de la semana.', cambio.proyecto, cambio.fecha);
            if (cambio.fecha > hoy) throw fallo('VALIDACION', 'No se permite dedicación futura.', cambio.proyecto, cambio.fecha);
            cambio.minutos = minutos(dato.get('horas'), cambio.proyecto, cambio.fecha);
            String celda = claveCelda(cambio.proyecto, cambio.fecha);
            if (!vistas.add(celda)) throw fallo('VALIDACION', 'La petición repite una celda.', cambio.proyecto, cambio.fecha);
            p.proyectos.add(cambio.proyecto);
            p.cambios.add(cambio);
        }
        if (p.proyectos.size() > MAX_PROYECTOS_POR_PETICION) throw fallo('VALIDACION', 'Un guardado admite como máximo 20 proyectos modificados.', null, null);
        return p;
    }

    private static Integer minutos(Object horas, Id proyecto, Date fecha) {
        if (horas == null) return 0;
        if (!(horas instanceof String)) throw fallo('VALIDACION', 'Las horas deben enviarse como texto decimal con punto.', proyecto, fecha);
        String texto = (String)horas;
        if (String.isBlank(texto)) return 0;
        if (!Pattern.matches('^(0|[1-9][0-9]?)(\\.[0-9]{1,2})?$', texto)) throw fallo('VALIDACION', 'Formato de horas inválido: usa punto y hasta dos decimales.', proyecto, fecha);
        Decimal cantidad = Decimal.valueOf(texto) * 60;
        if (cantidad > 1440 || cantidad != cantidad.setScale(0) || Math.mod(cantidad.intValue(), 15) != 0) throw fallo('VALIDACION', 'Usa incrementos de 0.25 horas, hasta 24 horas por celda.', proyecto, fecha);
        return cantidad.intValue();
    }

    private static void exigirClaves(Map<String,Object> datos, Set<String> claves) {
        if (datos.keySet() != claves) throw fallo('VALIDACION', 'La petición contiene campos ausentes o no admitidos.', null, null);
    }
    private static Date fechaIso(Object valor) {
        if (!(valor instanceof String) || !Pattern.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$', (String)valor)) throw fallo('VALIDACION', 'La fecha debe tener formato AAAA-MM-DD.', null, null);
        try { return Date.valueOf((String)valor); }
        catch (Exception e) { throw fallo('VALIDACION', 'La fecha no es válida.', null, null); }
    }
    private static void exigirLunes(Date inicio) {
        if (Math.mod(Date.newInstance(2000,1,3).daysBetween(inicio), 7) != 0) throw fallo('VALIDACION', 'La semana debe comenzar en lunes.', null, inicio);
    }
    private static String claveSemana(Date inicio) { return String.valueOf(UserInfo.getUserId()) + '|' + String.valueOf(inicio); }
    private static String claveCelda(Id proyecto, Date fecha) { return String.valueOf(proyecto) + '|' + String.valueOf(fecha); }
    private static String claveLinea(Id semana, Id proyecto, Date fecha) { return String.valueOf(semana) + '|' + claveCelda(proyecto, fecha); }

    private static SemanaDedicacion__c bloquearSemana(Date inicio) {
        List<SemanaDedicacion__c> encontradas = Database.queryWithBinds(
            'SELECT Id FROM SemanaDedicacion__c WHERE Clave__c=:clave AND Usuario__c=:actor AND OwnerId=:actor LIMIT 1 FOR UPDATE',
            new Map<String,Object>{'clave'=>claveSemana(inicio),'actor'=>UserInfo.getUserId()}, AccessLevel.USER_MODE);
        return encontradas.isEmpty() ? null : releerSemana(encontradas[0].Id);
    }
    private static SemanaDedicacion__c releerSemana(Id identificador) {
        List<SemanaDedicacion__c> semanas = Database.queryWithBinds('SELECT '+CAMPOS_SEMANA+' FROM SemanaDedicacion__c WHERE Id=:identificador AND OwnerId=:actor AND Usuario__c=:actor',
            new Map<String,Object>{'identificador'=>identificador,'actor'=>UserInfo.getUserId()}, AccessLevel.USER_MODE);
        if (semanas.size()!=1) throw fallo('ACCESO_DENEGADO', 'No se puede acceder a la semana.', null, null);
        return semanas[0];
    }
    private static List<DedicacionDiaria__c> lineas(SemanaDedicacion__c semana) {
        if (semana == null) return new List<DedicacionDiaria__c>();
        List<DedicacionDiaria__c> filas = Database.queryWithBinds('SELECT '+CAMPOS_LINEA+' FROM DedicacionDiaria__c WHERE Semana__c=:semana ORDER BY Fecha__c,Proyecto__c LIMIT 701', new Map<String,Object>{'semana'=>semana.Id}, AccessLevel.USER_MODE);
        if (filas.size()>700) throw fallo('FALLO_TECNICO', 'La semana supera la capacidad de lectura.', null, null);
        return filas;
    }
    private static Map<Id,ProyectoDedicacion__c> bloquearProyectos(Set<Id> ids) {
        Map<Id,ProyectoDedicacion__c> resultado = new Map<Id,ProyectoDedicacion__c>();
        List<Id> orden = new List<Id>(ids);
        orden.sort();
        // Consultas de una fila en orden estable; FOR UPDATE no admite ORDER BY.
        for (Id identificador : orden) {
            List<ProyectoDedicacion__c> filas = Database.queryWithBinds('SELECT Id,Name,Codigo__c,Activo__c FROM ProyectoDedicacion__c WHERE Id=:identificador FOR UPDATE', new Map<String,Object>{'identificador'=>identificador}, AccessLevel.USER_MODE);
            if (!filas.isEmpty()) resultado.put(identificador, filas[0]);
        }
        return resultado;
    }

    private static Map<String,Object> estado(Date inicio, Date hoy, SemanaDedicacion__c semana) {
        List<DedicacionDiaria__c> filas = lineas(semana);
        Set<Id> historicos = new Set<Id>();
        for (DedicacionDiaria__c fila : filas) historicos.add(fila.Proyecto__c);
        List<ProyectoDedicacion__c> catalogo = Database.queryWithBinds('SELECT Id,Name,Codigo__c,Activo__c FROM ProyectoDedicacion__c WHERE Activo__c=true OR Id IN :historicos ORDER BY Name,Id LIMIT 1001', new Map<String,Object>{'historicos'=>historicos}, AccessLevel.USER_MODE);
        if (catalogo.size()>1000) throw fallo('FALLO_TECNICO', 'El catálogo supera la capacidad de lectura.', null, null);
        Map<Id,ProyectoDedicacion__c> porId = new Map<Id,ProyectoDedicacion__c>(catalogo);
        Boolean puedeGuardar = FeatureManagement.checkPermission('P07_GuardarPropia');
        List<Object> proyectos = new List<Object>();
        for (ProyectoDedicacion__c proyecto : catalogo) proyectos.add(new Map<String,Object>{'id'=>proyecto.Id,'nombre'=>proyecto.Name,'codigo'=>proyecto.Codigo__c,'activo'=>proyecto.Activo__c,'editable'=>puedeGuardar && proyecto.Activo__c});
        List<Integer> diarios = new List<Integer>{0,0,0,0,0,0,0};
        List<Object> entradas = new List<Object>();
        Integer total = 0;
        for (DedicacionDiaria__c fila : filas) {
            if (!porId.containsKey(fila.Proyecto__c)) throw fallo('ACCESO_DENEGADO', 'No se puede consultar el catálogo completo de esta semana.', null, null);
            Integer dia = inicio.daysBetween(fila.Fecha__c);
            if (dia<0 || dia>6) throw fallo('FALLO_TECNICO', 'No se puede procesar esta semana.', null, null);
            Integer cantidad = fila.Minutos__c.intValue();
            diarios[dia] += cantidad;
            total += cantidad;
            entradas.add(new Map<String,Object>{'proyectoId'=>fila.Proyecto__c,'fecha'=>String.valueOf(fila.Fecha__c),'minutos'=>cantidad,'editable'=>puedeGuardar && porId.get(fila.Proyecto__c).Activo__c && fila.Fecha__c<=hoy});
        }
        if (semana != null && (semana.TotalMinutos__c == null ? 0 : semana.TotalMinutos__c) != total) throw fallo('FALLO_TECNICO', 'No se puede confirmar el total semanal.', null, null);
        List<Object> dias = new List<Object>();
        for (Integer i=0;i<7;i++) dias.add(new Map<String,Object>{'fecha'=>String.valueOf(inicio.addDays(i)),'minutos'=>diarios[i],'editable'=>puedeGuardar && inicio.addDays(i)<=hoy});
        return new Map<String,Object>{'semana'=>String.valueOf(inicio),'hoy'=>String.valueOf(hoy),'revision'=>semana==null?'0':String.valueOf(semana.Revision__c.setScale(0)),'existe'=>semana!=null,'puedeGuardar'=>puedeGuardar,'proyectos'=>proyectos,'entradas'=>entradas,'dias'=>dias,'totalMinutos'=>total};
    }

    private static void aplicarLineas(String operacion, List<DedicacionDiaria__c> filas) {
        if (filas.isEmpty()) return;
        paso = operacion;
        filasPermitidas.clear();
        for (DedicacionDiaria__c fila : filas) filasPermitidas.put(fila.Clave__c, fila.clone(true,false,false,false));
        if (operacion=='BAJAS') Database.delete(filas, true, AccessLevel.SYSTEM_MODE);
        else if (operacion=='CAMBIOS') Database.update(filas, true, AccessLevel.SYSTEM_MODE);
        else Database.insert(filas, true, AccessLevel.SYSTEM_MODE);
        despuesDml();
        filasPermitidas.clear();
    }
    private static void despuesDml() {
        escriturasObservadas++;
        if (Test.isRunningTest() && falloDespuesDml != null && escriturasObservadas==falloDespuesDml) {
            List<SemanaDedicacion__c> observada = Database.queryWithBinds('SELECT Revision__c,TotalMinutos__c FROM SemanaDedicacion__c WHERE Id=:cabecera', new Map<String,Object>{'cabecera'=>cabeceraPermitida}, AccessLevel.SYSTEM_MODE);
            if (!observada.isEmpty()) { totalAntesDelFallo=observada[0].TotalMinutos__c; revisionAntesDelFallo=observada[0].Revision__c; }
            throw fallo('FALLO_TECNICO', 'No se pudo guardar. No se ha aplicado ningún cambio.', null, null);
        }
    }

    // Los triggers pueden consultar el contexto privado; ninguna superficie puede habilitarlo.
    public static void protegerSemana() {
        if (!Trigger.isExecuting) return;
        List<SemanaDedicacion__c> filas = (List<SemanaDedicacion__c>)(Trigger.isDelete ? Trigger.old : Trigger.new);
        for (SemanaDedicacion__c fila : filas) {
            Boolean permitido = false;
            if (Trigger.isBefore && Trigger.isInsert && paso=='CABECERA' && cabeceraNueva!=null && filas.size()==1) {
                permitido = fila.OwnerId==UserInfo.getUserId() && fila.Usuario__c==UserInfo.getUserId() && fila.Inicio__c==cabeceraNueva.Inicio__c && fila.Clave__c==claveSemana(fila.Inicio__c) && fila.Revision__c==0;
            } else if (Trigger.isBefore && Trigger.isUpdate && fila.Id==cabeceraPermitida) {
                SemanaDedicacion__c antes = (SemanaDedicacion__c)Trigger.oldMap.get(fila.Id);
                Boolean identidad = fila.OwnerId==antes.OwnerId && fila.Usuario__c==antes.Usuario__c && fila.Inicio__c==antes.Inicio__c && fila.Clave__c==antes.Clave__c && fila.Name==antes.Name;
                if (paso=='REVISION') permitido = identidad && antes.Revision__c==revisionPermitida && fila.Revision__c==revisionPermitida+1 && fila.TotalMinutos__c==antes.TotalMinutos__c;
                else if (paso=='ALTAS' || paso=='CAMBIOS' || paso=='BAJAS') permitido = identidad && fila.Revision__c==antes.Revision__c;
            }
            if (!permitido) fila.addError('P07: la cabecera solo puede modificarse mediante el guardado semanal autorizado.');
        }
    }
    public static void protegerDedicacion() {
        if (!Trigger.isExecuting) return;
        List<DedicacionDiaria__c> filas = (List<DedicacionDiaria__c>)(Trigger.isDelete ? Trigger.old : Trigger.new);
        for (DedicacionDiaria__c fila : filas) {
            DedicacionDiaria__c prevista = filasPermitidas.get(fila.Clave__c);
            Boolean permitido = Trigger.isBefore && prevista!=null && fila.Semana__c==cabeceraPermitida && fila.Proyecto__c==prevista.Proyecto__c && fila.Fecha__c==prevista.Fecha__c && fila.Clave__c==claveLinea(fila.Semana__c,fila.Proyecto__c,fila.Fecha__c);
            if (permitido && Trigger.isInsert) permitido = paso=='ALTAS' && fila.Minutos__c==prevista.Minutos__c;
            else if (permitido && Trigger.isUpdate) {
                DedicacionDiaria__c antes = (DedicacionDiaria__c)Trigger.oldMap.get(fila.Id);
                permitido = paso=='CAMBIOS' && fila.Id==prevista.Id && fila.Minutos__c==prevista.Minutos__c && fila.Semana__c==antes.Semana__c && fila.Proyecto__c==antes.Proyecto__c && fila.Fecha__c==antes.Fecha__c && fila.Clave__c==antes.Clave__c && fila.Name==antes.Name;
            } else if (permitido && Trigger.isDelete) permitido = paso=='BAJAS' && fila.Id==prevista.Id;
            else permitido = false;
            if (!permitido) fila.addError('P07: la dedicación solo puede modificarse mediante el guardado semanal autorizado.');
        }
    }

    private static GuardadoException fallo(String codigo, String mensaje, Id proyecto, Date fecha) {
        GuardadoException f = new GuardadoException(mensaje);
        f.codigo=codigo; f.proyecto=proyecto; f.fecha=fecha;
        return f;
    }
    @TestVisible private static String codigoDml(String codigo) {
        if (codigo=='DUPLICATE_VALUE') return 'CONFLICTO_CREACION';
        if (codigo=='UNABLE_TO_LOCK_ROW') return 'CONTENCION';
        if (codigo=='INSUFFICIENT_ACCESS_OR_READONLY' || codigo=='INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') return 'ACCESO_DENEGADO';
        return 'FALLO_TECNICO';
    }
    private static String respuestaError(Exception e) {
        String codigo='FALLO_TECNICO';
        String mensaje='No se pudo completar la operación. Recarga antes de volver a intentarlo.';
        Id proyecto; Date fecha;
        if (e instanceof GuardadoException) {
            GuardadoException f=(GuardadoException)e; codigo=f.codigo; mensaje=f.getMessage(); proyecto=f.proyecto; fecha=f.fecha;
        } else if (e instanceof DmlException) {
            DmlException d=(DmlException)e;
            if (d.getNumDml()>0) codigo=codigoDml(d.getDmlStatusCode(0));
        } else if (e instanceof QueryException) {
            String interno=e.getMessage().toLowerCase();
            if (interno.contains('unable_to_lock_row') || interno.contains('unable to obtain exclusive access')) codigo='CONTENCION';
        }
        return System.JSON.serialize(new Map<String,Object>{'ok'=>false,'estado'=>null,'errores'=>new List<Object>{new Map<String,Object>{'codigo'=>codigo,'mensaje'=>mensaje,'proyectoId'=>proyecto,'fecha'=>fecha==null?null:String.valueOf(fecha)}}});
    }
    private static String correcto(Map<String,Object> resultado) {
        return System.JSON.serialize(new Map<String,Object>{'ok'=>true,'estado'=>resultado,'errores'=>new List<Object>()});
    }
}
