// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;

contract MarshyShare {
    // The owner, for refund of extra eth.
    address payable private owner;
    // Current eth locked up in the contract
    int256 balance;
    // The goal of the contract, once this is reached, it will pay out.
    int256 goal;
    // The address the goal should be payed out to.
    address payable payee;
    
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event GoalFulfilled();
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor(int256 toBePayed, address payable _payee) {
        // Set balance to 0
        balance = 0;
        // The owner is the sender and the payee is the _payee argument
        owner = msg.sender;
        payee = _payee;
        // setup goal
        goal = toBePayed;
    }
    
    
    function deposit() public payable {
        // adds to balance and subracts from goal
        balance = balance + int(msg.value);
        goal = goal - int(msg.value);
        
        // If the goal is met
        if(goal <= 0) {
            // Pay the payee
            payee.transfer(uint(goal));
            // Set the new balance
            balance = balance - goal;
            // logging!
            emit GoalFulfilled();
            // transfer extra eth, if the balance is positive (should be)
            if(balance > 0){
                owner.transfer(uint(balance));
            }
        }
    }
    
    // Pretty easy, just get the balance
    function getBalance() public view returns(int256 balance) {return balance;}
    
    // Same as above, but with the current goal
    function getGoal() public view returns(int256 _goal) {return goal;}
    
    // Fallback deposit functions
    fallback() external payable {balance = balance + int(msg.value);}
    
    receive() external payable {balance = balance + int(msg.value);}
}
