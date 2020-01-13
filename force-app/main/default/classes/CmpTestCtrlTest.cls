/* Class:       CmpTestCtrlTest
 * Created On:  
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */

@isTest
public class CmpTestCtrlTest {
	
	@testSetup static void buildData(){
		
	}

	//test methods

	static testMethod void myTest1() {
		CmpTestCtrl.Input i = new CmpTestCtrl.Input();
		i.deviceInfoStr = '{}';
		System.debug(i);
		//i.remove('deviceInfo');// = null;
		CmpTestCtrl.Output o = CmpTestCtrl.getAE('{"deviceInfoStr":"{}"}');
	}
	
	
}