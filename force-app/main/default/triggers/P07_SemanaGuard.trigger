trigger P07_SemanaGuard on SemanaDedicacion__c (before insert, before update, before delete, after undelete) {
    P07_DedicacionService.protegerSemana();
}
