@IsTest(SeeAllData=false)
private class P07_DedicacionServiceTest {
    @TestSetup static void preparar() {
        Profile perfil=[SELECT Id FROM Profile WHERE UserLicense.Name='Salesforce Platform' LIMIT 1];
        List<User> usuarios=new List<User>();
        for (String rol : new List<String>{'a','b','coord','sincrud','sinfls','sinperm'}) {
            String unico=UserInfo.getOrganizationId()+'.'+String.valueOf(DateTime.now().getTime())+'.'+rol;
            usuarios.add(new User(Username='p07.'+unico+'@example.invalid', Email='p07@example.invalid', LastName='P07Test_'+rol,
                Alias=('p07'+rol).left(8), TimeZoneSidKey='Europe/Madrid', LocaleSidKey='es_ES', EmailEncodingKey='UTF-8', LanguageLocaleKey='es', ProfileId=perfil.Id));
        }
        Database.insert(usuarios,true,AccessLevel.SYSTEM_MODE);
        Map<String,Id> permisos=new Map<String,Id>();
        for (PermissionSet p : [SELECT Id,Name FROM PermissionSet WHERE Name IN ('P07_MiembroLectura','P07_CoordinacionLectura','P07_GuardadoPropio','P07_ServicioLectura')]) permisos.put(p.Name,p.Id);
        PermissionSet sinFls=new PermissionSet(Name='P07_PruebaObjetos',Label='Prueba aislada objetos');
        Database.insert(sinFls,AccessLevel.SYSTEM_MODE);
        List<ObjectPermissions> objetos=new List<ObjectPermissions>();
        for (String nombre : new List<String>{'ProyectoDedicacion__c','SemanaDedicacion__c','DedicacionDiaria__c'}) objetos.add(new ObjectPermissions(ParentId=sinFls.Id,SobjectType=nombre,PermissionsRead=true));
        Database.insert(objetos,true,AccessLevel.SYSTEM_MODE);
        List<PermissionSetAssignment> asignaciones=new List<PermissionSetAssignment>();
        for (User u : usuarios) {
            List<Id> ids=new List<Id>();
            if (u.LastName=='P07Test_a' || u.LastName=='P07Test_b') ids.addAll(new List<Id>{permisos.get('P07_MiembroLectura'),permisos.get('P07_GuardadoPropio')});
            else if (u.LastName=='P07Test_coord') ids.addAll(new List<Id>{permisos.get('P07_CoordinacionLectura'),permisos.get('P07_ServicioLectura')});
            else if (u.LastName=='P07Test_sincrud') ids.add(permisos.get('P07_ServicioLectura'));
            else if (u.LastName=='P07Test_sinfls') ids.addAll(new List<Id>{sinFls.Id,permisos.get('P07_ServicioLectura')});
            else ids.add(permisos.get('P07_MiembroLectura'));
            for (Id permiso : ids) asignaciones.add(new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=permiso));
        }
        Database.insert(asignaciones,true,AccessLevel.SYSTEM_MODE);
        System.runAs(usuarios[0]) {
            List<ProyectoDedicacion__c> proyectos=new List<ProyectoDedicacion__c>();
            for (Integer i=1;i<=4;i++) proyectos.add(new ProyectoDedicacion__c(Name='Proyecto '+i,Codigo__c='T'+i,Activo__c=i!=4,OwnerId=usuarios[0].Id));
            proyectos.add(new ProyectoDedicacion__c(Name='Privado B',Codigo__c='B',Activo__c=true,OwnerId=usuarios[1].Id));
            Database.insert(proyectos,true,AccessLevel.SYSTEM_MODE);
        }
    }
    private static User actor(String rol) { return [SELECT Id FROM User WHERE LastName=:('P07Test_'+rol) LIMIT 1]; }
    private static Id proyecto(Integer n) { return [SELECT Id FROM ProyectoDedicacion__c WHERE Codigo__c=:('T'+n) LIMIT 1].Id; }
    private static Date lunes() {
        Date d=Date.today().addDays(-14);
        while (Math.mod(Date.newInstance(2000,1,3).daysBetween(d),7)!=0) d=d.addDays(-1);
        return d;
    }
    private static Map<String,Object> celda(Id p,Date d,Object horas) { return new Map<String,Object>{'proyectoId'=>p,'fecha'=>String.valueOf(d),'horas'=>horas}; }
    private static Map<String,Object> respuesta(String json) { return (Map<String,Object>)System.JSON.deserializeUntyped(json); }
    private static Map<String,Object> guardar(Date d,String revision,List<Object> cambios) {
        return respuesta(P07_DedicacionService.guardarSemana(System.JSON.serialize(new Map<String,Object>{'semana'=>String.valueOf(d),'revisionEsperada'=>revision,'cambios'=>cambios})));
    }
    private static Map<String,Object> bien(Map<String,Object> r) { Assert.areEqual(true,r.get('ok'),System.JSON.serialize(r)); return (Map<String,Object>)r.get('estado'); }
    private static void error(String codigo,Map<String,Object> r) {
        Assert.areEqual(false,r.get('ok'),System.JSON.serialize(r)); Assert.isNull(r.get('estado'));
        List<Object> errores=(List<Object>)r.get('errores'); Assert.areEqual(1,errores.size());
        Assert.areEqual(codigo,((Map<String,Object>)errores[0]).get('codigo'),System.JSON.serialize(r));
        Assert.isFalse(System.JSON.serialize(r).contains('stackTrace'));
    }
    private static SemanaDedicacion__c semana() { return [SELECT Id,OwnerId,Usuario__c,Inicio__c,Clave__c,Revision__c,TotalMinutos__c FROM SemanaDedicacion__c LIMIT 1]; }
    @IsTest static void lecturaSinCreacion() {
        System.runAs(actor('a')) {
            Map<String,Object> e=bien(respuesta(P07_DedicacionService.leerSemana(String.valueOf(lunes()))));
            Assert.areEqual(false,e.get('existe')); Assert.areEqual('0',e.get('revision')); Assert.areEqual(String.valueOf(Date.today()),e.get('hoy'));
            Assert.areEqual(3,((List<Object>)e.get('proyectos')).size()); Assert.areEqual(7,((List<Object>)e.get('dias')).size());
            Assert.areEqual(0,((List<Object>)e.get('entradas')).size()); Assert.areEqual(0,[SELECT count() FROM SemanaDedicacion__c]);
            bien(guardar(lunes(),'0',new List<Object>{celda(proyecto(1),lunes(),'0')}));
            Assert.areEqual(0,[SELECT count() FROM SemanaDedicacion__c]);
        }
    }
    @IsTest static void cicloCanonicoYNoop() {
        System.runAs(actor('a')) {
            Assert.isTrue(SemanaDedicacion__c.SObjectType.getDescribe().isAccessible());
            Assert.isFalse(SemanaDedicacion__c.SObjectType.getDescribe().isCreateable());
            Assert.isFalse(DedicacionDiaria__c.SObjectType.getDescribe().isUpdateable());
            Assert.isFalse(DedicacionDiaria__c.SObjectType.getDescribe().isDeletable());
            Id p=proyecto(1); Date d=lunes();
            Map<String,Object> e=bien(guardar(d,'0',new List<Object>{celda(p,d,'1.25'),celda(proyecto(2),d,'0.5')}));
            Assert.areEqual('1',e.get('revision')); Assert.areEqual(105,e.get('totalMinutos'));
            SemanaDedicacion__c s=semana(); Assert.areEqual(UserInfo.getUserId(),s.Usuario__c); Assert.areEqual(UserInfo.getUserId(),s.OwnerId);
            Assert.areEqual(String.valueOf(UserInfo.getUserId())+'|'+String.valueOf(d),s.Clave__c);
            DedicacionDiaria__c f=[SELECT Clave__c,Minutos__c FROM DedicacionDiaria__c WHERE Proyecto__c=:p];
            Assert.areEqual(String.valueOf(s.Id)+'|'+String.valueOf(p)+'|'+String.valueOf(d),f.Clave__c); Assert.areEqual(75,f.Minutos__c);
            e=bien(guardar(d,'1',new List<Object>{celda(p,d,'1.25')})); Assert.areEqual('1',e.get('revision'));
            e=bien(guardar(d,'1',new List<Object>{celda(p,d,'2')})); Assert.areEqual('2',e.get('revision')); Assert.areEqual(150,e.get('totalMinutos'));
            e=bien(respuesta(P07_DedicacionService.leerSemana(String.valueOf(d)))); Assert.areEqual('2',e.get('revision')); Assert.areEqual(150,e.get('totalMinutos'));
            e=bien(guardar(d,'2',new List<Object>{celda(p,d,''),celda(proyecto(2),d,null)}));
            Assert.areEqual('3',e.get('revision')); Assert.areEqual(0,e.get('totalMinutos')); Assert.areEqual(1,[SELECT count() FROM SemanaDedicacion__c]); Assert.areEqual(0,[SELECT count() FROM DedicacionDiaria__c]);
            e=bien(guardar(d,'3',new List<Object>())); Assert.areEqual('3',e.get('revision'));
        }
    }
    @IsTest static void rechazoPrecisionAntesDml() {
        System.runAs(actor('a')) {
            Id p=proyecto(1); Date d=lunes();
            for (Object valor : new List<Object>{'0.001','0.10','1e1','-0.25','24.25','0,25','01','1.000',1.25,true}) error('VALIDACION',guardar(d,'0',new List<Object>{celda(p,d,valor)}));
            Assert.areEqual(0,[SELECT count() FROM SemanaDedicacion__c]);
        }
    }
    @IsTest static void limiteAgregadoYOmitidas() {
        System.runAs(actor('a')) {
            Id a=proyecto(1),b=proyecto(2); Date d=lunes();
            bien(guardar(d,'0',new List<Object>{celda(a,d,'23.75'),celda(b,d,'0.25'),celda(a,d.addDays(1),'24')}));
            error('VALIDACION',guardar(d,'1',new List<Object>{celda(b,d,'0.5')}));
            Assert.areEqual(2880,semana().TotalMinutos__c); Assert.areEqual(1,semana().Revision__c);
            Map<String,Object> e=bien(guardar(d,'1',new List<Object>{celda(a,d,'23.5'),celda(b,d,'0.5')}));
            Assert.areEqual(2880,e.get('totalMinutos')); Assert.areEqual('2',e.get('revision'));
        }
    }
    @IsTest static void historicoInactivo() {
        Id p=proyecto(1); Date d=lunes();
        System.runAs(actor('a')) { bien(guardar(d,'0',new List<Object>{celda(p,d,'24')})); }
        Database.update(new ProyectoDedicacion__c(Id=p,Activo__c=false),AccessLevel.SYSTEM_MODE);
        System.runAs(actor('a')) {
            Map<String,Object> e=bien(respuesta(P07_DedicacionService.leerSemana(String.valueOf(d))));
            Assert.areEqual(3,((List<Object>)e.get('proyectos')).size());
            Assert.areEqual(false,((Map<String,Object>)((List<Object>)e.get('entradas'))[0]).get('editable'));
            for (String horas : new List<String>{'0','1','24'}) error('VALIDACION',guardar(d,'1',new List<Object>{celda(p,d,horas)}));
            error('VALIDACION',guardar(d,'1',new List<Object>{celda(proyecto(2),d,'0.25')}));
            error('VALIDACION',guardar(d,'1',new List<Object>{celda(proyecto(4),d,'1')}));
            Assert.areEqual(1440,semana().TotalMinutos__c);
        }
    }
    @IsTest static void fechasYDuplicados() {
        System.runAs(actor('a')) {
            Id p=proyecto(1); Date d=lunes();
            error('VALIDACION',guardar(d.addDays(1),'0',new List<Object>()));
            error('VALIDACION',guardar(d,'0',new List<Object>{celda(p,d.addDays(7),'1')}));
            Date futuro=d.addDays(35);
            error('VALIDACION',guardar(futuro,'0',new List<Object>{celda(p,futuro,'0')}));
            error('VALIDACION',guardar(d,'0',new List<Object>{celda(p,d,'1'),celda(p,d,'2')}));
            error('VALIDACION',respuesta(P07_DedicacionService.leerSemana('2026-02-30')));
            error('VALIDACION',respuesta(P07_DedicacionService.leerSemana('24/11/2026')));
            Date cruce=Date.newInstance(2025,12,29);
            bien(guardar(cruce,'0',new List<Object>{celda(p,cruce,'0.25'),celda(p,Date.newInstance(2026,1,4),'0.75')}));
            Assert.areEqual(60,semana().TotalMinutos__c);
        }
    }
    @IsTest static void contratoEstricto() {
        System.runAs(actor('a')) {
            Date d=lunes(); Id p=proyecto(1);
            for (String texto : new List<String>{null,'','{','[]','{}'}) error('VALIDACION',respuesta(P07_DedicacionService.guardarSemana(texto)));
            Map<String,Object> datos=new Map<String,Object>{'semana'=>String.valueOf(d),'revisionEsperada'=>'0','cambios'=>new List<Object>()};
            datos.put('usuarioId',UserInfo.getUserId()); error('VALIDACION',respuesta(P07_DedicacionService.guardarSemana(System.JSON.serialize(datos)))); datos.remove('usuarioId');
            datos.put('revisionEsperada',0); error('VALIDACION',respuesta(P07_DedicacionService.guardarSemana(System.JSON.serialize(datos))));
            for (String rev : new List<String>{'-1','01','1.0','1000000000000000000'}) error('VALIDACION',guardar(d,rev,new List<Object>()));
            error('VALIDACION',guardar(d,'0',new List<Object>{celda(UserInfo.getUserId(),d,'1')}));
            error('VALIDACION',guardar(d,'0',new List<Object>{'texto'}));
            Map<String,Object> extra=celda(p,d,'1'); extra.put('clave','manual'); error('VALIDACION',guardar(d,'0',new List<Object>{extra}));
            List<Object> muchas=new List<Object>(); for (Integer i=0;i<141;i++) muchas.add(celda(p,d,'1'));
            error('VALIDACION',guardar(d,'0',muchas)); Assert.areEqual(0,[SELECT count() FROM SemanaDedicacion__c]);
        }
    }
    @IsTest static void revisionYRepeticion() {
        System.runAs(actor('a')) {
            Id p=proyecto(1); Date d=lunes();
            error('REVISION_DESACTUALIZADA',guardar(d,'1',new List<Object>{celda(p,d,'1')}));
            bien(guardar(d,'0',new List<Object>{celda(p,d,'1')}));
            error('REVISION_DESACTUALIZADA',guardar(d,'0',new List<Object>{celda(p,d,'1')}));
            error('REVISION_DESACTUALIZADA',guardar(d,'0',new List<Object>()));
            Assert.areEqual(1,[SELECT count() FROM DedicacionDiaria__c]); Assert.areEqual(1,semana().Revision__c);
        }
    }
    @IsTest static void aislamientoPorIdentidad() {
        Date d=lunes(); Id p=proyecto(1); Id privado=[SELECT Id FROM ProyectoDedicacion__c WHERE Codigo__c='B'].Id;
        System.runAs(actor('a')) { error('ACCESO_DENEGADO',guardar(d,'0',new List<Object>{celda(privado,d,'1')})); bien(guardar(d,'0',new List<Object>{celda(p,d,'1')})); }
        System.runAs(actor('b')) {
            Map<String,Object> e=bien(respuesta(P07_DedicacionService.leerSemana(String.valueOf(d)))); Assert.areEqual(false,e.get('existe'));
            bien(guardar(d,'0',new List<Object>{celda(privado,d,'2')}));
        }
        Assert.areEqual(2,[SELECT count() FROM SemanaDedicacion__c]);
        Set<String> claves=new Set<String>(); for (SemanaDedicacion__c s : [SELECT Clave__c FROM SemanaDedicacion__c]) claves.add(s.Clave__c); Assert.areEqual(2,claves.size());
    }
    @IsTest static void seguridadCrudFlsPermiso() {
        System.runAs(actor('sincrud')) {
            Assert.isTrue(FeatureManagement.checkPermission('P07_Consultar')); Assert.isFalse(ProyectoDedicacion__c.SObjectType.getDescribe().isAccessible());
            error('ACCESO_DENEGADO',respuesta(P07_DedicacionService.leerSemana(String.valueOf(lunes()))));
        }
        System.runAs(actor('sinfls')) {
            Assert.isTrue(ProyectoDedicacion__c.SObjectType.getDescribe().isAccessible()); Assert.isFalse(ProyectoDedicacion__c.Activo__c.getDescribe().isAccessible());
            error('ACCESO_DENEGADO',respuesta(P07_DedicacionService.leerSemana(String.valueOf(lunes()))));
        }
        System.runAs(actor('sinperm')) {
            Assert.isTrue(ProyectoDedicacion__c.SObjectType.getDescribe().isAccessible()); Assert.isFalse(FeatureManagement.checkPermission('P07_Consultar'));
            error('ACCESO_DENEGADO',respuesta(P07_DedicacionService.leerSemana(String.valueOf(lunes()))));
        }
    }
    @IsTest static void coordinacionSoloLectura() {
        Date d=lunes();
        System.runAs(actor('a')) { bien(guardar(d,'0',new List<Object>{celda(proyecto(1),d,'1')})); }
        Id s=semana().Id; User coord=actor('coord');
        Database.insert(new SemanaDedicacion__Share(ParentId=s,UserOrGroupId=coord.Id,AccessLevel='Read',RowCause='Manual'),AccessLevel.SYSTEM_MODE);
        System.runAs(coord) {
            List<SObject> visibles=Database.queryWithBinds('SELECT Id FROM SemanaDedicacion__c WHERE Id=:id',new Map<String,Object>{'id'=>s},AccessLevel.USER_MODE); Assert.areEqual(1,visibles.size());
            Map<String,Object> e=bien(respuesta(P07_DedicacionService.leerSemana(String.valueOf(d)))); Assert.areEqual(false,e.get('existe')); Assert.areEqual(false,e.get('puedeGuardar'));
            error('ACCESO_DENEGADO',guardar(d,'0',new List<Object>()));
        }
    }
    @IsTest static void rollbackAltaTrasDml() {
        System.runAs(actor('a')) {
            P07_DedicacionService.falloDespuesDml=2;
            error('FALLO_TECNICO',guardar(lunes(),'0',new List<Object>{celda(proyecto(1),lunes(),'1')}));
            Assert.areEqual(2,P07_DedicacionService.escriturasObservadas); Assert.areEqual(60,P07_DedicacionService.totalAntesDelFallo);
            Assert.areEqual(0,[SELECT count() FROM SemanaDedicacion__c]); Assert.areEqual(0,[SELECT count() FROM DedicacionDiaria__c]);
            P07_DedicacionService.falloDespuesDml=null;
            bien(guardar(lunes(),'0',new List<Object>{celda(proyecto(1),lunes(),'1')}));
        }
    }
    @IsTest static void rollbackMixtoIncluyeRevision() {
        System.runAs(actor('a')) {
            Date d=lunes(); Id a=proyecto(1),b=proyecto(2),c=proyecto(3);
            bien(guardar(d,'0',new List<Object>{celda(a,d,'1'),celda(b,d,'0.5')}));
            List<Object> cambios=new List<Object>{celda(a,d,'2'),celda(b,d,'0'),celda(c,d,'0.25')};
            P07_DedicacionService.falloDespuesDml=4;
            error('FALLO_TECNICO',guardar(d,'1',cambios));
            Assert.areEqual(4,P07_DedicacionService.escriturasObservadas); Assert.areEqual(135,P07_DedicacionService.totalAntesDelFallo); Assert.areEqual(2,P07_DedicacionService.revisionAntesDelFallo);
            Assert.areEqual(90,semana().TotalMinutos__c); Assert.areEqual(1,semana().Revision__c);
            Map<Id,Decimal> antes=new Map<Id,Decimal>(); for (DedicacionDiaria__c f : [SELECT Proyecto__c,Minutos__c FROM DedicacionDiaria__c]) antes.put(f.Proyecto__c,f.Minutos__c);
            Assert.areEqual(2,antes.size()); Assert.areEqual(60,antes.get(a)); Assert.areEqual(30,antes.get(b)); Assert.isFalse(antes.containsKey(c));
            P07_DedicacionService.falloDespuesDml=null;
            Assert.areEqual('2',bien(guardar(d,'1',cambios)).get('revision'));
        }
    }
    @IsTest static void defensaCabeceraDirecta() {
        User a=actor('a'); Date d=lunes();
        System.runAs(a) {
            List<SemanaDedicacion__c> altas=new List<SemanaDedicacion__c>();
            for (Integer i=0;i<2;i++) altas.add(new SemanaDedicacion__c(OwnerId=a.Id,Usuario__c=a.Id,Inicio__c=d.addDays(7*i),Clave__c=String.valueOf(a.Id)+'|'+String.valueOf(d.addDays(7*i)),Revision__c=0));
            for (Database.SaveResult r : Database.insert(altas,false,AccessLevel.SYSTEM_MODE)) Assert.isFalse(r.isSuccess());
            bien(guardar(d,'0',new List<Object>{celda(proyecto(1),d,'1')}));
            SemanaDedicacion__c s=semana();
            List<SemanaDedicacion__c> intentos=new List<SemanaDedicacion__c>{new SemanaDedicacion__c(Id=s.Id,Revision__c=5),new SemanaDedicacion__c(Id=s.Id,OwnerId=actor('b').Id),new SemanaDedicacion__c(Id=s.Id,Usuario__c=actor('b').Id),new SemanaDedicacion__c(Id=s.Id,Inicio__c=d.addDays(7)),new SemanaDedicacion__c(Id=s.Id,Clave__c='manual')};
            for (SemanaDedicacion__c intento : intentos) Assert.isFalse(Database.update(intento,false,AccessLevel.SYSTEM_MODE).isSuccess());
            Assert.isFalse(Database.delete(s,false,AccessLevel.SYSTEM_MODE).isSuccess());
            Assert.areEqual(1,[SELECT count() FROM DedicacionDiaria__c]); Assert.areEqual(1,semana().Revision__c);
        }
    }
    @IsTest static void defensaDetalleDirectoYRestauracion() {
        System.runAs(actor('a')) {
            Date d=lunes(); Id p=proyecto(1);
            bien(guardar(d,'0',new List<Object>{celda(p,d,'1')}));
            DedicacionDiaria__c f=[SELECT Id,Semana__c,Proyecto__c,Fecha__c,Minutos__c,Clave__c FROM DedicacionDiaria__c LIMIT 1];
            DedicacionDiaria__c nueva=new DedicacionDiaria__c(Semana__c=f.Semana__c,Proyecto__c=p,Fecha__c=d.addDays(1),Minutos__c=15,Clave__c=String.valueOf(f.Semana__c)+'|'+String.valueOf(p)+'|'+String.valueOf(d.addDays(1)));
            Assert.isFalse(Database.insert(nueva,false,AccessLevel.SYSTEM_MODE).isSuccess());
            for (DedicacionDiaria__c intento : new List<DedicacionDiaria__c>{new DedicacionDiaria__c(Id=f.Id,Minutos__c=120),new DedicacionDiaria__c(Id=f.Id,Proyecto__c=proyecto(2)),new DedicacionDiaria__c(Id=f.Id,Fecha__c=d.addDays(1)),new DedicacionDiaria__c(Id=f.Id,Clave__c='manual')}) Assert.isFalse(Database.update(intento,false,AccessLevel.SYSTEM_MODE).isSuccess());
            Assert.isFalse(Database.delete(f,false,AccessLevel.SYSTEM_MODE).isSuccess());
            bien(guardar(d,'1',new List<Object>{celda(p,d,'0')}));
            Assert.isFalse(Database.undelete(f,false,AccessLevel.SYSTEM_MODE).isSuccess());
            Assert.areEqual(0,[SELECT count() FROM DedicacionDiaria__c]); Assert.areEqual(0,semana().TotalMinutos__c); Assert.areEqual(2,semana().Revision__c);
        }
    }
    @IsTest static void clasificacionDeColisionesSimulada() {
        Assert.areEqual('CONFLICTO_CREACION',P07_DedicacionService.codigoDml('DUPLICATE_VALUE'));
        Assert.areEqual('CONTENCION',P07_DedicacionService.codigoDml('UNABLE_TO_LOCK_ROW'));
        Assert.areEqual('ACCESO_DENEGADO',P07_DedicacionService.codigoDml('INSUFFICIENT_ACCESS_OR_READONLY'));
        Assert.areEqual('ACCESO_DENEGADO',P07_DedicacionService.codigoDml('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'));
        Assert.areEqual('FALLO_TECNICO',P07_DedicacionService.codigoDml('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }

    @IsTest static void reparentadoYAccesoAjeno() {
        Date d=lunes(); User a=actor('a'),b=actor('b'); Id primera;
        System.runAs(a) {
            Id proyectoId=proyecto(1);
            bien(guardar(d,'0',new List<Object>{celda(proyectoId,d,'1')})); primera=semana().Id;
            bien(guardar(d.addDays(-7),'0',new List<Object>{celda(proyectoId,d.addDays(-7),'1')}));
            Id segunda=[SELECT Id FROM SemanaDedicacion__c WHERE Id!=:primera LIMIT 1].Id;
            DedicacionDiaria__c fila=[SELECT Id,Semana__c FROM DedicacionDiaria__c WHERE Semana__c=:primera LIMIT 1];
            Assert.isFalse(Database.update(new DedicacionDiaria__c(Id=fila.Id,Semana__c=segunda),false,AccessLevel.SYSTEM_MODE).isSuccess());
            Assert.areEqual(primera,[SELECT Semana__c FROM DedicacionDiaria__c WHERE Id=:fila.Id].Semana__c);
            List<DedicacionDiaria__c> altas=new List<DedicacionDiaria__c>();
            for (Integer i=1;i<=2;i++) altas.add(new DedicacionDiaria__c(Semana__c=primera,Proyecto__c=proyectoId,Fecha__c=d.addDays(i),Minutos__c=15,Clave__c=String.valueOf(primera)+'|'+String.valueOf(proyectoId)+'|'+String.valueOf(d.addDays(i))));
            for (Database.SaveResult r : Database.insert(altas,false,AccessLevel.SYSTEM_MODE)) Assert.isFalse(r.isSuccess());
            Assert.areEqual(2,[SELECT count() FROM DedicacionDiaria__c]);
        }
        System.runAs(b) {
            Assert.areEqual(0,Database.queryWithBinds('SELECT Id FROM SemanaDedicacion__c WHERE Id=:id',new Map<String,Object>{'id'=>primera},AccessLevel.USER_MODE).size());
            Assert.areEqual(0,Database.queryWithBinds('SELECT Id FROM DedicacionDiaria__c WHERE Semana__c=:id',new Map<String,Object>{'id'=>primera},AccessLevel.USER_MODE).size());
        }
    }
    @IsTest static void limiteProyectosYLecturaFutura() {
        User a=actor('a');
        System.runAs(a) {
            List<ProyectoDedicacion__c> catalogo=new List<ProyectoDedicacion__c>();
            for (Integer i=0;i<21;i++) catalogo.add(new ProyectoDedicacion__c(Name='Limite '+i,Codigo__c='L'+i,Activo__c=true,OwnerId=a.Id));
            Database.insert(catalogo,true,AccessLevel.SYSTEM_MODE);
            List<Object> cambios=new List<Object>(); for (ProyectoDedicacion__c p : catalogo) cambios.add(celda(p.Id,lunes(),'0.25'));
            error('VALIDACION',guardar(lunes(),'0',cambios)); Assert.areEqual(0,[SELECT count() FROM SemanaDedicacion__c]);
            cambios.remove(20);
            Test.startTest();
            Map<String,Object> e=bien(guardar(lunes(),'0',cambios)); Assert.areEqual(300,e.get('totalMinutos'));
            Date futura=lunes().addDays(35);
            e=bien(respuesta(P07_DedicacionService.leerSemana(String.valueOf(futura))));
            for (Object dia : (List<Object>)e.get('dias')) Assert.areEqual(false,((Map<String,Object>)dia).get('editable'));
            Test.stopTest();
        }
    }
}
