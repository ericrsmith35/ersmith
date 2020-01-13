({
    doInit: function(cmp, event, helper) {
        var filters = cmp.get('v.filters'),
            hashObj,
            categories;

        if(!filters) {
            hashObj = helper.parseUrlHash()

            if(hashObj.hasOwnProperty('category')) {
                categories = hashObj.category.split(',');
                helper.retrieveCategories(cmp, categories[0]);

            } else {
                helper.retrieveCategory(cmp, function(category) {
                    helper.retrieveCategories(cmp, category);
                });
            }
        }
    },

    filterByCategory: function (cmp, event, helper) {
        var name = event.getSource().get('v.name'),
            cmpEvent = cmp.getEvent('knowledgeCategoryClickedFromBreadcrumbs');

        cmpEvent.setParam("categoryName", name);
        cmpEvent.fire();
    },

    retrieveCategories: function(cmp, event, helper) {
        var filters = cmp.get('v.filters');

        if(filters.hasOwnProperty('category') && filters.category.length > 0 && filters.category[0] !== 'home') {
            helper.retrieveCategories(cmp, filters.category[0]);

        } else {
            cmp.set('v.categoryItems', null);
        }
    }
})