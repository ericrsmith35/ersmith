/* Class:       InsertAssetsFromOLI
 * Created On:  July 2018
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: Batch class to bulk insert Assets. Called from OLI_Select_ap.class. Tested in OLI_Select_ap_Test.cls
 */

 
global class InsertAssetsFromOLI implements Database.Batchable<SObject>, Database.Stateful {

    // private constructor. Dev should use batchAssets() static method
    private InsertAssetsFromOLI(Asset[] assets){
        this.assets = assets;
    }

    // callable method to kick off batch
    global static void batchAssets(Asset[] assets){
        Database.executeBatch(new InsertAssetsFromOLI(assets), 100);
    }

    private Asset[] assets;

    // start method
    global Asset[] start(Database.BatchableContext bc) {
        return assets;
    }
    
    // execute
    global void execute(Database.BatchableContext bc, List<Asset> assets){
        // just insert
        insert assets;
    }
    
    // when all batches are done
    global void finish(Database.BatchableContext bc) {}
    
}