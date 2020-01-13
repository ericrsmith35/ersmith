/* Class:       IPUtils
 * Created On:  
 * Created by:  J. Pipkin (OpFocus, Inc)
 * Description: 
 */
 
public with sharing class IPUtils {

	static final String v4 = 'IPv4';
	static final String v6 = 'IPv6';
	static final Integer v4bit = 32;
	static final Integer v6bit = 128;
	static final Integer v4max = 255;
	static final Integer v6max = 65535;
	static final String v4sep = '.';
	static final String v6sep = ':';
	private static final String [] hexchars = new String[] {'0' , '1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9' , 'a' , 'b' , 'c' , 'd' , 'e' , 'f'};
	
	public class IPException extends Exception{}

	/*
		**************************** CALLABLE ****************************
	 */

	public static String getEndIPFromStart(String ipv, String startIP, String cidrSize){
		if(ipv == v4){
			return getIPv4EndFromStart(startIP, cidrSize);
		}
		//else if(ipv == v6){
		//	return getIPv6EndFromStart(startIP, cidrSize);
		//}
		return null;
	}



	public static Integer getCIDRSize(String typex, String cidr){
		String sz = cidr.replaceAll('/','');
		Double cs = Double.valueOf(sz);
		return Integer.valueOf(Math.pow((Double) 2, (typex == v4 ? v4bit : v6bit) - cs));
	}


    public static String decimalToHex(Integer i, Integer max) {
    	if(max != null){
	    	String hexMax = 'f'.repeat(max);
	    	if(i > hexToDecimal(hexMax)){
	    		throw new IPException('Decimal is higher than the max hexidecimal length');
	    	}
	    }
    	List<String> hexStrs = new List<String>();
    	Integer pwr = 16;
    	while(i > 0){
    		hexStrs.add(hexchars[i & pwr - 1]);
    		i >>>= 4;
    	}
    	String hex = '';
    	for(Integer hx = hexStrs.size() - 1; hx > -1; hx--){
    		hex += hexStrs[hx];
    	}
    	return hex;
    }

    public static Integer hexToDecimal(String hex){
    	hex = hex.toLowerCase();
    	Integer dec = 0;
    	String[] hexsplit = hex.split('');
    	for(Integer i = 0; i < hex.length(); i++){
    		Integer pos = hexchars.indexOf(hexsplit[i]);
    		dec = dec * 16 + pos;
    	}
    	return dec;
    }

    public static Long hexToDecimall(String hex){
    	hex = hex.toLowerCase();
    	Long dec = 0;
    	String[] hexsplit = hex.split('');
    	for(Integer i = 0; i < hex.length(); i++){
    		Integer pos = hexchars.indexOf(hexsplit[i]);
    		dec = dec * 16 + pos;
    	}
    	return dec;
    }

    public static String[] getOctets(String ip, String typex){
		if(typex == v4){
			return ip.split('\\.');
		}
		else{
			return ip.split(':');
		}
	}


	/*
		**************************** IPv4 ****************************
	 */
	
	private static String getIPv4EndFromStart(String startIP, String cidrSize){
		List<Integer> int_octets = startIncrement(startIP, v4, cidrSize);

		List<String> endingOctets = new List<String>();
		for(Integer oct : int_octets){
			endingOctets.add(String.valueOf(oct));
		}
		System.debug('returning: ' + String.join(endingOctets, v4sep));
		return String.join(endingOctets, v4sep);
	}



	/*
		**************************** IPv6 ****************************
	 */
	
	//private static String getIPv6EndFromStart(String startIP, String cidrSize){
	//	List<Integer> int_octets = startIncrement(startIP, v6, cidrSize);
	//	System.debug('int_octets: ' + int_octets);
	//	List<String> endingOctets = new List<String>();
	//	for(Integer oct : int_octets){
	//		String res = decimalToHex(oct,4);
	//		res = '0'.repeat(4-res.length()) + res;
	//		endingOctets.add(res);
	//	}

	//	System.debug('returning: ' + String.join(endingOctets, v6sep));
	//	return String.join(endingOctets, v6sep);
	//}

	
	/*
		**************************** COMMON ****************************
	 */

	
	private static Integer[] startIncrement(String startIP, String typex, String cidrSize){
		String[] octets = separateOctets(startIP,typex);
		System.debug(octets);
		List<Integer> int_octets = new List<Integer>();
		for(String oct : octets){
			if(typex == v4)
				int_octets.add(Integer.valueOf(oct));
			//else{
			//	int_octets.add(hexToDecimal(oct));
			//}
		}
		Integer size = getCIDRSize(typex, cidrSize);
		Integer count = 1;
		incrementOctets(typex, int_octets, size, count);
		
		return int_octets;
	}

	private static String[] separateOctets(String startIP, String typex){
		return typex == v4 ? startIP.split('\\' + v4sep) : startIP.split('\\' + v6sep);
	}

	

	private static Boolean isMaxValue(Integer i, String typex){
		return typex == v4 ? (i == v4max ? true : false) : (i == v6max ? true : false);
	}

	private static Integer getMaxValue(String typex){
		return typex == v4 ? v4max : v6max;
	}

	private static void incrementOctets(String typex, List<Integer> int_octets, Integer increment, Integer counter){
		Integer octIndx = int_octets.size() - 1;
		while(!isMaxValue(int_octets[octIndx], typex) && counter < increment){
			System.debug('left: ' + (increment - counter));
			if(increment - counter > getMaxValue(typex)){
				int_octets[octIndx] = getMaxValue(typex);
				counter += getMaxValue(typex);
			}
			else{
				int_octets[octIndx] ++ ;
				counter++;
			}
		}

		if(counter == increment){
			return;
		}

		if(isMaxValue(int_octets[octIndx], typex)){
			//System.debug('before left: ' + octIndx);
			incrementLeftOctet(octIndx, int_octets);
			//System.debug('after left: ' + octIndx);
			//System.debug('int_octets: ' + int_octets);
		}
		incrementOctets(typex, int_octets, increment, counter);
	}

	

	private static void incrementLeftOctet(Integer octIndx, List<Integer> int_octets){
		int_octets[octIndx - 1] += 1;
		for(Integer reset = octIndx ; reset < int_octets.size(); reset++){
			int_octets[reset] = -1;
		}
	}

	


	

	
}