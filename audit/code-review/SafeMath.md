# SafeMath

Source file [../../contracts/SafeMath.sol](../../contracts/SafeMath.sol)

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
// BK Ok
library SafeMath {
  // BK Ok
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    // Next 3 Ok
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  // BK Ok
  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // BK Ok
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    // BK Ok
    return c;
  }

  // BK Ok
  function sub(uint256 a, uint256 b) internal returns (uint256) {
    // BK Next 2 Ok
    assert(b <= a);
    return a - b;
  }

  // BK Ok
  function add(uint256 a, uint256 b) internal returns (uint256) {
    // BK Ok
    uint256 c = a + b;
    // BK Next 2 Ok
    assert(c >= a);
    return c;
  }
}
```