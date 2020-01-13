trigger FeedCommentTrigger on FeedComment (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

     // Handles all FeedComment triggers
     // GWI - Eric Smith - Jan 2018

    if(trigger.isInsert && trigger.isAfter){
        for (FeedComment fc : trigger.new){
            // Call VWF to create Case if the FeedComment contains '#ticket'
            if (fc.CommentBody.toLowerCase().Contains('#ticket')) {
                Map<String, Object> params = new Map<String, Object>();
                params.put('vCommentId', fc.Id);
                Flow.Interview.Chatter_Feed_Comment_Create_Ticket callFlow = new Flow.Interview.Chatter_Feed_Comment_Create_Ticket(params);
                callFlow.start();
            }
        }
    }
}