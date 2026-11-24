trigger P07_DedicacionGuard on DedicacionDiaria__c (before insert, before update, before delete, after undelete) {
    P07_DedicacionService.protegerDedicacion();
}
