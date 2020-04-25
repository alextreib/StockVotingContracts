pragma solidity 0.5.16;

//todo: StockBetting
// This contract is unique per stock, but the 
contract StockBetting {
    // Parameters of the auction. Times are either
    // absolute unix timestamps (seconds since 1970-01-01)
    // or time periods in seconds.

    struct Bid {
        address payable account;

        uint bid; // estimated stock value in now + _biddingtime
        uint amount; //todo: replace with deposit
    }

    Bid[] public bids;
    // mapping(address => Bid) public bids;

    uint public bidEndTime;
    // bytes32 public StockSymbol;

    // admin of the contract -> StockVoting
    address public chairperson;

    //todo: publish address of winner (after contract ended)

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool ended;

    // Events that will be emitted on changes.
    event Payout(address payable winner, uint payout);

    constructor(
        uint _biddingTime
    ) public {
        chairperson = msg.sender;
        // todo: block.timestamp
        bidEndTime = block.timestamp + _biddingTime;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    function bid(uint bidValue, uint amount) public payable {
        // The keyword payable
        // is required for the function to
        // be able to receive Ether.

        // Revert the call if the bidding
        // period is over.
        // require(
        //     now <= bidEndTime,
        //     "Auction already ended."
        // );

        bids.push(Bid({
            account: msg.sender,
            bid: bidValue,
            amount: amount
        }));


        // if (highestBid != 0) {
        //     // Sending back the money by simply using
        //     // highestBidder.send(highestBid) is a security risk
        //     // because it could execute an untrusted contract.
        //     // It is always safer to let the recipients
        //     // withdraw their money themselves.
        //     pendingReturns[highestBidder] += highestBid;
        // }
        // highestBidder = msg.sender;
        // highestBid = msg.value;

        //todo: publish event when bidadded...
        // emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// End the betting because the time is up 
    /// to the winner.
    function bettingEnd(uint stockValue) external payable {
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts

        // require(now >= bidEndTime, "Biding Time is not over yet.");
        require(msg.sender==chairperson, "Not the rights to end this contract.");
        require(!ended, "Contract has already ended.");

        // 2. Effects
        ended = true;
        uint payoutsum=0;
        //todo: optimize -> not safe
        uint diff=10000;
        address payable winner;
        for (uint p = 0; p < bids.length; p++) {
            payoutsum = payoutsum + bids[p].amount;
            if(diff>(stockValue-bids[p].bid))
            {
                diff=stockValue-bids[p].bid;
                winner=bids[p].account;
            }
        }

        emit Payout(winner, payoutsum);

        // 3. Interaction
        winner.transfer(payoutsum);
    }

    // Getter/Setter
    function getBidofAccount(address bider) public view returns(uint) {
        for (uint p = 0; p < bids.length; p++) {
            if (bids[p].account == bider){
                return bids[p].bid;
            }
        }
    }
}