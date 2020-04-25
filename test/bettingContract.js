const BettingContract = artifacts.require('./BettingContract.sol')
const assert = require('assert')
const truffleAssert = require('truffle-assertions');

contract('BettingContract_unittest', (accounts) => {
   beforeEach(async () => {
      contractInstance = await BettingContract.deployed()
   })
   it('Constructor test', async () => {
      const accountOne = accounts[0];
      const chairPerson= await contractInstance.chairperson.call();

      assert.equal(accountOne, chairPerson);
   })
   it('Bid function test', async () => {
      await contractInstance.bid(210,10)

      const accountOne = accounts[0];
      const BidValueAcc1= (await contractInstance.getBidofAccount.call(accountOne)).toNumber();

      assert.equal(BidValueAcc1.valueOf(), 210);
   })
   it('Bid function test', async () => {
      await contractInstance.bid(210,20)

      const accountOne = accounts[0];
      const BidValueAcc1= (await contractInstance.getBidofAccount.call(accountOne)).toNumber();

      assert.equal(BidValueAcc1.valueOf(), 210);
   })
   it('Events are published', async () => {
      const number= 2000;
      const accountOne = accounts[0];


      let result= await contractInstance.bettingEnd(number, { from: accountOne });

      // Is event transmitted during execution of bettingEnd
      truffleAssert.eventEmitted(result, 'Payout', (ev) => {
         return ev.winner == accountOne && ev.payout.toNumber() === 30;
      });
   })

   it('Trying to end contract to !chairperson && already ended', async () => {
      const accountZero = accounts[0];
      const accountTwo = accounts[2];
      const number= 2000;

      const chairPerson= await contractInstance.chairperson.call();

      assert.equal(accountZero, chairPerson);

      // let result= await contractInstance.bettingEnd(number, { from: accountTwo });

      await truffleAssert.reverts(
         contractInstance.bettingEnd(number, { from: accountTwo }),
         "Not the rights to end this contract."
     );
   })

   it('Trying to end contract with chairperson, but already ended', async () => {
      const number= 2000;
      const chairPerson= await contractInstance.chairperson.call();

      await truffleAssert.reverts(
         contractInstance.bettingEnd(number, { from: chairPerson }),
         "Contract has already ended."
     );
   })
})
 

contract('BettingContract_integration', (accounts) => {
   beforeEach(async () => {
      contractInstance = await BettingContract.deployed()
   })
   // A bid, B bid 
   it('Usual Workflow', async () => {
      // Constructor (chairperson)
      const accountZero = accounts[0];
      
      const accountOne = accounts[1];
      bidvalue1=100;
      bidsum1=10;

      await contractInstance.bid(bidvalue1, bidsum1, { from: accountOne });

      const accountTwo = accounts[2];
      bidvalue2=200;
      bidsum2=20;

      await contractInstance.bid(bidvalue2, bidsum2, { from: accountTwo });

      let bettingEndCall = await contractInstance.bettingEnd(160, { from: accountZero });
      
      // Is event transmitted during execution of bettingEnd
      truffleAssert.eventEmitted(bettingEndCall, 'Payout', (ev) => {
         return ev.winner == accountOne && ev.payout.toNumber() === (bidsum1+bidsum2);
      });
      
      const chairPerson= await contractInstance.chairperson.call();
      assert.equal(accountZero, chairPerson);
   })

   // Payout -> Sum correct and event gepublished
   // transfered to correct recipient
})
 