pragma solidity ^0.4.18;

contract Parking {

	struct location {
		uint degrees;
		uint minutes;
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
		bool status;
		address renter;
		uint duration;
		uint startTime; 
	}

	parkingLot [] lots;
	uint numLot;

	function nearLots(){

	}

	function reserveSpot(parkingSpot p,  parkingLot l) public {
		p.status = true;
		renter = sender.address;
	}



	function abandonSpot(parkingSpot p, parkingLot l) public {
		p.status = false;
		renter = null;
	}

	function addRentOutSpot(address owner, string lat, string long, uint num, uint price, uint size) public {
		parkingSpot [] s;
		for(int i=1; i<= num; i++){
			s.push(i,false)
		}
		lots.push(parkingLot(owner, lat, long, s, num, price,size));
		sNo++;
	}

}