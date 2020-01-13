@IsTest
private class KnowledgeCategoriesControllerTest {
    static testmethod void testGetCategoryItems() {
        KnowledgeCategoryWrapper[] items = KnowledgeCategoriesController.getCategoryItems();
        System.assertNotEquals(null, items);
    }
/*

    @testSetup static void setup() {
        List<SObject> articles = KnowledgeTestUtils.createTestArticles(1);
        System.assertEquals(true, articles.size() == 1, 'Wrong number of articles created');
    }

    static testmethod void testGetCategoryItems() {
        KnowledgeCategoryWrapper[] items = KnowledgeCategoriesController.getCategoryItems();
        System.assertNotEquals(null, items);
    }

    static testmethod void testGetCategoryItemsForBreadcrumbs() {
        KnowledgeCategoryWrapper[] items = KnowledgeCategoriesController.getCategoryItemsForBreadcrumbs('group', 'category');
        System.assertNotEquals(null, items);
    }

    static testmethod void testGetRandomCategoryGroupForItem() {
        SObject article = KnowledgeTestUtils.getArticle();

        String category = KnowledgeCategoriesController.getRandomCategoryGroupForItem(article.Id);
        System.assertNotEquals(null, category);
    }

    static testmethod void testIsCategoryItemsContainItem1() {
        List<KnowledgeCategoryWrapper> items = new List<KnowledgeCategoryWrapper>();
        KnowledgeCategoryWrapper cw = new KnowledgeCategoryWrapper();
        cw.Name = 'group__c:category__c';
        cw.Label = 'Test Category';
        cw.ArticleCount = 1;
        items.add(cw);

        Boolean containsItem = KnowledgeCategoriesController.isCategoryItemsContainItem(items, 'category', 'group');
        System.assertEquals(true, containsItem);
    }

    static testmethod void testIsCategoryItemsContainItem2() {
        List<KnowledgeCategoryWrapper> items = new List<KnowledgeCategoryWrapper>();
        KnowledgeCategoryWrapper cw = new KnowledgeCategoryWrapper();
        cw.Name = 'group:category';
        cw.Label = 'Test Category';
        cw.ArticleCount = 1;
        items.add(cw);

        Boolean containsItem = KnowledgeCategoriesController.isCategoryItemsContainItem(items, 'category', 'group');
        System.assertEquals(false, containsItem);
    }
*/

}