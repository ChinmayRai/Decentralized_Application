pragma solidity ^0.4.18;

contract Parking {
	
	struct parkingSpot{
		string name;
	    address owner;
		uint numBooking;
		int lat;
		int long;
		uint price;
	}

	struct booking {
		uint spotId;
		address renter;
		bool active;
		uint start; 
		uint end;
		uint price;
	}

	struct userData {
		uint numParkingSpots;
		uint userNum;
		uint numBooking;
	}
	
    address public overallOwner;
	mapping (address => string) public userPass;
	mapping (bytes32 => address) public userAddress;
	mapping (address => userData) public userAcc; 
	parkingSpot [] public spots;
	booking [] public bookings;
	uint public numSpots;  // traverse lots using this because of logical deletion
	uint public numBooking;
	uint public numUsers;
	uint[6][] public spotbookingIndex;
	uint[6][] public userSpotIndex;
	uint[6][] public userBookingIndex;
	

	//constructor
	function Parking() public {
		numBooking = 0;
		numSpots = 0;
		numUsers=0;
		overallOwner = msg.sender;
	}

	//changes state
   	function signUp (string _username, string _password, address _account) public returns (bool){
   		userPass[_account] = _password;
   		userAddress[keccak256(_username)] = _account;
   		userAcc[_account]= userData(0,numUsers,0);
   		userBookingIndex.push([32,32,32,32,32,32]);
   		userSpotIndex.push([32,32,32,32,32,32]);
   		numUsers++;
   		return true;
   	}
   	

	function addRentOutSpot(string _name, address _owner, int _lat, int _long, uint _price) public returns (bool){
		spots.push(parkingSpot(_name, _owner, 0, _lat, _long, _price));
		spotbookingIndex.push([32,32,32,32,32,32]);
		userSpotIndex[userAcc[_owner].userNum][userAcc[_owner].numParkingSpots]=numSpots;
		userAcc[_owner].numParkingSpots++;
        numSpots++;
        return true;
	}

	// i = index of spot
	function reserveSpot(uint _i, uint _start, uint _stop) public payable returns (bool){
		if(msg.value>=(spots[_i].price*(_stop-_start)/(3600))){
			if(checkAvailability(_i, _start, _stop)){
				bookings.push(booking(_i, msg.sender, true, _start, _stop, msg.value));
				spotbookingIndex[_i][spots[_i].numBooking] = numBooking;
				spots[_i].numBooking++;
				userBookingIndex[userAcc[msg.sender].userNum][userAcc[msg.sender].numBooking]=numBooking;
				userAcc[msg.sender].numBooking++;
				numBooking++;
				return true;
			}
			return false;
		}
		return false;
	}

	// index refers to bookingIndex of userData
	function abandonSpot(address _account, uint _index) public returns (bool) { 
		if (_index >= userAcc[_account].numBooking) return false;
		userData memory d = userAcc[_account];
		uint n = userBookingIndex[d.userNum][_index];
		bookings[n].active=false;
		address owner = spots[bookings[n].spotId].owner;
		owner.transfer(bookings[n].price );
	}
    
    //private function 
	function checkAvailability(uint _n, uint _start, uint _stop) private view returns (bool) {
		for (uint i=0; i<spots[_n].numBooking; i++){
			booking memory b = bookings[spotbookingIndex[_n][i]];
			if(b.start < _start && _start < b.end ) return false;
			else if (b.start < _stop && _stop < b.end ) return false;
			else if (b.start > _start && b.end < _stop ) return false;
		}
		return true;
	}

	function hash(string _s) public pure returns (bytes32){
		return keccak256(_s);
	}
    
    //deletes the contract  	
   	function close() public  { //onlyOwner is custom modifier
         if (msg.sender == overallOwner) selfdestruct(overallOwner);  // `owner` is the owners address
    }

}

