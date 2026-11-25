public with sharing class P07_InformeService {
    private static final Integer MAX_LINEAS = 1000;
    @TestVisible private static Integer limitePrueba;
    private class ConsultaException extends Exception {
        String codigo;
    }
    @AuraEnabled
    public static String consultar(String peticionJson) {
        try {
            autorizar();
            if (String.isBlank(peticionJson) || peticionJson.length() > 100)
                throw fallo('VALIDACION', 'Indica dos lunes en formato AAAA-MM-DD.');
            Map<String,Object> filtros;
            try {
                filtros = (Map<String,Object>)JSON.deserializeUntyped(peticionJson);
            } catch (Exception e) {
                throw fallo('VALIDACION', 'La selección no tiene el formato esperado.');
            }
            if (filtros == null || filtros.keySet() != new Set<String>{'desde','hasta'})
                throw fallo('VALIDACION', 'La consulta admite únicamente desde y hasta.');
            Date desde = lunes(filtros.get('desde')), hasta = lunes(filtros.get('hasta'));
            if (desde > hasta) throw fallo('VALIDACION', 'El lunes inicial no puede ser posterior al final.');
            Integer maximo = Test.isRunningTest() && limitePrueba != null && limitePrueba > 0
                ? Math.min(MAX_LINEAS, limitePrueba) : MAX_LINEAS;
            Integer tope = maximo + 1;
            Boolean propia = FeatureManagement.checkPermission('P07_GuardarPropia');
            String consulta = 'SELECT Id,Semana__c,Semana__r.Inicio__c,Semana__r.Usuario__c,Semana__r.Usuario__r.Name,'
                + 'Proyecto__c,Fecha__c,Minutos__c FROM DedicacionDiaria__c '
                + 'WHERE Semana__r.Inicio__c >= :desde AND Semana__r.Inicio__c <= :hasta';
            if (propia) consulta += ' AND Semana__r.Usuario__c = :actor AND Semana__r.OwnerId = :actor';
            consulta += ' ORDER BY Semana__r.Inicio__c,Semana__r.Usuario__c,Proyecto__c,Fecha__c,Id LIMIT :tope';
            List<DedicacionDiaria__c> lineas = Database.queryWithBinds(consulta,
                new Map<String,Object>{'desde'=>desde,'hasta'=>hasta,'actor'=>UserInfo.getUserId(),'tope'=>tope},
                AccessLevel.USER_MODE);
            if (lineas.size() > maximo)
                throw fallo('LIMITE_VOLUMEN', 'La consulta supera 1.000 líneas. Acota el intervalo; no se han devuelto resultados parciales.');
            Set<Id> ids = new Set<Id>();
            for (DedicacionDiaria__c linea : lineas) ids.add(linea.Proyecto__c);
            Map<Id,ProyectoDedicacion__c> proyectos = new Map<Id,ProyectoDedicacion__c>();
            if (!ids.isEmpty()) {
                proyectos = new Map<Id,ProyectoDedicacion__c>((List<ProyectoDedicacion__c>)Database.queryWithBinds(
                    'SELECT Id,Name,Codigo__c,Activo__c FROM ProyectoDedicacion__c WHERE Id IN :ids',
                    new Map<String,Object>{'ids'=>ids}, AccessLevel.USER_MODE));
            }
            if (proyectos.size() != ids.size())
                throw fallo('ACCESO_DENEGADO', 'No tienes acceso a todas las relaciones necesarias para esta consulta.');
            List<Object> semanas = new List<Object>();
            Map<String,Map<String,Object>> porSemana = new Map<String,Map<String,Object>>();
            Map<String,Map<String,Object>> porMiembro = new Map<String,Map<String,Object>>();
            Map<String,Map<String,Object>> porProyecto = new Map<String,Map<String,Object>>();
            Integer total = 0;
            for (DedicacionDiaria__c linea : lineas) {
                String inicio = String.valueOf(linea.Semana__r.Inicio__c);
                String miembroId = String.valueOf(linea.Semana__r.Usuario__c);
                String miembroKey = inicio + '|' + miembroId, proyectoKey = miembroKey + '|' + linea.Proyecto__c;
                if (!porSemana.containsKey(inicio)) {
                    Map<String,Object> semana = new Map<String,Object>{'inicio'=>inicio,'totalMinutos'=>0,'miembros'=>new List<Object>()};
                    porSemana.put(inicio, semana); semanas.add(semana);
                }
                if (!porMiembro.containsKey(miembroKey)) {
                    Map<String,Object> miembro = new Map<String,Object>{'id'=>miembroId,'nombre'=>linea.Semana__r.Usuario__r.Name,'totalMinutos'=>0,'proyectos'=>new List<Object>()};
                    porMiembro.put(miembroKey, miembro);
                    ((List<Object>)porSemana.get(inicio).get('miembros')).add(miembro);
                }
                if (!porProyecto.containsKey(proyectoKey)) {
                    ProyectoDedicacion__c p = proyectos.get(linea.Proyecto__c);
                    Map<String,Object> proyecto = new Map<String,Object>{'id'=>String.valueOf(p.Id),'nombre'=>p.Name,'codigo'=>p.Codigo__c,'activo'=>p.Activo__c,'totalMinutos'=>0,'detalle'=>new List<Object>()};
                    porProyecto.put(proyectoKey, proyecto);
                    ((List<Object>)porMiembro.get(miembroKey).get('proyectos')).add(proyecto);
                }
                Integer minutos = linea.Minutos__c.intValue();
                ((List<Object>)porProyecto.get(proyectoKey).get('detalle')).add(
                    new Map<String,Object>{'id'=>String.valueOf(linea.Id),'fecha'=>String.valueOf(linea.Fecha__c),'minutos'=>minutos});
                sumar(porProyecto.get(proyectoKey), minutos);
                sumar(porMiembro.get(miembroKey), minutos);
                sumar(porSemana.get(inicio), minutos);
                total += minutos;
            }
            return JSON.serialize(new Map<String,Object>{'ok'=>true,'resultado'=>new Map<String,Object>{
                'desde'=>String.valueOf(desde),'hasta'=>String.valueOf(hasta),'completo'=>true,'limiteLineas'=>MAX_LINEAS,
                'numeroLineas'=>lineas.size(),'totalMinutos'=>total,'semanas'=>semanas},'errores'=>new List<Object>()});
        } catch (ConsultaException e) {
            return error(e.codigo, e.getMessage());
        } catch (QueryException e) {
            return error('ACCESO_DENEGADO', 'No se pudo acceder a los datos y campos necesarios para esta consulta.');
        } catch (Exception e) {
            return error('FALLO_TECNICO', 'No se pudo completar la consulta. Vuelve a intentarlo.');
        }
    }
    private static void sumar(Map<String,Object> grupo, Integer minutos) {
        grupo.put('totalMinutos', (Integer)grupo.get('totalMinutos') + minutos);
    }
    private static Date lunes(Object valor) {
        if (!(valor instanceof String) || !Pattern.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$', (String)valor))
            throw fallo('VALIDACION', 'Selecciona lunes en formato AAAA-MM-DD.');
        Date fecha;
        try { fecha = Date.valueOf((String)valor); }
        catch (Exception e) { throw fallo('VALIDACION', 'La fecha no existe.'); }
        if (String.valueOf(fecha) != valor || Math.mod(Date.newInstance(2000,1,3).daysBetween(fecha), 7) != 0)
            throw fallo('VALIDACION', 'Ambos extremos deben ser lunes válidos.');
        return fecha;
    }
    private static void autorizar() {
        if (!FeatureManagement.checkPermission('P07_Consultar'))
            throw fallo('ACCESO_DENEGADO', 'No tienes permiso para consultar dedicación.');
        Map<Schema.SObjectType,Set<String>> requisitos = new Map<Schema.SObjectType,Set<String>>{
            ProyectoDedicacion__c.SObjectType => new Set<String>{'Id','Name','Codigo__c','Activo__c'},
            SemanaDedicacion__c.SObjectType => new Set<String>{'Id','Inicio__c','OwnerId','Usuario__c'},
            DedicacionDiaria__c.SObjectType => new Set<String>{'Id','Semana__c','Proyecto__c','Fecha__c','Minutos__c'},
            User.SObjectType => new Set<String>{'Id','Name'}
        };
        for (Schema.SObjectType tipo : requisitos.keySet()) {
            Schema.DescribeSObjectResult d = tipo.getDescribe();
            if (!d.isAccessible()) throw fallo('ACCESO_DENEGADO', 'No tienes acceso al esquema necesario para la consulta.');
            Map<String,Schema.SObjectField> campos = d.fields.getMap();
            for (String nombre : requisitos.get(tipo))
                if (!campos.get(nombre).getDescribe().isAccessible())
                    throw fallo('ACCESO_DENEGADO', 'Falta acceso de lectura a un campo necesario para la consulta.');
        }
    }
    private static ConsultaException fallo(String codigo, String mensaje) {
        ConsultaException e = new ConsultaException(mensaje); e.codigo = codigo; return e;
    }
    private static String error(String codigo, String mensaje) {
        return JSON.serialize(new Map<String,Object>{'ok'=>false,'resultado'=>null,'errores'=>new List<Object>{
            new Map<String,Object>{'codigo'=>codigo,'mensaje'=>mensaje}}});
    }
}
