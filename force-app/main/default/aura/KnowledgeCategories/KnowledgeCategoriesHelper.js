({

    retrieveCategoryItems: function (cmp, callback) {
        var action = cmp.get('c.getCategoryItems');

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {
                if (typeof callback === 'function') {
                    callback(resVal);
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateCategoryItems: function(cmp, items){
        var categoryItems = items ? items : cmp.get('v.categoryItems'),
            filters = cmp.get('v.filters'),
            filterCategories = filters.category ? filters.category : [],
            openedCats = cmp.get('v.openedCats');

        for(var i=0;i<categoryItems.length;i+=1){
            if(categoryItems[i].Children && categoryItems[i].Children.length > 0){
                this.updateCategoryChildItems(categoryItems[i].Children, filterCategories, openedCats);
            }
        }

        cmp.set('v.categoryItems', categoryItems);
    },

    updateCategoryChildItems: function(childItems, filterCategories, openedCats){

        for(var i=0;i<childItems.length;i+=1){
            childItems[i].selected = this.inArray(filterCategories, childItems[i].Name);
            childItems[i].opened = this.inArray(openedCats, childItems[i].Name);

            if(childItems[i].Children && childItems[i].Children.length > 0){
                this.updateCategoryChildItems(childItems[i].Children, filterCategories, openedCats);
            }
        }
    },

    retrieveOpenedCategories: function(cmp, categoryName, callback) {
        var action = cmp.get('c.getCategoryItemsForBreadcrumbs'),
            categoryParts,
            group,
            category;

        categoryName = categoryName.replace(/__c/g, '');
        categoryParts = categoryName.split(':');
        group = categoryParts[0];
        category = categoryParts[1];

        if(!group || !category) {
            return;
        }

        action.setParams({
            categoryGroup: group,
            category: category
        });

        //action.setStorable();

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue(),
                openedCats = [];

            if (state === 'SUCCESS') {

                for(var i=0;i<resVal.length;i+=1){
                    openedCats.push(resVal[i].Name);
                }

                cmp.set('v.openedCats', openedCats);

                if (typeof callback === 'function') {
                    callback();
                }
            }
        });

        $A.enqueueAction(action);
    },

    inArray: function(arr, val) {
        return arr.some(function(arrVal) {
            return val === arrVal;
        });
    }
})