pragma solidity ^0.4.18;

contract CrowdFunding {
    
	// Investor struct
	struct Investor {
		address addr; // investor's address
		uint amount; // investment amount
	}

	address public owner; // contract owner
	uint public numbInvestors; // the number of investors
	uint public deadline; // deadline for this contract to be closed
	string public status; // "Funding", "Campaign Success", "Campaign Failed"
	bool public end; // the end of funding
	uint public goalAmount; // target amount
	uint public totalAmount; //total amount
	mapping(uint => Investor) public investors;

	event GoalReached(address ownerAddress, uint amountRaisedValue);
	event FundTransfer(address backer, uint amount, bool isContribution);
    
    // Create modifier to limit to owner
    modifier onlyOwner()    {
        require(msg.sender==owner);
        _;
    }

    // Create modifier to check if deadline has passed
    modifier afterDeadline() {
		require (now >= deadline);
		_;
	}
	
	// Constructor
	function CrowdFunding(uint _durationMinutes, uint _goalAmount,uint _costOfToken, address _tokenAddress) public {
		// Initialize owner, deadline, goalAmount, status,end, numbInvestors, totalAmount
		owner = msg.sender;
		deadline = now + _duration * 1 minutes;
		goalAmount = _goalAmount * 1 ether;
		status="Funding";
		end= false;
		numbInvestors = 0;
		totalAmount =0;
	}

	// Function to be called when investing
	function fund() public payable {
		// 1. Check if this crowd funding ended or not
		require(  now < deadline   );
		
		// 2. Set invest-related info and process funding
		investors[numbInvestors] = Investor(msg.sender,msg.value);
		numbInvestors++;
		totalAmount += msg.value;
	}


	function checkFoalReached () public onlyOwner() {
	    
		// 1. Check if this crowd funding ended or not
		require(end==false);
		
		// 2. Check if the deadline is past or not
		require(now >= deadline);
		
		// 3-1. If this crowdfunding is successful, send funded ETH to owner
		if(totalAmount >= goalAmount * 1000000000000000000){
		    owner.transfer(totalAmount);
		    status="Campaign Success";
		    totalAmount=0;
		}
		
// 3-2. If not, return fund-raising to each investor
		else{
		    status = "Campaign Failed";
		    for(uint i=0; i<numbInvestors ; i++){
		        investors[i].addr.transfer(investors[i].amount);
		    }
		}
		
		// Consider updating status and end
		end=true;
	}
	

	// 1. Create function to destroy this contract
	function self_destroy () public onlyOwner() {
	    selfdestruct(owner);
	}

}


