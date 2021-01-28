pragma solidity ^0.6.0;

import './HodlToken.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './MockDai.sol';


/*The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies 
the implementation of "user permissions" - OwnershipTransferred,_transferOwnership,fallback,isOwner,onlyOwner,
owner,renounceOwnership,transferOwnership
https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.0.0/contracts/ownership/Ownable.sol.*/

contract HodlFarmTest is Ownable {

    event Staking(bool);

    string public name = 'HodlFarm'; //contract has a name

    //declare state variables to local variables so they can be accessed outside the constructor
    HodlToken public hodlToken; 
    MockDai public daiToken;

    //Array to store the addresses of stakers
    address[] public stakers;
    //Mapping to store startTime, stakingBalance, hodlBalance, and isStaking status for an address
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public hodlBalance;
    mapping(address => bool) public isStaking;

    constructor(HodlToken _hodlToken, MockDai _daiToken) public { //T A
        //instance of smart contract
        hodlToken = _hodlToken;
        daiToken = _daiToken;
    }

    //1. Stakes Token (Deposit)
    function stake(uint256 _amount) public {
        // Require amount greater than 0
        require(_amount > 0, 'You cannot stake zero tokens');

        //approve transaction
        daiToken.approve(address(this), _amount);

        //Trasnfer Mock Dai tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        //Update staking balance, stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        stakingBalance[msg.sender] += _amount;

        //update user status and mark beginning of yield earnings
        isStaking[msg.sender] = true;
        startTime[msg.sender] = block.timestamp;

        //Emit an event
        emit Staking(true);
    }

    //2. Withdraw yield (Interest/Reward - Hodl Token)
    function withdrawYield() public {
        //calling calculateYield function which returns minTime, which we have stored in timeStaked
        uint timeStaked = calculateYield(msg.sender);
        //calculate yield balance (interest/reward)
        uint bal = (stakingBalance[msg.sender] * timeStaked) / 100;

        //reset timestamp
        startTime[msg.sender] = block.timestamp;
        
        //transfer hodl
        hodlToken.transfer(msg.sender, bal);
    }


    //for calculating and fetching
    function calculateYield(address _usr) public view returns(uint){
        //this ll take the timestamp of the block which was mined when we clicked the withdraw/unstake button
        uint end = block.timestamp;
        //calculated the total time [end-start]
        uint totalTime = end - startTime[_usr];
        //convert sec to minutes
        uint minTime = totalTime / 60;
        return minTime;
    }


    //3. Unstaking Dai Token (Withdraw) //**WIthdrawing wat we staked
    function unstake() public {
        //isStaking should be true in order to unstake
        require(isStaking[msg.sender] = true, 'You are not staking tokens');
        
        //map address to hodl balance so yield isn't lost after unstaking
        uint timeStaked = calculateYield(msg.sender);

        //calculate yield balance (interest/reward)
        uint yield = (stakingBalance[msg.sender] * timeStaked) / 100;

        //reset timestamp
        startTime[msg.sender] = block.timestamp;

        //update mapping for Hodl Balance, hodlBalance[msg.sender] = hodlBalance[msg.sender] + yield;
        hodlBalance[msg.sender] += yield;
        

        //start actual unstaking process
        //fetchin staking balance
        uint256 balance = stakingBalance[msg.sender];
        //require amount greater than 0
        require(balance > 0, 'You do not have funds to fetch');
        //**resetting stakingBalance of the investor in HodlFarm, since we havent really sent tokens from here
        stakingBalance[msg.sender] = 0;
        //**Transfer mDai tokens back to the owner, not from the HodlFarm back but issuing them the same amount
        //from daiToken
        daiToken.transfer(msg.sender, balance);

        //update staking status
        isStaking[msg.sender] = false;
        //Emit an event
        emit Staking(false);
    }

}