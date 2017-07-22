# PlaceHolder

Source file [../../contracts/PlaceHolder.sol](../../contracts/PlaceHolder.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
import "./MiniMeToken.sol";

contract PlaceHolder is Controlled, TokenController {
  // BK Ok
  bool public transferable;
  // BK Ok
  MiniMeToken apt;

  // BK Ok
  function PlaceHolder(address _apt) {
    // BK Ok
    apt = MiniMeToken(_apt);
  }

  /// @notice Called when `_owner` sends ether to the MiniMe Token contract
  /// @return True if the ether is accepted, false if it throws
  // BK Ok
  function proxyPayment(address) payable returns (bool) {
    // BK Ok
    return false;
  }

  /// @notice Notifies the controller about a token transfer allowing the
  ///  controller to react if desired
  /// @return False if the controller does not authorize the transfer
  // BK Ok
  function onTransfer(address, address, uint256) returns (bool) {
    // BK Ok
    return transferable;
  }

  /// @notice Notifies the controller about an approval allowing the
  ///  controller to react if desired
  /// @return False if the controller does not authorize the approval
  // BK Ok
  function onApprove(address, address, uint) returns (bool) {
    // BK Ok
    return transferable;
  }

  // BK Ok - Only controller
  function allowTransfers(bool _transferable) onlyController {
    // BK Ok
    transferable = _transferable;
  }

  /// @notice Generates `_amount` tokens that are assigned to `_owner`
  /// @param _owner The address that will be assigned the new tokens
  /// @param _amount The quantity of tokens generated
  /// @return True if the tokens are generated correctly
  // BK Ok - Only controller
  function generateTokens(address _owner, uint _amount
  ) onlyController returns (bool) {
    // BK Ok
    return apt.generateTokens(_owner, _amount);
  }

  /// @notice The owner of this contract can change the controller of the APT token
  ///  Please, be sure that the owner is a trusted agent or 0x0 address.
  /// @param _newController The address of the new controller
  // BK Ok - Only controller
  function changeAPTController(address _newController) public onlyController {
    // BK Ok
    apt.changeController(_newController);
  }

  //////////
  // Safety Methods
  //////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  // BK Ok - Only controller
  function claimTokens(address _token) public onlyController {
    // BK Ok - If this is the token contract's controller, send the instruction to the token contract
    if (apt.controller() == address(this)) {
      // BK Ok
      apt.claimTokens(_token);
    }

    // BK Ok - Claiming ETH
    if (_token == 0x0) {
      // BK Ok - Move ETH to controller account
      controller.transfer(this.balance);
      // BK Ok
      return;
    }

    // BK Ok
    ERC20 token = ERC20(_token);
    // BK Ok - Current balance
    uint256 balance = token.balanceOf(this);
    // BK Ok - Move tokens to controller account
    token.transfer(controller, balance);
    // BK Ok - Log event
    ClaimedTokens(_token, controller, balance);
  }

  // BK Ok
  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
}

```
