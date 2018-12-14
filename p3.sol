pragma solidity ^0.4.18;

contract Parking {
	
	struct parkingSpot{
	    address owner;
		mapping (uint => uint) bookingIndex;
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
		mapping (uint => uint) parkingSpotIndex;
		uint numParkingSpots;
		mapping (uint => uint) bookingIndex;
		uint numBooking;
	}
	
    address public overallOwner;
	mapping (address => string) public userPass;
	mapping (address => string) public userAddress;
	mapping (address => userData) public userAcc; 
	parkingSpot [] public spots;
	booking [] public bookings;
	uint public numSpots;  // traverse lots using this because of logical deletion
	uint public numBooking;

	//constructor
	function Parking() public {
		numBooking = 0;
		numSpots = 0;
		overallOwner = msg.sender;
	}

	//changes state
   	function signUp (string username, string password, address account) public returns (bool){
   		userPass[account] = password;
   		userAddress[account] = username;
   		userAcc[account]=userData({numParkingSpots: 0, numBooking: 0});
   		return true;
   	}
   	

	function addRentOutSpot(address owner, int lat, int long, uint price) public returns (bool){
		spots.push(parkingSpot({owner:owner,  numBooking:0, lat:lat, long:long, price:price}));
		userAcc[owner].parkingSpotIndex[userAcc[owner].numParkingSpots]=numSpots;
		userAcc[owner].numParkingSpots++;
        numSpots++;
        return true;
	}

	// i = index of spot
	function reserveSpot(uint i, uint start, uint stop) public payable returns (bool){
		if(msg.value>=spots[i].price*(stop-start)/(3600) ){
			if(checkAvailability(i, start, stop)){
				bookings.push(booking(i, msg.sender, true, start, stop, msg.value));
				spots[i].bookingIndex[spots[i].numBooking] = numBooking;
				spots[i].numBooking++;
				userAcc[msg.sender].bookingIndex[userAcc[msg.sender].numBooking]=numBooking;
				userAcc[msg.sender].numBooking++;
				numBooking++;
				return true;
			}
			return false;
		}
		return false;
	}

	// index refers to bookingIndex of userData
	function abandonSpot(address account, uint index) public returns (bool) { 
		if (index >= userAcc[account].numBooking) return false;
		uint n = userAcc[account].bookingIndex[index];
		bookings[n].active=false;
		address owner = spots[bookings[n].spotId].owner;
		owner.transfer(bookings[n].price);
	}
    
    //private function 
	function checkAvailability(uint n, uint start, uint stop) private view returns (bool) {
		for (uint i=0; i<spots[n].numBooking; i++){
			booking memory b = bookings[spots[n].bookingIndex[i]];
			if(b.start < start && start < b.end ) return false;
			else if (b.start < stop && stop < b.end ) return false;
			else if (b.start > start && b.end < stop ) return false;
		}
		return true;
	}
    
    //deletes the contract  	
   	function close() public  { //onlyOwner is custom modifier
         if (msg.sender == overallOwner) selfdestruct(overallOwner);  // `owner` is the owners address
    }

}

