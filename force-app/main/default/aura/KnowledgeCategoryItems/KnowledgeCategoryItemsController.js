({
    filterByCategory: function(cmp, event){
        var targetEl = event.currentTarget,
            categoryClicked = targetEl.dataset.id,
            categoryClickedLabel = targetEl.dataset.label,
            cmpEvent = cmp.getEvent('knowledgeCategoryClickedInner');

        cmpEvent.setParam("categoryName", categoryClicked);
        cmpEvent.setParam("categoryLabel", categoryClickedLabel);
        cmpEvent.fire();
    },

    collapseCategories: function(cmp, event){
        var cmpEvent = cmp.getEvent('knowledgeCategoryCollapse');
/*
            collapseButton = event.getSource();

        if(collapseButton.get('v.iconName') === 'utility:add') {
            collapseButton.set('v.iconName', 'utility:dash');

        } else {
            collapseButton.set('v.iconName', 'utility:add');
        }
*/

        cmpEvent.setParam("category", event.getSource().get('v.value'));
        cmpEvent.fire();
    }
})