({
    doInit: function(cmp, event, helper){
        var filters = cmp.get('v.filters');

        helper.retrieveCategoryItems(cmp, function (items) {

            if(filters.hasOwnProperty('category') && filters.category.length > 0) {
                helper.retrieveOpenedCategories(cmp, filters.category[0], function() {
                    helper.updateCategoryItems(cmp, items);
                });

            } else {
                helper.updateCategoryItems(cmp, items);
            }
        });
    },

    clearCategoryFilters: function(cmp, event, helper){
        var cmpEvent = cmp.getEvent('knowledgeCategoryResetInner');
        cmpEvent.fire();
        cmp.set('v.openedCats', []);
        helper.updateCategoryItems(cmp);
        cmp.set('v.categoriesOpened', true);
    },

    handleCategoryClicked: function(cmp, event, helper){
        cmp.set('v.categoriesOpened', true);
    },

    handleCollapseCategory: function(cmp, event, helper){
        var openedCats = cmp.get('v.openedCats'),
            categoryClicked = event.getParam('category');

        if(!helper.inArray(openedCats, categoryClicked)){
            openedCats.push(categoryClicked);
        } else {
            var index = openedCats.indexOf(categoryClicked);
            if (index > -1) {
                openedCats.splice(index, 1);
            }
        }

        cmp.set('v.openedCats', openedCats);
        helper.updateCategoryItems(cmp);
    },

    updateCategoryItems: function(cmp, event, helper){
        helper.updateCategoryItems(cmp);
    },

    toggleCategories: function(cmp){
        var categoriesOpened = cmp.get('v.categoriesOpened');

        if(categoriesOpened){
            cmp.set('v.categoriesOpened', false);
        } else {
            cmp.set('v.categoriesOpened', true);
        }
    }
})