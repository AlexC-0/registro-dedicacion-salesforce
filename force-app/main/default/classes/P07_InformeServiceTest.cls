@IsTest(SeeAllData=false)
private class P07_InformeServiceTest {
    @TestSetup static void preparar() {
        Profile perfil = [SELECT Id FROM Profile WHERE Name='P07_AccesoMinimo' LIMIT 1];
        List<User> usuarios = new List<User>();
        for (String rol : new List<String>{'a','b','coord','sincrud','sinfls','sinperm'}) {
            String unico = UserInfo.getOrganizationId()+'.'+DateTime.now().getTime()+'.'+rol;
            usuarios.add(new User(Username='p07inf.'+unico+'@example.invalid',Email='p07@example.invalid',
                LastName='P07Informe_'+rol,Alias=('inf'+rol).left(8),TimeZoneSidKey='Europe/Madrid',
                LocaleSidKey='es_ES',EmailEncodingKey='UTF-8',LanguageLocaleKey='es',ProfileId=perfil.Id,UserPermissionsSFContentUser=false));
        }
        insert usuarios;
        Map<String,Id> permisos = new Map<String,Id>();
        for (PermissionSet p : [SELECT Id,Name FROM PermissionSet WHERE Name IN
            ('P07_MiembroLectura','P07_CoordinacionLectura','P07_GuardadoPropio','P07_ServicioLectura','P07_ConsultaInforme')]) permisos.put(p.Name,p.Id);
        PermissionSet objetos = new PermissionSet(Name='P07_InformePruebaObjetos',Label='Objetos sin campos para prueba');
        insert objetos;
        List<ObjectPermissions> lecturas = new List<ObjectPermissions>();
        for (String nombre : new List<String>{'ProyectoDedicacion__c','SemanaDedicacion__c','DedicacionDiaria__c'})
            lecturas.add(new ObjectPermissions(ParentId=objetos.Id,SobjectType=nombre,PermissionsRead=true));
        insert lecturas;
        List<PermissionSetAssignment> asignaciones = new List<PermissionSetAssignment>();
        for (User u : usuarios) {
            List<Id> ids = new List<Id>();
            if (u.LastName=='P07Informe_a' || u.LastName=='P07Informe_b') ids.addAll(new List<Id>{permisos.get('P07_MiembroLectura'),permisos.get('P07_GuardadoPropio')});
            else if (u.LastName=='P07Informe_coord') ids.addAll(new List<Id>{permisos.get('P07_CoordinacionLectura'),permisos.get('P07_ServicioLectura')});
            else if (u.LastName=='P07Informe_sincrud') ids.add(permisos.get('P07_ServicioLectura'));
            else if (u.LastName=='P07Informe_sinfls') ids.addAll(new List<Id>{objetos.Id,permisos.get('P07_ServicioLectura')});
            else ids.add(permisos.get('P07_MiembroLectura'));
            if (u.LastName!='P07Informe_b') ids.add(permisos.get('P07_ConsultaInforme'));
            for (Id p : ids) asignaciones.add(new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=p));
        }
        insert asignaciones;
        System.runAs(usuarios[0]) {
            List<ProyectoDedicacion__c> proyectos = new List<ProyectoDedicacion__c>{
                new ProyectoDedicacion__c(Name='Revisión ficticia',Codigo__c='INF_R',Activo__c=true),
                new ProyectoDedicacion__c(Name='Histórico ficticio',Codigo__c='INF_H',Activo__c=true)
            };
            insert proyectos;
            List<ProyectoDedicacion__Share> shares = new List<ProyectoDedicacion__Share>();
            for (ProyectoDedicacion__c p : proyectos)
                for (Integer i : new List<Integer>{1,2}) shares.add(new ProyectoDedicacion__Share(ParentId=p.Id,UserOrGroupId=usuarios[i].Id,AccessLevel='Read',RowCause='Manual'));
            insert shares;
        }
    }
    private static User actor(String rol) { return [SELECT Id FROM User WHERE LastName=:('P07Informe_'+rol) LIMIT 1]; }
    private static Id proyecto(String codigo) { return [SELECT Id FROM ProyectoDedicacion__c WHERE Codigo__c=:codigo LIMIT 1].Id; }
    private static Date lunes() {
        Date d=Date.today().addDays(-21);
        while (Math.mod(Date.newInstance(2000,1,3).daysBetween(d),7)!=0) d=d.addDays(-1);
        return d;
    }
    private static Map<String,Object> celda(Id p,Date d,String horas) {
        return new Map<String,Object>{'proyectoId'=>p,'fecha'=>String.valueOf(d),'horas'=>horas};
    }
    private static void guardar(Date d,String revision,List<Object> cambios) {
        String r=P07_DedicacionService.guardarSemana(JSON.serialize(new Map<String,Object>{
            'semana'=>String.valueOf(d),'revisionEsperada'=>revision,'cambios'=>cambios}));
        Assert.areEqual(true,((Map<String,Object>)JSON.deserializeUntyped(r)).get('ok'),r);
    }
    private static void datos() {
        Date d=lunes();Id p=proyecto('INF_R'),h=proyecto('INF_H');User a=actor('a'),b=actor('b'),coord=actor('coord');
        System.runAs(a) {
            guardar(d,'0',new List<Object>{celda(p,d,'1'),celda(h,d,'0.5'),celda(h,d.addDays(1),'0.25')});
            guardar(d.addDays(-14),'0',new List<Object>{celda(p,d.addDays(-14),'0.75')});
            guardar(d.addDays(-7),'0',new List<Object>{celda(p,d.addDays(-7),'0.25')});
            guardar(d.addDays(-7),'1',new List<Object>{celda(p,d.addDays(-7),'0')});
        }
        System.runAs(b) { guardar(d,'0',new List<Object>{celda(p,d,'1')}); }
        update new ProyectoDedicacion__c(Id=h,Activo__c=false);
        List<SemanaDedicacion__Share> shares = new List<SemanaDedicacion__Share>();
        for (SemanaDedicacion__c s : [SELECT Id,OwnerId FROM SemanaDedicacion__c]) {
            if (s.OwnerId==a.Id) shares.add(new SemanaDedicacion__Share(ParentId=s.Id,UserOrGroupId=coord.Id,AccessLevel='Read',RowCause='Manual'));
            else shares.add(new SemanaDedicacion__Share(ParentId=s.Id,UserOrGroupId=a.Id,AccessLevel='Read',RowCause='Manual'));
        }
        insert shares;
    }
    private static Map<String,Object> respuesta(String texto) { return (Map<String,Object>)JSON.deserializeUntyped(texto); }
    private static Map<String,Object> consultar(Date desde,Date hasta) {
        return respuesta(P07_InformeService.consultar(JSON.serialize(new Map<String,Object>{'desde'=>String.valueOf(desde),'hasta'=>String.valueOf(hasta)})));
    }
    private static Map<String,Object> bien(Map<String,Object> r) {
        Assert.areEqual(true,r.get('ok'),JSON.serialize(r));Assert.areEqual(0,((List<Object>)r.get('errores')).size());
        return (Map<String,Object>)r.get('resultado');
    }
    private static void error(String codigo,Map<String,Object> r) {
        Assert.areEqual(false,r.get('ok'),JSON.serialize(r));Assert.isNull(r.get('resultado'));
        Assert.areEqual(codigo,((Map<String,Object>)((List<Object>)r.get('errores'))[0]).get('codigo'),JSON.serialize(r));
        Assert.isFalse(JSON.serialize(r).contains('stackTrace'));
    }
    @IsTest static void propiaSinDmlYFueraDeAmbito() {
        datos();Date d=lunes();User a=actor('a'),b=actor('b');
        Test.startTest();
        System.runAs(a) {
            Integer antes=Limits.getDmlStatements();
            Map<String,Object> r=bien(consultar(d,d));
            Assert.areEqual(antes,Limits.getDmlStatements());Assert.areEqual(105,r.get('totalMinutos'));Assert.areEqual(3,r.get('numeroLineas'));
            Assert.areEqual(true,r.get('completo'));Assert.areEqual(1000,r.get('limiteLineas'));
            Assert.isFalse(JSON.serialize(r).contains(b.Id));
        }
        System.runAs(b) {
            Map<String,Object> r=bien(consultar(d,d));
            Assert.areEqual(60,r.get('totalMinutos'));Assert.areEqual(1,r.get('numeroLineas'));
            Assert.isFalse(JSON.serialize(r).contains(a.Id));
        }
        Test.stopTest();
    }
    @IsTest static void coordinacionHistoricoYSumas() {
        datos();Date d=lunes();User coord=actor('coord'),a=actor('a'),b=actor('b');Id historico=proyecto('INF_H');
        Test.startTest();
        System.runAs(coord) {
            Assert.isFalse(DedicacionDiaria__c.SObjectType.getDescribe().isUpdateable());
            Map<String,Object> r=bien(consultar(d.addDays(-14),d));
            Assert.areEqual(150,r.get('totalMinutos'));Assert.areEqual(4,r.get('numeroLineas'));
            List<Object> semanas=(List<Object>)r.get('semanas');Assert.areEqual(2,semanas.size());
            Map<String,Object> semana=(Map<String,Object>)semanas[1];
            Assert.areEqual(105,semana.get('totalMinutos'));
            Map<String,Object> miembro=(Map<String,Object>)((List<Object>)semana.get('miembros'))[0];
            Assert.areEqual(a.Id,miembro.get('id'));Assert.areEqual(105,miembro.get('totalMinutos'));
            Integer suma=0;Boolean encontrado=false;
            for (Object raw : (List<Object>)miembro.get('proyectos')) {
                Map<String,Object> p=(Map<String,Object>)raw;Integer detalle=0;
                for (Object fila : (List<Object>)p.get('detalle')) detalle+=Integer.valueOf(((Map<String,Object>)fila).get('minutos'));
                Assert.areEqual(detalle,p.get('totalMinutos'));suma+=detalle;
                if (p.get('id')==historico) { encontrado=true;Assert.areEqual(false,p.get('activo'));Assert.areEqual(45,detalle); }
            }
            Assert.isTrue(encontrado);Assert.areEqual(105,suma);Assert.isFalse(JSON.serialize(r).contains(b.Id));
        }
        Test.stopTest();
    }
    @IsTest static void semanaVaciaConservaCabeceraYPapelera() {
        datos();Date d=lunes().addDays(-7);Id a=actor('a').Id;
        SemanaDedicacion__c antes=[SELECT Id,Revision__c,TotalMinutos__c FROM SemanaDedicacion__c WHERE Usuario__c=:a AND Inicio__c=:d];
        Test.startTest();
        System.runAs(actor('a')) {
            Map<String,Object> r=bien(consultar(d,d));Assert.areEqual(0,r.get('numeroLineas'));Assert.areEqual(0,r.get('totalMinutos'));
            Assert.areEqual(0,((List<Object>)r.get('semanas')).size());
        }
        Test.stopTest();
        SemanaDedicacion__c despues=[SELECT Revision__c,TotalMinutos__c FROM SemanaDedicacion__c WHERE Id=:antes.Id];
        Assert.areEqual(antes.Revision__c,despues.Revision__c);Assert.areEqual(antes.TotalMinutos__c,despues.TotalMinutos__c);
        Assert.areEqual(1,[SELECT count() FROM DedicacionDiaria__c WHERE Semana__c=:antes.Id AND IsDeleted=true ALL ROWS]);
    }
    @IsTest static void rechazosDeOperacionCrudYFls() {
        System.runAs(actor('sincrud')) {
            Assert.isTrue(FeatureManagement.checkPermission('P07_Consultar'));Assert.isFalse(ProyectoDedicacion__c.SObjectType.getDescribe().isAccessible());
            error('ACCESO_DENEGADO',consultar(lunes(),lunes()));
        }
        System.runAs(actor('sinfls')) {
            Assert.isTrue(ProyectoDedicacion__c.SObjectType.getDescribe().isAccessible());Assert.isFalse(ProyectoDedicacion__c.Activo__c.getDescribe().isAccessible());
            error('ACCESO_DENEGADO',consultar(lunes(),lunes()));
        }
        System.runAs(actor('sinperm')) {
            Assert.isTrue(ProyectoDedicacion__c.SObjectType.getDescribe().isAccessible());Assert.isFalse(FeatureManagement.checkPermission('P07_Consultar'));
            error('ACCESO_DENEGADO',consultar(lunes(),lunes()));
        }
    }
    @IsTest static void fechasYContratoEstricto() {
        System.runAs(actor('a')) {
            for (String bruto : new List<String>{null,'','{','[]','null','{}','{"desde":"2026-11-23","hasta":"2026-11-23","usuario":"ajeno"}'})
                error('VALIDACION',respuesta(P07_InformeService.consultar(bruto)));
            for (Object desde : new List<Object>{null,20261123,'2026-02-30','2026-11-24','2026-1-05','2026-11-23T00:00:00Z','2026-11-23 OR Id != null'}) {
                error('VALIDACION',respuesta(P07_InformeService.consultar(JSON.serialize(new Map<String,Object>{'desde'=>desde,'hasta'=>'2026-11-23'}))));
            }
            error('VALIDACION',consultar(lunes(),lunes().addDays(-7)));
            bien(consultar(Date.newInstance(2025,12,29),Date.newInstance(2026,1,5)));
        }
    }
    @IsTest static void limiteSinTruncamiento() {
        datos();
        Test.startTest();
        System.runAs(actor('a')) {
            P07_InformeService.limitePrueba=4;
            Map<String,Object> r=bien(consultar(lunes().addDays(-14),lunes()));
            Assert.areEqual(4,r.get('numeroLineas'));Assert.areEqual(150,r.get('totalMinutos'));
            P07_InformeService.limitePrueba=3;
            error('LIMITE_VOLUMEN',consultar(lunes().addDays(-14),lunes()));
        }
        Test.stopTest();
    }
    @IsTest static void relacionInaccesibleNoEsResultadoVacio() {
        datos();Id coord=actor('coord').Id,h=proyecto('INF_H');
        delete [SELECT Id FROM ProyectoDedicacion__Share WHERE ParentId=:h AND UserOrGroupId=:coord AND RowCause='Manual'];
        Test.startTest();
        System.runAs(actor('coord')) { error('ACCESO_DENEGADO',consultar(lunes(),lunes())); }
        Test.stopTest();
    }
    @IsTest static void accesoClaseSeparadoDeLlamadaDirecta() {
        PermissionSet p=[SELECT Id,PermissionsRunReports,PermissionsApiEnabled,PermissionsViewAllData,PermissionsModifyAllData FROM PermissionSet WHERE Name='P07_ConsultaInforme'];
        Id clase=[SELECT Id FROM ApexClass WHERE Name='P07_InformeService'].Id,b=actor('b').Id;
        Assert.areEqual(false,p.PermissionsRunReports);Assert.areEqual(false,p.PermissionsApiEnabled);Assert.areEqual(false,p.PermissionsViewAllData);Assert.areEqual(false,p.PermissionsModifyAllData);
        Assert.areEqual(1,[SELECT count() FROM SetupEntityAccess WHERE ParentId=:p.Id AND SetupEntityId=:clase]);
        Assert.areEqual(0,[SELECT count() FROM ObjectPermissions WHERE ParentId=:p.Id]);
        Assert.areEqual(0,[SELECT count() FROM PermissionSetAssignment WHERE AssigneeId=:b AND PermissionSetId=:p.Id]);
        System.runAs(actor('b')) {
            // Una llamada Apex directa no atraviesa la autorización de clase de la interfaz.
            Map<String,Object> r=bien(consultar(lunes(),lunes()));Assert.areEqual(0,r.get('numeroLineas'));
        }
    }
}
