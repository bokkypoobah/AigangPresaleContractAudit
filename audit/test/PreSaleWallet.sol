pragma solidity ^0.4.11;

/*
    Copyright 2017, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title PreSale Contract
/// @author Klaus Hott
/// @dev This contract will be hold the Ether during the presale period.
///  The idea of this contract is to avoid recycling Ether during the presale
///  period. So all the ETH collected will be locked here until the presale
///  period ends

// @dev Contract to hold sale raised funds during the sale period.
// Prevents attack in which the Aragon Multisig sends raised ether
// to the sale contract to mint tokens to itself, and getting the
// funds back immediately.

import "./PreSale.sol";

contract PreSaleWallet {
  // Public variables
  address public multisig;
  uint256 public endBlock;
  PreSale public preSale;

  // @dev Constructor initializes public variables
  // @param _multisig The address of the multisig that will receive the funds
  // @param _endBlock Block after which the multisig can request the funds
  // @param _preSale Address of the StatusContribution contract
  function PreSaleWallet(address _multisig, uint256 _endBlock, address _preSale) {
    require(_multisig != 0x0);
    require(_preSale != 0x0);
    require(_endBlock != 0 && _endBlock <= 4500000);
    multisig = _multisig;
    endBlock = _endBlock;
    preSale = PreSale(_preSale);
  }

  // @dev Receive all sent funds without any further logic
  function () public payable {}

  // @dev Withdraw function sends all the funds to the wallet if conditions are correct
  function withdraw() public {
    require(msg.sender == multisig);        // Only the multisig can request it
    require(block.number > endBlock ||      // Allow after end block
            preSale.finalizedBlock() != 0); // Allow when sale is finalized
    multisig.transfer(this.balance);
  }
}
