pragma solidity ^0.4.18;

contract Parking {
	
	struct parkingSpot{
	    address owner;
		booking [] records;
		uint numRecords;
		uint lat;
		uint long;
		uint price;
	}

	struct booking {
		uint id;
		address renter;
		uint parkingSpot;
		uint start; 
		uint end;
		uint price;
	}

	struct userData {
		booking [] tx;
		uint txCount;
	}
	
    address overallOwner;
	mapping (address => string) private userPass;
	mapping (string => address) private userAddress;
	mapping (address => userData) public userAcc; 
	parkingSpot [] public spots;
	uint public numSpots;  // traverse lots using this because of logical deletion
	uint private recordID;

	//constructor
	function Parking () public {
		recordID = 1;
		numSpots = 0;
		overallOwner = msg.sender;
	}

	//changes state
   	function signUp (string username, string password, address account) public returns (bool){
   		if (bytes(userPass[account]).length != 0) return false;
   		userPass[account] = password;
   		userAddress[username] = account;
   		return true;
   	}
   	
   	//view function
	function authenticate  (string usr, string pwd) public view returns(bool)  {
		return (compareStrings(pwd,userPass[userAddress[usr]]));
	}

	//view function
	//returns an array of indices pertaining to array lots to retrieve information of properties owned by user
	function ownerProperties (address user) public returns (uint []) { 
		uint  []  a;
		for (uint i=0; i<numSpots; i++) if(spots[i].owner == user) a.push(i);
		return a;
	}

	//changes state
	function addRentOutSpot(address owner, uint256 lat, uint256 long, uint price) public {
		// does not check if it exists from before
	    parkingSpot s;
	    s.owner = owner;
	    s.lat = lat;
	    s.long = long;
	    s.price = price;
	    s.numRecords = 0;
	    spots.push(s);
        numSpots ++;	    
	}

	//changes state
	function removeRentProperty (uint index) public returns (bool){  // index = index in lots of property
		//check if it can be deleted at the moment?
		if (spots[index].owner == address(0)) return false;
		if (spots[index].numRecords > 0) return false;
		spots [index] = spots [numSpots - 1]; 
		delete spots[numSpots - 1];
		numSpots--;
		return true;
	}


	
	function nearSpots(uint long, uint lat) public  returns (uint []) {
		uint  [] a;
		uint [] distances; 
		uint max = 0;
		for (uint i = 0; i<numSpots; i++){
		    distances.push((long-spots[i].long)*(long-spots[i].long) + (lat-spots[i].lat)*(lat-spots[i].lat));
		    if(distances[i]>max) max = distances[i];
		}
		uint threshold = 0;
		uint min = max;
		uint index = 0;
		for (uint j = 0; j < 3; j++){
		    for (uint k =0; k<numSpots; k++){
		        if(threshold < distances[k] && distances[k] < min){
		            min = distances[k];
		            index = k;
		        }
		    }
		    a.push(index);
		    threshold = min;
		    min = max;
		}
		return a;
	}
				
	//changes state												//i = parkingLotIndex
	function reserveSpot(address account,uint i, uint start, uint stop) public payable returns (bool){
		if(msg.value>=spots[i].price*(stop-start)/(3600) ){
			if(checkAvailability(spots[i], start, stop)){
				booking memory b = booking(recordID++, msg.sender, i, start, stop, msg.value);
				spots[i].records[spots[i].numRecords++] = b;
				userAcc[account].tx[userAcc[account].txCount++] = b;
				return true;
			}
		}
		return false;
	}

    //changes state
	// index refers to booking index in struct user
	function abandonSpot(address account, uint index) public returns (bool) { 
		if (index >= userAcc[account].txCount) return false;
		uint ID = userAcc[account].tx[index].id;
		uint spot = userAcc[account].tx[index].parkingSpot;
		address person = spots[spot].owner;
		uint amount = userAcc[account].tx[index].price;
		userAcc[account].tx[index] = userAcc[account].tx[userAcc[account].txCount-- - 1];
		for (uint i = 0; i < spots[spot].numRecords; i++){
			if (spots[spot].records[i].id == ID){
				spots[spot].records[i] = spots[spot].records[spots[spot].numRecords-- - 1];
				person.transfer(amount);
				return true;
			}
		}
		return false;
	}
    
    //private function 
	function checkAvailability(parkingSpot s, uint start, uint stop) private returns (bool) {
		for (uint i=0; i<s.numRecords; i++){
			if(s.records[i].start < start && start < s.records[i].end ) return false;
			else if (s.records[i].start < stop && stop < s.records[i].end ) return false;
			else if (s.records[i].start > start && s.records[i].end < stop ) return false;
		}
		return true;
	}
    
    //private function
	function compareStrings (string a, string b) private pure returns (bool){
       	return keccak256(a) == keccak256(b);
   	}
 
    //deletes the contract  	
   	function close() public  { //onlyOwner is custom modifier
         if (msg.sender == overallOwner) selfdestruct(overallOwner);  // `owner` is the owners address
    }

}


