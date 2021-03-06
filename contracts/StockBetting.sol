pragma solidity 0.5.16;

contract StockBetting {
    struct Bid {
        address payable account;

        uint bid; // estimated stock value in now + _biddingtime
        uint amount; //todo: replace with deposit
    }

    Bid[] public bids;

    // Time how long the contract is active 
    uint public runEndTime;
    
    // Time how long the bids are allowed
    uint public bidEndTime;

    // admin of the contract -> StockVoting.net
    address payable public chairperson;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool ended;

    // Events that will be emitted on changes.
    event NewBid(address payable account, uint bid, uint amount);
    event Payout(address payable winner, uint payout);

    constructor(
        //todo payable
        address payable _chairperson,
        uint _runTime,
        uint _bidTime
        )
    public {
        chairperson = _chairperson;
        // todo: Safe?
        runEndTime = now + _runTime;
        bidEndTime = now + _bidTime;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    function bid(uint bidValue) public payable {
        // The keyword payable
        // is required for the function to
        // be able to receive Ether.

        // Revert the call if the bidding
        // period is over.
        require(
            now <= runEndTime,
            "No bid possible anymore, the run time has ended"
        );
        require(
            now <= bidEndTime,
            "No bid possible anymore, the time to bid has ended"
        );

        bids.push(Bid({
            account: msg.sender,
            bid: bidValue,
            amount: msg.value
        }));

        emit NewBid(msg.sender, bidValue, msg.value);

        return;
    }

    /// End the betting because the time is up 
    /// to the winner.
    function bettingEnd(uint stockValue) external payable {
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts

        require(msg.sender==chairperson, "Not the rights to end this contract");
        require(now >= runEndTime, "Runtime of contract is not over yet");
        require(!ended, "Contract has already ended");


        if(1==bids.length)
        {
            // One on bid Give bider possibility to withdraw bet
            address payable lonelyBider = bids[0].account;
            uint bidsum = bids[0].amount;
            emit Payout(lonelyBider, bidsum);

            //todo: give voter possibility to withdraw money (safer)
            lonelyBider.transfer(bidsum);
            return;
        }

        // 2. Effects
        ended = true;
        uint payoutsum = 0;
        //todo: optimize -> not safe
        // int distance = Math.abs(numbers[0] - myNumber);
        uint previous_diff = 10000;
        address payable winner;

        for (uint p = 0; p < bids.length; p++) {
            payoutsum = payoutsum + bids[p].amount;
            uint bidValue = bids[p].bid;
            //Calculate absolute value (distance to stockValue)
            uint diffStock = (stockValue > bidValue) ? stockValue - bidValue : bidValue - stockValue;

            if(previous_diff>diffStock)
            {
                previous_diff = diffStock;
                winner = bids[p].account;
            }
        }

        emit Payout(winner, payoutsum);

        // 3. Interaction
        // Note that this is not visible on the blockchain, it is only executed through the contract itself
        // https://ethereum.stackexchange.com/questions/8315/confused-by-internal-transactions
        //todo: give winner possibility to withdraw money (safer)

        winner.transfer(payoutsum);
    }

    // Getter/Setter
    function getBidofAccount(address payable _accountToCheck) public view returns(uint) {
        for (uint p = 0; p < bids.length; p++) {
            if (bids[p].account == _accountToCheck){
                return bids[p].bid;
            }
        }
    }

   	function getBalance(address payable addr) public view returns(uint) {
		return addr.balance;
	}

    function setrunEndTime(uint _newrunEndTime) public {
        require(msg.sender==chairperson, "Not the rights to change this value");
		runEndTime = _newrunEndTime;
	}
    function setbidEndTime(uint _newbidEndTime) public {
        require(msg.sender==chairperson, "Not the rights to change this value");
		bidEndTime = _newbidEndTime;
    }
}