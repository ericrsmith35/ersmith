({
    retrieveCategory: function(cmp, callback) {
        var action = cmp.get('c.getRandomCategoryGroupForItem');

        action.setParams({
            itemId: cmp.get('v.recordId')
        });

        action.setStorable();

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS' && resVal) {
                if (typeof callback === 'function') {
                    callback(resVal);
                }
            }
        });

        $A.enqueueAction(action);
    },

    retrieveCategories: function(cmp, categoryName) {
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

        action.setStorable();

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {

                if(resVal.length > 0) {
                    cmp.set('v.categoryItems', resVal);
                }
            }
        });

        $A.enqueueAction(action);
    },

    parseUrlHash: function() {
        var varsObj = {},
            hashArr = [],
            keyVal = [];

        if (location.hash !== null && location.hash.length > 0) {
            hashArr = location.hash.replace('#/', '').replace('#', '').split('&');

            for (var i = 0; i < hashArr.length; i+=1) {
                keyVal = hashArr[i].split("=");

                if (keyVal.length === 2) {
                    varsObj[keyVal[0]] = keyVal[1];
                } else if (i === 0 && keyVal.length === 1) {
                    varsObj.id = keyVal[0];
                }
            }
        }

        return varsObj;
    }
})