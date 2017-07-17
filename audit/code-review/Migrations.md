# Migrations

Source file [../../contracts/Migrations.sol](../../contracts/Migrations.sol).

This contract is used by [truffle](http://truffle.readthedocs.io/en/beta/getting_started/migrations/), and is not referenced by the [AIT](AIT.md), [MiniMeToken](MiniMeToken.md), [MultiSigWallet](MultiSigWallet.md), [PreSale](PreSale.md) or [SafeMath](SafeMath.md) contracts.

<br />

<hr />

```javascript
// BK NOTE - Should be 0.4.11, but used in the truffles testing framework
pragma solidity ^0.4.4;

contract Migrations {
  // BK Ok
  address public owner;
  // BK Ok
  uint public last_completed_migration;

  // BK Ok - Does not throw
  modifier restricted() {
    if (msg.sender == owner) _;
  }

  // BK Ok
  function Migrations() {
    owner = msg.sender;
  }

  // BK Ok
  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  // BK Ok
  function upgrade(address new_address) restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
```