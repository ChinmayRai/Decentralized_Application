pragma solidity ^0.4.18;

contract Parking {

	struct location {
		uint degrees;
		uint minutes;
		uint seconds;
		boolean flag; //true means north or west, false means south or east
	}
	
	struct parkingLot {
		address owner;
		location lat;
		location long;
		string name;
		parkingSpot[] spots;
		uint num;
		uint price;
		uint size; // 0 = small, 1 = medium, 2 = big
	}


	struct parkingSpot{
		address renter;
		uint duration;
		uint startTime; 
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
		private string password;
	}

	struct userData {
		string password;
		address account;
		booking [] tx;
		uint txCount;
	}

	mapping (string => userData) public userAcc; 
	parkingLot [] lots;
	uint numLot;  // traverse lots using this because of logical deletion
	uint recordID;

	function Parking () public {
		recordID = 1;
		numLots = 0;
	}

   	function signUp (string username, string password, address account) public returns (bool){
   		if (userAcc[username].password.length != 0) return false;
   		userAcc[username].password = password;
   		userAcc[username].account = account;
   		return true;
   	}

	function authenticate public (string usr, string pwd) returns(bool) {
		return (compareStrings(pwd,userAcc[usr].password));
	}

	//returns an array of indices pertaining to array lots to retrieve information of properties owned by user
	function ownerProperties (address user) returns (uint []) { 
		uint [] a;
		for (int i=0; i<numLot; i++) if(lots[i].owner == user) a.push(i);
		return a;
	}

	function addRentOutSpot(address owner, string lat, string long, string name, uint num, uint price, uint size) public {
		// does not check if it exists from before
		parkingSpot [] s;
		for(int i=1; i<= num; i++){
			s.push()
		}
		location latitude;
		location longitude;
		var l = lat.toSlice();
		latitude.degrees = stringToUint(l.split(",".toSlice()));
		latitude.minutes = stringToUint(l.split(",".toSlice()));
		latitude.seconds = stringToUint(l.split(",".toSlice()));
		latitude.flag = compareStrings(l,"N");
		var l = long.toSlice();
		longitude.degrees = stringToUint(l.split(",".toSlice()));
		longitude.minutes = stringToUint(l.split(",".toSlice()));
		longitude.seconds = stringToUint(l.split(",".toSlice()));
		longitude.flag = compareStrings(l,"W");
		lots[numLot] = (parkingLot(owner, latitude, longitude, name, s, num, price,size));
		numLot++;
	}

	function removeRentProperty (address user, uint index) public returns (bool){  // index = index in lots of property
		//check if it can be deleted at the moment?
		if (lots[index].num == 0) return false;
		for (int i = 0; i < lots[index].num; i++){
			if (lots[index].spots[i].records.length > 0) return false;
		}
		lots [index] = lots [numLot - 1]; 
		//delete lots[lots.length - 1];
		numLot--;
		return true;
	}

	function nearLots(){

	}

	function reserveSpot(string username, string password,parkingLotIndex i, uint start, uint stop) public returns (bool){
		for (j = 0; j<lots[i].num; j++){
				if(checkAvailability(lots[i].spots[j], uint start, uint stop)){
					address renter = msg.sender;
					booking b = booking(recordID, renter, i, j, start, end, password);
					recordID++;
					lots[i].spots[j].records[lots[i].spots[j].numRecords] = b;
					lots[i].spots[j].numRecords++;
					userAcc[username].tx[userAcc[username].txCount] = b;
					userAcc[username].txCount++;
					return true;
			}
		}
		return false;
	}


	// index refers to booking index in struct user
	function abandonSpot(string username, string password, uint index) public returns (bool) { 
		if (!index < userAcc[username].txCount) return false;
		uint ID = userAcc[username].tx[index].id;
		uint lot = userAcc[username].tx[index].parkingLot;
		uint spot = userAcc[username].tx[index].parkingSpot;
		userAcc[username].tx[index] = userAcc[username].tx[userAcc[username].txCount - 1];
		userAcc[username].txCount--;
		for (int i = 0; i < lots[lot].spots[spot].numRecords; i++){
			if (lots[lot].spots[spot].records[i].id == ID){
				lots[lot].spots[spot].records[i] = lots[lot].spots[spot].records[lots[lot].spot[spots].numRecords-1];
				lots[lot].spots[spot].numRecords--;
				return true;
			}
		}
		return false;
	}

	function checkAvailability(parkingSpot s, uint start, uint stop){
		for (int i=0; i<s.numRecords; i++){
			if(s.records[i].start < start && start < s.records[i].end ) return false;
			else if (s.records[i].start < end && end < s.records[i].end ) return false;
			else if (s.records[i].start > start && s.records[i].end < end ) return false;
		}
		return true;
	}

	function compareStrings (string a, string b) view returns (bool){
       	return keccak256(a) == keccak256(b);
   	}

   	function stringToUint(string s) constant returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
}