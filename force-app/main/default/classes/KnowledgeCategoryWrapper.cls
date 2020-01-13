public with sharing class KnowledgeCategoryWrapper {
    @AuraEnabled
    public String Name;

    @AuraEnabled
    public String Label;

    @AuraEnabled
    public Integer ArticleCount;

    @AuraEnabled
    public List<KnowledgeCategoryWrapper> Children;

    @AuraEnabled
    public Boolean selected;

    @AuraEnabled
    public Boolean opened;

}