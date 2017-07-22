# Aigang Network Presale Contract Audit

This is an audit of [Aigang Network's crowdsale](https://aigang.network/) contracts.

Commit [https://github.com/AigangNetwork/aigang-contracts/commit/6ec3a02f67903fb88fa18af86e5325c967cb26f2](https://github.com/AigangNetwork/aigang-contracts/commit/6ec3a02f67903fb88fa18af86e5325c967cb26f2).

<br />

<hr />

## Table Of Contents

* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Trustlessness Of The Crowdsale Contract](#trustlessness-of-the-crowdsale-contract)
* [Notes](#notes)
* [Testing](#testing)
* [Crowdsale And Token Contracts Overview](#crowdsale-and-token-contracts-overview)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

### First Review
* **IMPORTANT** There is a potential problem with the controller for the *APT* contract after the `PreSale.finalize()` function is called.
  In the Status.im crowdsale contracts, the `StatusContribution.finalize()` function calls `SNT.changeController(sntController);`, where
  `sntController` is originally set to the address of the *SNTPlaceHolder* contract that has a `changeController(...)` function.

  For the *APT* contracts, the *APT* contract controller is initially set to the *PreSale* contract address, and this is not updated when
  `PreSale.finalize()` is called. This will result in the *APT* token contract having an owner (`controller`) that can never be altered.

  * [x] ACTION Review whether there is a need to reassign the *APT* contract controller when `PreSale.finalize()` is called.

    Fixed in second review.

* **SAFETY IMPROVEMENT** There is no minimum funding goal and no refunds due if a minimum funding goal is not reached. It is far safer 
  therefore to immediately transfer the contributed funds into a multisig, hardware or regular wallet as these are more security tested.

  Currently, contributed ETH is accumulated in the *PreSale* contract. The contract owner (`controller`) has to execute the
  `PreSale.claimTokens(0)` function to transfer any ETH balances from the *PreSale* contract to the owner's account. This
  seems like a half-baked solution, as the contributed ETH should either automatically be transferred into an external wallet (safer),
  or accumulated in the *PreSale* contract and automatically transferred out to an external wallet when the `PreSale.finalize()` function is
  called. The `PreSale.claimTokens(0)` is an emergency function to extract any tokens or ETH accidentally trapped in the crowdsale contract.

  * [x] ACTION Alter contribution flow to immediately transfer contributed ETH into a multisig, hardware or regular wallet.

    Fixed in second review.

### Second Review

* **IMPORTANT** There is the ability for the token owner to generate tokens AFTER the PreSale is finalised

  In my testing results [test/test1results.txt](test/test1results.txt]), I generated many tokens after the PreSale was finalised (`crowdsale.finalizedBlock=1550`) :
  
      Finalise PreSale
      finalisePresaleTx gas=2000000 gasUsed=49014 costETH=0.000882252 costUSD=0.181260437904 @ ETH/USD=205.452 gasPrice=18000000000 block=1550 txId=0x003de798fb2a18ba3446bd150420557436953904ddf31f326b9249f2c7dec5f2
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      205.161496450000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.153938106000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976      101.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0      -91.005845212000000000          91.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844      -10.001713132000000000          10.000000000000000000 Account #4
       5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.000000000000000000           0.000000000000000000 Account #5
      ...
      10 0x1aa3ebfd892954f32a37b698673505d1dafef4f5        0.000000000000000000           0.000000000000000000 MiniMeTokenFactory
      11 0xe00ccdd988b1395489290c4c22e85a9c989f40f6        0.000000000000000000           0.000000000000000000 APT
      12 0xf3d9d349146b55cf4e0b622edc71bc4af76b014c        0.000000000000000000           0.000000000000000000 PlaceHolder
      13 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000 PreSale
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                        101.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

      PASS Finalise PreSale
      crowdsaleContractAddress=0xb797d2439cd318684f93de852b4928ea75ae6917
      crowdsale.controller=0xa11aae29840fbb5c86e6fd4cf809eba183aef433
      crowdsale.exchangeRate=1
      crowdsale.investor_bonus=25
      crowdsale.apt=0xe00ccdd988b1395489290c4c22e85a9c989f40f6
      crowdsale.place_holder=0xf3d9d349146b55cf4e0b622edc71bc4af76b014c
      crowdsale.preSaleWallet=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
      crowdsale.totalSupplyCap=1000000
      crowdsale.totalSold=101
      crowdsale.minimum_investment=1e-17
      crowdsale.startBlock=1530
      crowdsale.endBlock=1545
      crowdsale.initializedBlock=1527
      crowdsale.finalizedBlock=1550
      crowdsale.paused=false
      Finalized 0 #1550: {"_now":"1550"}
      placeHolderContractAddress=0xf3d9d349146b55cf4e0b622edc71bc4af76b014c
      placeHolder.controller=0xa11aae29840fbb5c86e6fd4cf809eba183aef433
      placeHolder.transferable=false
      tokenContractAddress=0xe00ccdd988b1395489290c4c22e85a9c989f40f6
      token.controller=0xf3d9d349146b55cf4e0b622edc71bc4af76b014c
      token.symbol=APT
      token.name=Aigang Pre-Launch Token
      token.decimals=18
      token.totalSupply=101
      totalSupplyHistory(0) = 1533 => 97
      totalSupplyHistory(1) = 1535 => 98
      totalSupplyHistory(2) = 1538 => 101
      balanceHistory(0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0, 0) = 1533 => 87
      balanceHistory(0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0, 1) = 1535 => 88
      balanceHistory(0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0, 2) = 1538 => 91
      balanceHistory(0xa44a08d3f6933c69212114bb66e2df1813651844, 0) = 1533 => 10

      Generate Tokens - Should not be possible
      generateTokensTx gas=2000000 gasUsed=94836 costETH=0.001707048 costUSD=0.350716425696 @ ETH/USD=205.452 gasPrice=18000000000 block=1552 txId=0x5cef60a9c31788c724afe3e0629c5f63b150fc492a839013a139c5758cc22cd0
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      215.163203498000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.155645154000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976      101.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0      -91.005845212000000000          91.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844      -10.001713132000000000          10.000000000000000000 Account #4
       5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.000000000000000000  1000000000.000000000000000000 Account #5
      ...
      10 0x1aa3ebfd892954f32a37b698673505d1dafef4f5        0.000000000000000000           0.000000000000000000 MiniMeTokenFactory
      11 0xe00ccdd988b1395489290c4c22e85a9c989f40f6        0.000000000000000000           0.000000000000000000 APT
      12 0xf3d9d349146b55cf4e0b622edc71bc4af76b014c        0.000000000000000000           0.000000000000000000 PlaceHolder
      13 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000 PreSale
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                 1000000101.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

      PASS Generate Tokens - Should not be possible
      crowdsaleContractAddress=0xb797d2439cd318684f93de852b4928ea75ae6917
      crowdsale.controller=0xa11aae29840fbb5c86e6fd4cf809eba183aef433
      crowdsale.exchangeRate=1
      crowdsale.investor_bonus=25
      crowdsale.apt=0xe00ccdd988b1395489290c4c22e85a9c989f40f6
      crowdsale.place_holder=0xf3d9d349146b55cf4e0b622edc71bc4af76b014c
      crowdsale.preSaleWallet=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
      crowdsale.totalSupplyCap=1000000
      crowdsale.totalSold=101
      crowdsale.minimum_investment=1e-17
      crowdsale.startBlock=1530
      crowdsale.endBlock=1545
      crowdsale.initializedBlock=1527
      crowdsale.finalizedBlock=1550
      crowdsale.paused=false
      placeHolderContractAddress=0xf3d9d349146b55cf4e0b622edc71bc4af76b014c
      placeHolder.controller=0xa11aae29840fbb5c86e6fd4cf809eba183aef433
      placeHolder.transferable=false
      tokenContractAddress=0xe00ccdd988b1395489290c4c22e85a9c989f40f6
      token.controller=0xf3d9d349146b55cf4e0b622edc71bc4af76b014c
      token.symbol=APT
      token.name=Aigang Pre-Launch Token
      token.decimals=18
      token.totalSupply=1000000101
      totalSupplyHistory(0) = 1533 => 97
      totalSupplyHistory(1) = 1535 => 98
      totalSupplyHistory(2) = 1538 => 101
      totalSupplyHistory(3) = 1552 => 1000000101
      balanceHistory(0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0, 0) = 1533 => 87
      balanceHistory(0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0, 1) = 1535 => 88
      balanceHistory(0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0, 2) = 1538 => 91
      balanceHistory(0xa44a08d3f6933c69212114bb66e2df1813651844, 0) = 1533 => 10
      Transfer 0 #1552: _from=0x0000000000000000000000000000000000000000 _to=0xa55a151eb00fded1634d27d1127b4be4627079ea _amount=1000000000

  * [ ] ACTION Review whether the token contract owner should have the ability to generate tokens after the PreSale is finalised

* **IMPORTANT** There is the ability for the token contract owner to burn another user's tokens AFTER the PreSale is finalised

  * [ ] ACTION Review whether the token contract owner should have the ability to burn another user's tokens after the PreSale is finalised

<br />

<hr />

## Potential Vulnerabilities

* No potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds contributed to
these contracts is not easily attacked or stolen by third parties. The secondary aim of this audit is that ensure the coded algorithms work
as expected. This audit does not guarantee that that the code is bugfree, but intends to highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Aigang Network's business proposition, the individuals involved in
this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition before funding
any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on the
crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as duplicating
crowdsale websites. Potential participants should NOT just click on any links received through these messages. Scammers have also hacked
the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address matches the
audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* The risk of funds getting stolen or hacked from the *PreSale* contract can be greatly reduced by transferring the contributed funds to
  an external multisig, hardware or regular wallet.

  [x] Fixed in the second review

* This set of contracts have some complexity in the linkages between the separate *APT* (*MiniMeToken*) and *PreSale* contract. The set up
  of the contracts will need to be carefully verified after deployment to confirm that the contracts have been linked correctly.

* **LOW IMPORTANCE** The *APT* (*MiniMeToken*) contract does not have the function to transfer any other ERC20 tokens accidentally sent
  to this contract. The Status.im version of the *MiniMeToken* has the following additional function and event:

      //////////
      // Safety Methods
      //////////
      
          /// @notice This method can be used by the controller to extract mistakenly
          ///  sent tokens to this contract.
          /// @param _token The address of the token contract that you want to recover
          ///  set to 0 in case you want to extract ether.
          function claimTokens(address _token) onlyController {
              if (_token == 0x0) {
                  controller.transfer(this.balance);
                  return;
              }
      
              ERC20Token token = ERC20Token(_token);
              uint balance = token.balanceOf(this);
              token.transfer(controller, balance);
              ClaimedTokens(_token, controller, balance);
          }
      
      ////////////////
      // Events
      ////////////////
      
          event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

  [x] Fixed in the second review

<br />

<hr />

## Trustlessness Of The Crowdsale Contract

### First Review

* From the *MiniMeToken* comment for the `transferFrom(...)` function:

  > The controller of this contract can move tokens around at will, this is important to recognize! Confirm that you trust the
  > controller of this contract, which in most situations should be another open source smart contract or 0x0

* The *APT* (*MiniMeToken*) contract `controller` has the ability to burn any accounts token balances using `destroyTokens(...)`, or to
  disable and enable any transfers using `enableTransfers(...)`. For this contract to be trustless, the *APT* contract `controller` will
  need to be set an account that no one controls like `0x0000000000000000000000000000000000000000`. Setting this `controller` to this
  "burn" address may prevent any future upgrades to this token contract, or the transfer of these presale tokens to the main crowdsale
  contract.

  * [ ] ACTION Review whether the token contract owner should have the ability to burn another user's tokens after the PreSale is finalised
  
### Second Review

* The token contract owner has the ability to burn another user's tokens after the PreSale is finalised (see Recommendation)

  * [ ] ACTION Review whether the token contract owner should have the ability to generate tokens after the PreSale is finalised

<br />

<hr />

## Notes

### First Review
* Funds can be contributed to the APT token contract, or the Presale contract.

* The `Presale.investor_bonus = 25` variable is unused. There is no bonus in any calculations in this set of contracts.

* There is no minimum funding goal, and there is no refund mechanism if the non-existent funding goal is not reached.

* There is a `Presale.minimum_investment` variable where contributions below this amount will be rejected.

* There is a `Presale.pauseContribution(...)` function that will allow the contract owner to pause and restart contributions.

* An account may send ETH to `Presale.proxyPayment(...)` with another account as the token holding account. If the send ETH results
  in the tokens generated hitting the cap, an ETH refund will be provided back to the account that sent the ETH, and NOT the token
  holding account. This is the correct behaviour.

* Owner must call `PreSale.claimTokens(0)` to transfer the ETH accumulated in the *PreSale* contract to the owner's account. Normally this
  function is used to collect stray ETH and ERC20 tokens accidentally sent to the *PreSale* contract, but in this case, it will be used
  to transfer out the ETH.

* If the *PreSale* contract is the owner (`controller`) of the *APT* (*MiniMeToken*) contract, the *APT* `transfer(...)`, 
  `transferFrom(...)` and `approve(...)` functions will call the *PreSale* contract's `onTransfer(...)` and `onApprove(...)` function
  to check if transfers and approvals are enabled. To enable transfers and approvals, the owner (`controller`) of the *PreSale* contract
  will have to call `allowTransfers(true)` after the *PreSale* contract is `finalize()`d.

* The *MiniMeToken* contract records the `totalSupply` and `balances` in `uint128` data structures. The maximum size of these numbers,
  with 18 decimal places is `new BigNumber("ffffffffffffffffffffffffffffffff", 16).shift(-18)` resulting in
  `340282366920938463463.374607431768211455`. This is sufficient for most ERC20 tokens.

* The *MiniMeToken* contract controller **CANNOT** be set to a multisig contract wallet as all transfers will be disabled.

* The *MiniMeToken* contract `approve(...)` function has the following comment outlining the steps to change an approval limit

  > To change the approve amount you first have to reduce the addresses` allowance to zero by calling `approve(_spender,0)` if it is not
  > already 0 to mitigate the race condition described here: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

### Second Review

* The new *MiniMeToken* contract `claimTokens(...)` function does not check the return status of the token `transfer(...)` method.
  In this case it does not matter as the tokens will just not be transferred.

<br />

<hr />

## Testing

See [test/README.md](test/README.md), [test/01_test1.sh](test/01_test1.sh) and [test/test1results.txt](test/test1results.txt).

<br />

<hr />

## Crowdsale And Token Contracts Overview

* [x] This token contract is of moderate complexity.
* [x] The code has been tested for the normal [ERC20](https://github.com/ethereum/EIPs/issues/20) use cases:
  * [x] Deployment, with correct `symbol()`, `name()`, `decimals()` and `totalSupply()`.
  * [ ] `transfer(...)` from one account to another.
  * [ ] `approve(...)` and `transferFrom(...)` from one account to another.
  * [ ] While the `transfer(...)` and `transferFrom(...)` uses safe maths, there are checks so the function is able to return
    **true** and **false** instead of throwing an error.
* [x] `transfer(...)` and `transferFrom(...)` will only be enabled after the *PreSale* contract is `finalize()`d, AFTER the
  `allowTransfers(...)` is called with a `true` parameter.
* [x] `changeController(...)` does NOT have a `acceptController()` to prevent errorneous transfers of ownership of the token contract.
  This may not be appropriate as this function may need to be called from another contract.
* [x] ETH contributed to the crowdsale contract is accumulated in the crowdsale contract. The owner must call `PreSale.claimTokens(0)` to
  transfer the ETH to the owner (`controller`) of the contract. See [Recommendations](#recommendations).
* [x] Any ETH or tokens accidentally sent to the *PreSale* contract can be recovered using the `claimTokens(...)` function.
* [ ] Check potential division by zero.
* [ ] All numbers used are **uint** (which is **uint256**), with the exception of `decimals`, reducing the risk of errors from type
  conversions.
* [ ] Areas with potential overflow errors in `transfer(...)` and `transferFrom(...)` have the logic to prevent overflows.
* [ ] Areas with potential underflow errors in `transfer(...)` and `transferFrom(...)` have the logic to prevent underflows.
* [x] Function and event names are differentiated by case - function names begin with a lowercase character and event names begin 
  with an uppercase character.
* [x] During the crowdsale, ETH can be contributed to the *PreSale* default `function ()` and the `proxyPayment(...)` function. ETH can
  also be contributed to the *APT* (*MiniMeToken*) default `function ()`.
* [x] The testing has been done using geth v1.6.5-stable-cf87713d/darwin-amd64/go1.8.3 and solc 0.4.11+commit.68ef5810.Darwin.appleclang
  instead of one of the testing frameworks and JavaScript VMs to simulate the live environment as closely as possible.
* [x] The test scripts can be found in [test/01_test1.sh](test/01_test1.sh).
* [x] The test results can be found in [test/test1results.txt](test/test1results.txt) for the results and
  [test/test1output.txt](test/test1output.txt) for the full output.
* [x] There is a switch to pause and then restart the contract being able to receive contributions.
* [x] The [`transfer(...)`](https://github.com/ConsenSys/smart-contract-best-practices#be-aware-of-the-tradeoffs-between-send-transfer-and-callvalue)
  call is the last statements in the control flow of `PreSale.claimTokens(...)` to prevent the hijacking of the control flow.
* [X] The token contract does not implement the check for the number of bytes sent to functions to reject errors from the
  [short address attack](http://vessenes.com/the-erc20-short-address-attack-explained/). This technique is now NOT recommended.
* [x] This contract implement a modified `approve(...)` functions to mitigate the risk of 
  [double spending](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#) by requiring the account to set
  a non-zero approval limit to 0 before being to modifying this limit.

<br />

<hr />

## Code Review

* [x] [APT.md](code-review/APT.md)
  * [x] contract APT is MiniMeToken
* [x] [ERC20.md](code-review/ERC20.md)
  * [x] contract ERC20
* [x] [MiniMeToken.md](code-review/MiniMeToken.md)
  * [x] contract TokenController
  * [x] contract Controlled
  * [x] contract ApproveAndCallFallBack
  * [x] contract MiniMeToken is Controlled
  * [x] contract MiniMeTokenFactory
* [x] [PlaceHolder.md](code-review/PlaceHolder.md)
  * [x] contract PlaceHolder is Controlled, TokenController
* [x] [PreSale.md](code-review/PreSale.md)
  * [x] contract PreSale is Controlled, TokenController
    * [x] using SafeMath for uint256
* [x] [SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath

<br />

Outside Scope:

* [x] [Migrations.md](code-review/Migrations.md) (Used by [truffle](http://truffle.readthedocs.io/en/beta/getting_started/migrations/)).
  * [x] contract Migrations
* [MultiSigWallet.md](code-review/MultiSigWallet.md)

  This is the same source code as the ConsenSys [MultiSigWallet.sol](https://github.com/ConsenSys/MultiSigWallet/blob/e3240481928e9d2b57517bd192394172e31da487/contracts/solidity/MultiSigWallet.sol), with the 
  solidity version upgraded from 0.4.4 to 0.4.11.

  This is also the same source code as Status.im's multisig wallet at [0xa646e29877d52b9e2de457eca09c724ff16d0a2b](https://etherscan.io/address/0xa646e29877d52b9e2de457eca09c724ff16d0a2b#code) 
  currently holding 299,902.24 ethers.

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Aigang Network - July 22 2017. The MIT Licence.