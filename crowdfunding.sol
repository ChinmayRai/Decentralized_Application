pragma solidity ^0.4.18;

contract Parking {
	
	struct parkingLot {
		address owner;
		uint256 lat;
		uint256 long;
		string name;
		parkingSpot[] spots;
		uint num;
		uint price;
		uint size; // 0 = small, 1 = medium, 2 = big
	}


	struct parkingSpot{
		address renter;
		booking [] records;
		uint numRecords;
	}

	struct booking {
		uint id;
		address renter;
		uint parkingLot;
		uint parkingSpot;
		uint start; 
		uint end;
	}

	struct userData {
		string password;
		//address account;
		booking [] tx;
		uint txCount;
	}
	
    address overallOwner;
	mapping (string => address) private userAddress;
	mapping (address => userData) public userAcc; 
	mapping (address => uint) private etherAmount;
	parkingLot [] public lots;
	uint public numLots;  // traverse lots using this because of logical deletion
	uint private recordID;

	//constructor
	function Parking () public {
		recordID = 1;
		numLots = 0;
		overallOwner = msg.sender;
	}

	//changes state
   	function signUp (string username, string password, address account) public returns (bool){
   		if (bytes(userAcc[account].password).length != 0) return false;
   		userAcc[account].password = password;
   		//userAcc[username].account = account;
   		userAddress[username] = account;
   		return true;
   	}
   	//view function
	function authenticate  (string usr, string pwd) public view returns(bool)  {
		return (compareStrings(pwd,userAcc[userAddress[usr]].password));
	}

	//view function
	//returns an array of indices pertaining to array lots to retrieve information of properties owned by user
	function ownerProperties (address user) public returns (uint []) { 
		uint  [] storage a;
		for (uint i=0; i<numLots; i++) if(lots[i].owner == user) a.push(i);
		return a;
	}

	//changes state
	function addRentOutSpot(address owner, uint256 lat, uint256 long, string name, uint num, uint price, uint size) public {
		// does not check if it exists from before
		//booking  [] storage b;
		parkingSpot storage s;
		//s.records = b;
		parkingSpot [] storage list;
		for (uint i=0; i<num; i++) list.push(s);
		lots[numLots].spots = list;
		//parkingLot(owner, lat, long, name, list, num, price,size);
		lots[numLots].owner = owner;
		lots[numLots].lat = lat;
		lots[numLots].long = long;
		lots[numLots].name = name;
		lots[numLots].num = num;
		lots[numLots].price = price;
		lots[numLots].size = size;
		numLots++;
	}

	//changes state
	function removeRentProperty (address user, uint index) public returns (bool){  // index = index in lots of property
		//check if it can be deleted at the moment?
		if (lots[index].num == 0) return false;
		for (uint i = 0; i < lots[index].num; i++){
			if (lots[index].spots[i].records.length > 0) return false;
		}
		lots [index] = lots [numLots - 1]; 
		//delete lots[lots.length - 1];
		numLots--;
		return true;
	}


	//view functions
	function nearLots(uint long, uint lat) public view returns (uint []) {
		uint  [] a;
		uint [] distances; 
		uint max = 0;
		for (uint i = 0; i<numLots; i++){
		    distances.push((long-lots[i].long)*(long-lots[i].long) + (lat-lots[i].lat)*(lat-lots[i].lat));
		    if(distances[i]>max) max = distances[i];
		}
		uint threshold = 0;
		uint min = max;
		uint index = 0;
		for (uint j = 0; j < 5; j++){
		    for (uint k =0; k<numLots; k++){
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
	function reserveSpot(string username,uint i, uint start, uint stop) public payable returns (bool){
		if(msg.value>=lots[i].price*(stop-start)/(3600) ){
			for (uint j = 0; j<lots[i].num; j++){
					if(checkAvailability(lots[i].spots[j], start, stop)){
						address renter = msg.sender;
						booking memory b = booking(recordID, renter, i, j, start, stop);
						recordID++;
						lots[i].spots[j].records[lots[i].spots[j].numRecords] = b;
						lots[i].spots[j].numRecords++;
						userAcc[userAddress[username]].tx[userAcc[userAddress[username]].txCount] = b;
						userAcc[userAddress[username]].txCount++;
						etherAmount[userAddress[username]] += msg.value; 
						return true;
				}
			}
		}
		return false;
	}

    //changes state
	// index refers to booking index in struct user
	function abandonSpot(string username, string password, uint index) public returns (bool) { 
		if (!(index < userAcc[userAddress[username]].txCount)) return false;
		uint ID = userAcc[userAddress[username]].tx[index].id;
		uint lot = userAcc[userAddress[username]].tx[index].parkingLot;
		uint spot = userAcc[userAddress[username]].tx[index].parkingSpot;
		address person = lots[lot].owner;
		userAcc[userAddress[username]].tx[index] = userAcc[userAddress[username]].tx[userAcc[userAddress[username]].txCount - 1];
		userAcc[userAddress[username]].txCount--;
		for (uint i = 0; i < lots[lot].spots[spot].numRecords; i++){
			if (lots[lot].spots[spot].records[i].id == ID){
				lots[lot].spots[spot].records[i] = lots[lot].spots[spot].records[lots[lot].spots[spot].numRecords-1];
				lots[lot].spots[spot].numRecords--;
				person.transfer(etherAmount[userAddress[username]]);
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
	function compareStrings (string a, string b) private view returns (bool){
       	return keccak256(a) == keccak256(b);
   	}
 
    //deletes the contract  	
   	function close() public  { //onlyOwner is custom modifier
         if (msg.sender == overallOwner) selfdestruct(overallOwner);  // `owner` is the owners address
    }

}


