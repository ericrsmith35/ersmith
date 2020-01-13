public with sharing class KnowledgeCategoriesController {


    @AuraEnabled
    public static KnowledgeCategoryWrapper[] getCategoryItems() {

        KnowledgeCategoryWrapper[] items = new List<KnowledgeCategoryWrapper>();
/*
        KnowledgeCategoryWrapper item;

        List<DescribeDataCategoryGroupStructureResult> category_struct_res = Schema.describeDataCategoryGroupStructures(getDataCategoryGroupPairs(null), false);

        for(DescribeDataCategoryGroupStructureResult struct : category_struct_res){
            item = new KnowledgeCategoryWrapper();
            item.Name = struct.getName();
            item.Label = struct.getLabel();
            item.ArticleCount = 0;

            DataCategory[] top_categories = struct.getTopCategories();
            item.Children = KnowledgeCategoriesController.getAllCategories(top_categories[0], item.name);
            item.selected = false;

            items.add(item);
        }
*/
        return items;
    }
/*
    public static KnowledgeCategoryWrapper[] getAllCategories(DataCategory root_category, String group_name){
        KnowledgeCategoryWrapper[] items = new List<KnowledgeCategoryWrapper>();
        KnowledgeCategoryWrapper item;

        DataCategory[] children = root_category.getChildCategories();

        for(DataCategory ch : children){
            item = new KnowledgeCategoryWrapper();
            item.Name = group_name +'__c:'+ ch.getName() +'__c';
            item.Label = ch.getLabel();
            item.ArticleCount = 0;
            item.Children = KnowledgeCategoriesController.getAllCategories(ch, group_name);
            item.selected = false;

            items.add(item);
        }

        return items;
    }

    public static List<DataCategoryGroupSobjectTypePair> getDataCategoryGroupPairs(String categoryGroup) {
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');

        List<DescribeDataCategoryGroupResult> category_groups = Schema.describeDataCategoryGroups(objType);

        for(DescribeDataCategoryGroupResult group_res : category_groups){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject('KnowledgeArticleVersion');

            if(categoryGroup != null && !Test.isRunningTest()) {
                p.setDataCategoryGroupName(categoryGroup);
                pairs.add(p);
                break;

            } else {
                p.setDataCategoryGroupName(group_res.getName());
                pairs.add(p);
            }
        }

        return pairs;
    }

    @AuraEnabled
    public static KnowledgeCategoryWrapper[] getCategoryItemsForBreadcrumbs(String categoryGroup, String category) {

        List<KnowledgeCategoryWrapper> items = new List<KnowledgeCategoryWrapper>();
        KnowledgeCategoryWrapper item;

        List<DescribeDataCategoryGroupStructureResult> category_struct_res = Schema.describeDataCategoryGroupStructures(getDataCategoryGroupPairs(categoryGroup), false);

        DataCategory[] top_categories = category_struct_res[0].getTopCategories();
        DataCategory[] children = top_categories[0].getChildCategories();

        for (DataCategory child: children) {
            item = new KnowledgeCategoryWrapper();
            item.Name = categoryGroup +'__c:'+ child.getName() +'__c';
            item.Label = child.getLabel();
            item.ArticleCount = 0;
            item.Children = null;
            item.selected = false;

            if(child.getName() == category) {
                items.add(item);
                break;

            } else {
                List<KnowledgeCategoryWrapper> innerItems = getCategoryChildItemsForBreadcrumbs(child, category, categoryGroup);

                if(isCategoryItemsContainItem(innerItems, category, categoryGroup)) {
                    items.add(item);
                    items.addAll(innerItems);
                    break;
                }
            }
        }

        System.debug(items);
        return items;
    }


    @AuraEnabled
    public static String getRandomCategoryGroupForItem(String itemId) {
        String category = '';

        String q = 'SELECT Id, (SELECT dataCategoryGroupName, dataCategoryName FROM DataCategorySelections)'
                +' FROM '+ getKnowledgeObjectName() +' WHERE Id = \''+ itemId +'\'';

        SObject article = Database.query(q);

        for (sObject cat : article.getSObjects('DataCategorySelections')) {
            category = String.valueOf(cat.get('dataCategoryGroupName')) + ':' + String.valueOf(cat.get('dataCategoryName'));
            break; //get only first random category
        }

        return category;
    }

    public static String getKnowledgeObjectName() {
        String name = '';
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();

        for(Schema.SObjectType f : gd) {
            name = f.getDescribe().getName();
            if (name.contains('__kav')) {
                return name;
            }
        }

        return '';
    }

    public static List<KnowledgeCategoryWrapper> getCategoryChildItemsForBreadcrumbs(DataCategory child, String category, String categoryGroup){

        DataCategory[] innerChildren = child.getChildCategories();
        List<KnowledgeCategoryWrapper> innerItems = new List<KnowledgeCategoryWrapper>();
        KnowledgeCategoryWrapper item;

        for (DataCategory innerChild: innerChildren) {
            item = new KnowledgeCategoryWrapper();
            item.Name = categoryGroup +'__c:'+ innerChild.getName() +'__c';
            item.Label = innerChild.getLabel();
            item.ArticleCount = 0;
            item.Children = null;
            item.selected = false;

            if(innerChild.getName() == category) {
                innerItems.add(item);

                return innerItems;

            } else {
                List<KnowledgeCategoryWrapper> childItems = getCategoryChildItemsForBreadcrumbs(innerChild, category, categoryGroup);

                if(isCategoryItemsContainItem(childItems, category, categoryGroup)) {
                    innerItems.add(item);
                    innerItems.addAll(childItems);

                    return innerItems;
                }
            }

        }

        return innerItems;

    }

    public static Boolean isCategoryItemsContainItem(List<KnowledgeCategoryWrapper> items, String category, String categoryGroup) {

        for(KnowledgeCategoryWrapper item: items) {
            if(item.Name == categoryGroup +'__c:'+ category +'__c') return true;
        }

        return false;
    }
*/

}