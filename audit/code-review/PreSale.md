# PreSale

Source file [../../contracts/PreSale.sol](../../contracts/PreSale.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 4 Ok
import "./SafeMath.sol";
import "./ERC20.sol";
import "./MiniMeToken.sol";
import "./PreSaleWallet.sol";

contract PreSale is Controlled, TokenController {
  // BK Ok
  using SafeMath for uint256;

  // BK OK - 1 ETH => 1 APT
  uint256 constant public exchangeRate = 1; // ETH-APT exchange rate
  // BK NOTE - This variable is NOT used
  uint256 constant public investor_bonus = 25;

  // BK Ok
  MiniMeToken public apt;
  // BK Ok
  address public place_holder;
  // BK Ok
  address public preSaleWallet;

  // BK Ok - APT token cap, in the natural number, i.e. 1 APT = 1,000,000,000,000,000,000 natural number
  uint256 public totalSupplyCap;            // Total APT supply to be generated
  // BK Ok - In wei
  uint256 public totalSold;                 // How much tokens have been sold

  // BK Ok - This is the minimum contribution per tx, in wei
  uint256 public minimum_investment;

  // BK Next 2 Ok
  uint256 public startBlock;
  uint256 public endBlock;

  // BK Next 2 Ok
  uint256 public initializedBlock;
  uint256 public finalizedBlock;

  // BK Next 2 Ok
  bool public paused;

  // BK Ok
  modifier initialized() {
    // BK Ok
    assert(initializedBlock != 0);
    // BK Ok
    _;
  }

  // BK Ok - Contribution period open between the start and end block and the contracts have been initialised
  modifier contributionOpen() {
    // BK Ok
    assert(getBlockNumber() >= startBlock &&
           getBlockNumber() <= endBlock &&
           finalizedBlock == 0);
    // BK Ok
    _;
  }

  // BK Ok
  modifier notPaused() {
    // BK Ok
    require(!paused);
    // BK Ok
    _;
  }

  // BK Ok - Constructor
  function PreSale(address _apt, address _place_holder) {
    // BK Ok
    require(_apt != 0x0);
    // BK Ok
    require(_place_holder != 0x0);
    // BK Ok - The token contract
    apt = MiniMeToken(_apt);
    // BK Ok
    place_holder = _place_holder;
  }

  // BK Ok - The contracts need to be initialised to link the contracts together
  // BK Ok - Only controller
  function initialize(
      address _preSaleWallet,
      uint256 _totalSupplyCap,
      uint256 _minimum_investment,
      uint256 _startBlock,
      uint256 _endBlock
  ) public onlyController {
    // Initialize only once
    // BK Ok - Can only initialise once
    require(initializedBlock == 0);

    // BK Ok - Start off with 0 total supply
    assert(apt.totalSupply() == 0);
    // BK Ok - The owner of the token contract is this contract
    assert(apt.controller() == address(this));
    // BK Ok - 18 decimal places
    assert(apt.decimals() == 18);  // Same amount of decimals as ETH

    // BK Ok
    require(_preSaleWallet != 0x0);
    // BK Ok
    preSaleWallet = _preSaleWallet;

    // BK Ok - Start block must be in the future
    assert(_startBlock >= getBlockNumber());
    // BK Ok - Start block must be before the end block
    require(_startBlock < _endBlock);
    // BK Next 2 Ok
    startBlock = _startBlock;
    endBlock = _endBlock;

    // BK Ok - Must have a non-zero cap
    require(_totalSupplyCap > 0);
    // BK Ok
    totalSupplyCap = _totalSupplyCap;

    // BK Ok
    minimum_investment = _minimum_investment;

    // BK Ok - Save block number when initialised
    initializedBlock = getBlockNumber();
    // BK Ok - Log initialisation event
    Initialized(initializedBlock);
  }

  /// @notice If anybody sends Ether directly to this contract, consider he is
  /// getting APTs.
  // BK NOTE - Participants can contribute when the contracts are not in `pause` mode
  // BK Ok
  function () public payable notPaused {
    // BK Ok
    proxyPayment(msg.sender);
  }

  //////////
  // TokenController functions
  //////////

  /// @notice This method will generally be called by the APT token contract to
  ///  acquire APTs. Or directly from third parties that want to acquire APTs in
  ///  behalf of a token holder.
  /// @param _th APT holder where the APTs will be minted.
  // BK NOTE - Participants can contribute when the contracts are not in `pause` mode
  //         - This function is only active when these contracts have been initialised
  //         - This function is only active during the contribution period
  // BK Ok
  function proxyPayment(address _th) public payable notPaused initialized contributionOpen returns (bool) {
    // BK Ok - Cannot have 0 address for token balance
    require(_th != 0x0);
    // BK Ok
    doBuy(_th);
    // BK Ok
    return true;
  }

  // BK NOTE - Setting `transferable` to true results in this function returning true
  //         - If this contract is the owner (`controller`) of the MiniMeToken token contract, `onTransfer(...)`
  //           will be called to check if `transfer(...)` and `transferFrom(...)` are enabled
  // BK Ok
  function onTransfer(address, address, uint256) public returns (bool) {
    // BK Ok
    return false;
  }

  // BK NOTE - Setting `transferable` to true results in this function returning true
  //         - If this contract is the owner (`controller`) of the MiniMeToken token contract, `onApprove(...)`
  //           will be called to check if `approve(...)` is enabled
  // BK Ok
  function onApprove(address, address, uint256) public returns (bool) {
    // BK Ok
    return false;
  }

  // BK Ok
  function doBuy(address _th) internal {
    // BK Ok
    require(msg.value >= minimum_investment);

    // Antispam mechanism
    address caller;
    // BK Ok - Contributions may be sent to the token contract and it will be diverted here for the calculations
    if (msg.sender == address(apt)) {
      // BK Ok
      caller = _th;
    } else {
      // BK Ok. If called through `proxyPayment(...)` where the ETH funding account is different to the token holding account, this is the ETH funding account
      caller = msg.sender;
    }
    // BK Ok - Making sure that the originating address for the contribution is NOT a contract
    assert(!isContract(caller));

    // BK Ok - Original ETH value for token purchase
    uint256 toFund = msg.value;
    // BK Ok - Amount of tokens left for sale before hitting the cap
    uint256 leftForSale = tokensForSale();
    // BK Ok - Non-zero ETH value sent for token purchase
    if (toFund > 0) {
      // BK Ok - There are tokens left to be sold
      if (leftForSale > 0) {
        // BK Ok - Calculate the number of tokens for the ETH payment
        uint256 tokensGenerated = toFund.mul(exchangeRate);

        // Check total supply cap reached, sell the all remaining tokens
        // BK Ok - If number of tokens bought is more than the remaining that can be bought
        if (tokensGenerated > leftForSale) {
          // BK Ok - Only allow the remaining tokens to be bought 
          tokensGenerated = leftForSale;
          // BK Ok - And calculate the ETH refund
          toFund = leftForSale.div(exchangeRate);
        }

        // BK Ok - Call the token contract to generate the tokens and assign it to the token account
        assert(apt.generateTokens(_th, tokensGenerated));
        // BK Ok - Keep a tally of the tokens generated
        totalSold = totalSold.add(tokensGenerated);

        // BK Ok - Send funds immediately to the wallet
        preSaleWallet.transfer(toFund);
        // BK Ok - Log the number of tokens generated
        NewSale(_th, toFund, tokensGenerated);
      } else {
        // BK Ok - No tokens left for sale. Refund the whole amount
        toFund = 0;
      }
    }

    // BK Ok - Calculate refunds
    uint256 toReturn = msg.value.sub(toFund);
    // BK Ok - Send refund back to the originating ETH account 
    if (toReturn > 0) {
      // BK Ok
      caller.transfer(toReturn);
    }
  }

  /// @dev Internal function to determine if an address is a contract
  /// @param _addr The address being queried
  /// @return True if `_addr` is a contract
  // BK Ok
  function isContract(address _addr) constant internal returns (bool) {
    // BK Ok
    if (_addr == 0) return false;
    // BK Ok
    uint256 size;
    // BK Next 3 Ok
    assembly {
      size := extcodesize(_addr)
    }
    // BK Ok
    return (size > 0);
  }

  /// @notice This method will can be called by the controller before the contribution period
  ///  end or by anybody after the `endBlock`. This method finalizes the contribution period
  ///  by creating the remaining tokens and transferring the controller to the configured
  ///  controller.
  // BK NOTE - Can only finalised after the contracts have been initialised
  function finalize() public initialized {
    // BK Ok - Cannot finalised more than once
    require(finalizedBlock == 0);
    // BK Ok - Cannot finalise before the start
    assert(getBlockNumber() >= startBlock);
    // BK NOTE - Finalisation can be executed:
    //           - By the owner at any time after the start
    //           - By anyone after the end of the crowdsale
    //           - By anyone if the cap has been reached
    // BK Ok
    assert(msg.sender == controller || getBlockNumber() > endBlock || tokensForSale() == 0);

    // BK Ok - Change token contracts contoller to the place holder
    apt.changeController(place_holder);

    // BK Ok - Store the block number when these contracts where finalised 
    finalizedBlock = getBlockNumber();

    // BK Ok - Log finalisation event
    Finalized(finalizedBlock);
  }

  //////////
  // Constant functions
  //////////

  /// @return Total tokens availale for the sale in weis.
  // BK Ok
  function tokensForSale() public constant returns(uint256) {
    // BK NOTE - If tokens sold is less than the cap, return the difference
    //         - Otherwise return 0
    // BK Ok
    return totalSupplyCap > totalSold ? totalSupplyCap - totalSold : 0;
  }

  //////////
  // Testing specific methods
  //////////

  /// @notice This function is overridden by the test Mocks.
  // BK Ok
  function getBlockNumber() internal constant returns (uint256) {
    // BK Ok
    return block.number;
  }


  //////////
  // Safety Methods
  //////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  // BK NOTE - This function WILL NEED to be used by the owner to extract the ETH raised in this presale
  //         - Normally this function would be only used to collect stray ETH or ERC20 tokens
  // BK Ok - Only the contract owner can execute this function
  function claimTokens(address _token) public onlyController {
    // BK Ok
    if (apt.controller() == address(this)) {
      // BK Ok
      apt.claimTokens(_token);
    }

    // BK Ok - No token address specified, withdraw ETH from the contract 
    if (_token == 0x0) {
      // BK Ok - Transfer ETH balance to the owner's account
      controller.transfer(this.balance);
      // BK NOTE - No events logged for this
      return;
    }

    // BK Ok - Using ERC20 functions only
    ERC20 token = ERC20(_token);
    // BK Ok - Get the balance of the ERC20 token
    uint256 balance = token.balanceOf(this);
    // BK NOTE - Should check for status, but no side effects other than the tokens not being transferred
    token.transfer(controller, balance);
    // BK Ok - Log event
    ClaimedTokens(_token, controller, balance);
  }

  /// @notice Pauses the contribution if there is any issue
  // BK Ok
  function pauseContribution(bool _paused) onlyController {
    // BK Ok
    paused = _paused;
  }

  // BK Next 4 Ok
  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event NewSale(address indexed _th, uint256 _amount, uint256 _tokens);
  event Initialized(uint _now);
  event Finalized(uint _now);
}
```