pragma solidity ^0.6.0;

import './HodlToken.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

    /*Interfaces are similar to abstract contracts and are created using interface keyword. It is used for
    standardization of code*/
interface DaiToken {
        function transfer(address dst, uint wad) external returns (bool);
        function transferFrom(address from, address to, uint wad) external returns (bool);
        function balanceOf(address user) external view returns (uint);
        function approve(address _spender, uint256 _value) external returns (bool);
        }

contract HodlFarm is Ownable {
    /*The Ownable contract has an owner address, and provides basic authorization control functions, this 
    simplifies the implementation of "user permissions" - OwnershipTransferred,_transferOwnership,fallback,
    isOwner,onlyOwner,owner,renounceOwnership,transferOwnership
    https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.0.0/contracts/ownership/Ownable.sol.*/
    using SafeMath for uint256;
    /*Arithmetic operations in Solidity wrap on overflow. This can easily result in bugs, because programmers 
    usually assume that an overflow raises an error, which is the standard behavior in high level programming 
    languages. SafeMath restores this intuition by reverting the transaction when an operation overflows.
    Using this library instead of the unchecked operations eliminates an entire class of bugs, 
    so it’s recommended to use it always. 
    Functions - add(a, b),sub(a, b),sub(a, b, errorMessage),mul(a, b),div(a, b),
    div(a, b, errorMessage),mod(a, b),mod(a, b, errorMessage)*/


    string public name = 'HodlFarm'; //contract has a name

    //declare state variables to local variables so they can be accessed outside the constructor
    HodlToken public hodlToken;
    DaiToken public daiToken;

    //Array to store the addresses of stakers
    address[] public stakers;

    //Mapping to store startTime, stakingBalance, hodlBalance, and isStaking status for an address
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public hodlBalance;
    mapping(address => bool) public isStaking;

    constructor(HodlToken _hodlToken, DaiToken _daiToken) public {
        //instance of smart contract
        hodlToken = _hodlToken;
        daiToken = _daiToken;
    }

    /*
    A function that stakes stablecoin Dai to the contract.
    After Dai transfers to the contract, the mapped staking balance updates. 
    This is necessary because the contract only pays out when the user withdraws 
    their earnings. The mapping keeps track of said yield.
    */
    //Stakes Token (Deposit)
    function stake(uint256 _amount) public {
        // Require amount greater than 0
        require(_amount > 0, 'You cannot stake zero tokens');
         //approve transaction in interface
         //Trasnfer Mock Dai tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);
        //Update staking balance using safeMath, stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        stakingBalance[msg.sender] = SafeMath.add(stakingBalance[msg.sender], _amount);
        //update user status and mark beginning of yield earnings
        isStaking[msg.sender] = true;
        startTime[msg.sender] = block.timestamp;
    }

    /*A method for withdrawing the hodlToken yield.
    The timeStaked uint takes the result of the calculateYield function. 
    This contract gives the user 1% of their Dai balance in HodlToken every 60 
    seconds. After fetching the the calculated balance, the contract checks for 
    an existing balance mapped to hodlBalance. This mapping is only relevant if 
    the user staked Dai multiple times without unstaking/withdrawing. Further, the
    staking balance of the user is first multiplied by the time staked before
    divided by 100 to equate 1% of the user's stake (per minute as seen in the
    calculateYield function).
    */
    //2. Withdraw yield (Interest/Reward - Hodl Token)
    function withdrawYield() public {
        //Require amount greater than 0 or start time must not be equal to end time
        require(hodlBalance[msg.sender] > 0 || startTime[msg.sender] != block.timestamp);
        //calling calculateYield function which returns minTime, which we have stored in timeStaked
        uint timeStaked = calculateYieldTime(msg.sender);
        //calculate yield balance using safeMath (interest/reward)
        uint bal = SafeMath.div(SafeMath.mul(stakingBalance[msg.sender], timeStaked), 100);
        //adding old interest with new interest that generated
        if(hodlBalance[msg.sender] != 0){
            uint oldBal = hodlBalance[msg.sender];
            hodlBalance[msg.sender] = 0;
            bal = SafeMath.add(bal, oldBal);
        }
        //reset timestamp
        startTime[msg.sender] = block.timestamp;
        //transfer hodl
        hodlToken.transfer(msg.sender, bal);
    }


    /*A method for calculating yield time.
    The yield is calculated by first subtracting the initial timestamp by the current 
    timestamp. Thereafter, dividing 60 (as in 60 seconds per minute) by the timestamp 
    difference. This function is left public so the frontend can fetch and display the 
    user's yield in real time..
    */
    function calculateYieldTime(address _usr) public view returns(uint){
        //this ll take the timestamp of the block which was mined when we clicked the withdraw/unstake button
        uint end = block.timestamp;
        //calculated the total time [end-start]
        uint totalTime = SafeMath.sub(end, startTime[_usr]);
        //convert sec to minutes
        uint inMinutes = SafeMath.div(totalTime, 60);
        return inMinutes;
    }


    /*A method for users to take back their tokens from the contract.
    The timeStaked uint gathers the yield time. The staked time(in minutes) is 
    mulitplied by the staking balance and divided by 100 (1% every minute). The 
    contract resets the timestamp to prevent reentry. Thereafter, the previously saved 
    yield balance (if applicable) is added to the current yield figure. Finally, the actual 
    transfer of Dai back to the user occurs.
    */
    //3. Unstaking Dai Token (Withdraw) //**WIthdrawing wat we staked
    function unstake() public {
        //isStaking should be true in order to unstake
        require(isStaking[msg.sender] = true, 'You are not staking tokens');
        //map address to hodl balance so yield isn't lost after unstaking
        uint timeStaked = calculateYieldTime(msg.sender);
        //calculate yield balance using safeMath (interest/reward)
        uint yield = SafeMath.div(SafeMath.mul(stakingBalance[msg.sender], timeStaked), 100);
        //reset timestamp
        startTime[msg.sender] = block.timestamp;
        //update mapping for Hodl Balance using safeMath, hodlBalance[msg.sender] = hodlBalance[msg.sender] + yield;
        hodlBalance[msg.sender] = SafeMath.add(hodlBalance[msg.sender], yield);
        
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
    }

}