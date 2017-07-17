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
* [TODO](#todo)
* [Notes](#notes)
* [Testing](#testing)
* [Crowdsale And Token Contracts Overview](#crowdsale-and-token-contracts-overview)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* **IMPORTANT** There is a potential problem with the controller for the *AIT* contract after the `PreSale.finalize()` function is called.
  In the Status.im crowdsale contracts, the `StatusContribution.finalize()` calls `SNT.changeController(sntController);`, where `sntController`
  is originally set to **SNTPlaceHolder** which has a `changeController(...)` function. 

  For the AIT crowdsale contracts, the *AIT* contract controller is initially set to the **PreSale** contract, and is not updated when
  `PreSale.finalize()` is called. This will result in the *AIT* token contract having an owner (`controller`) that can never be altered.

  * [ ] ACTION Review whether there is a need to reassign the *AIT* contract controller when `PreSale.finalize()` is called.

* **SAFETY IMPROVEMENT** There is no minimum funding goal and no refunds due if a minimum funding goal is not reached. It is far safer 
  therefore to immediately transfer the contributed funds into a multisig, hardware or regular wallet as these are more security tested.

  Currently, contributed ETH is accumulated in the *PreSale* contract. The contract owner (`controller`) has to execute the
  `PreSale.claimTokens(0)` function to transfer any ETH balances from the *PreSale* contract to the owner's account. This
  seems like a half-baked solution, as the contributed ETH should either automatically be transferred into an external wallet (safer),
  or accumulated in the *PreSale* contract and automatically transferred out to an external wallet when the `PreSale.finalize()` function is
  called. The `PreSale.claimTokens(0)` is an emergency function to extract any tokens or ETH accidentally trapped in the crowdsale contract.

  * [ ] ACTION Immediately transfer contributed ETH into a multisig, hardware or regular wallet.

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

* [ ] TODO - Evaluate

<br />

<hr />

## Trustlessness Of The Crowdsale Contract

* From the MiniMeToken comment for the `transferFrom(...)` function:

  > The controller of this contract can move tokens around at will, this is important to recognize! Confirm that you trust the
  > controller of this contract, which in most situations should be another open source smart contract or 0x0

* The MiniMeToken contract `controller` has the ability to burn any accounts token balances using `destroyTokens(...)`.

* The MiniMeToken contract `controller` has the ability to disable and enable any transfers using `enableTransfers(...)`.

<br />

<hr />

## TODO

* [ ] Currently with the PreSale contract being the owner of the MiniMe token contract, transfers can be suspended by the owner. To be
  completely trustless, the owner (`controller`) of the MiniMe token contract will need to be changed to a regular account. But this is seems
  to not be possible with the current set of contracts. See [Recommendations](#recommendations) for further information.

* [ ] Check how the upgrade master can be set if the owner of the MiniMe token contract is the PreSale contract.

<br />

<hr />

## Notes

* Funds can be contributed to the AIT token contract, or the Presale contract.

* The `Presale.investor_bonus = 25` variable is unused. There is no bonus in any calculations in this set of contracts.

* There is no minimum funding goal, and there is no refund mechanism if the non-existent funding goal is not reached.

* There is a `Presale.minimum_investment` variable where contributions below this amount will be rejected.

* There is a `Presale.pauseContribution(...)` function that will allow the contract owner to pause and restart contributions.

* An account may send ETH to `Presale.proxyPayment(...)` with another account as the token holding account. If the send ETH results
  in the tokens generated hitting the cap, an ETH refund will be provided back to the account that sent the ETH, and NOT the token
  holding account. This is the correct behaviour.

* Owner must call `PreSale.claimTokens(0)` to transfer the ETH accumulated in the PreSale contract to the owner's account. Normally this
  function is used to collect stray ETH and ERC20 tokens accidentally sent to the PreSale contract, but in this case, it will be used
  to transfer out the ETH.

* If the `PreSale` contract is the owner (`controller`) of the MiniMe token contract, the MiniMe `transfer(...)`, `transferFrom(...)` and
  `approve(...)` functions will call the `PreSale` contract's `onTransfer(...)` and `onApprove(...)` function to check if transfers
  and approvals are enabled. To enable transfers and approvals, the owner (`controller`) of the `PreSale` contract will have to call
  `allowTransfers(true)`.

* The MiniMeToken contract records the totalSupply and balances in `uint128` data structures. The maximum size of these numbers, with 18 
  decimal places is `new BigNumber("ffffffffffffffffffffffffffffffff", 16).shift(-18)` resulting in `340282366920938463463.374607431768211455`,
  sufficient for most ERC20 tokens.

* The MiniMeToken contract controller CANNOT be set to a multisig contract wallet as all transfers will be disabled.

* The MiniMeToken contract `approve(...)` function has the following comment outlining the steps to change an approval limit

  > To change the approve amount you first have to reduce the addresses` allowance to zero by calling `approve(_spender,0)` if it is not
  > already 0 to mitigate the race condition described here: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

<br />

<hr />

## Testing

See [test/README.md](test/README.md), [test/01_test1.sh](test/01_test1.sh) and [test/test1results.txt](test/test1results.txt).

<br />

<hr />

## Crowdsale And Token Contracts Overview

* [x] This token contract is of moderate complexity
* [x] The code has been tested for the normal [ERC20](https://github.com/ethereum/EIPs/issues/20) use cases
  * [x] Deployment, with correct `symbol()`, `name()`, `decimals()` and `totalSupply()`
  * [ ] `transfer(...)` from one account to another
  * [ ] `approve(...)` and `transferFrom(...)` from one account to another
  * [ ] While the `transfer(...)` and `transferFrom(...)` uses safe maths, there are checks so the function is able to return **true** and **false** instead of throwing an error
* [ ] `transfer(...)` and `transferFrom(...)` is only enabled when the crowdsale is finalised, when either the funds raised matches the cap, or the current time is beyond the crowdsale end date
* [ ] `transferOwnership(...)` has `acceptOwnership()` to prevent errorneous transfers of ownership of the token contract
* [ ] ETH contributed to the crowdsale contract is accumulated in the crowdsale contract. The owner must call `PreSale.claimTokens(0)` to transfer the ETH to the owner (`controller`) of the contract. 
* [ ] ETH cannot be trapped in the token contract as the default `function () payable` is not implemented
* [ ] Check potential division by zero
* [ ] All numbers used are **uint** (which is **uint256**), with the exception of `decimals`, reducing the risk of errors from type conversions
* [ ] Areas with potential overflow errors in `transfer(...)` and `transferFrom(...)` have the logic to prevent overflows
* [ ] Areas with potential underflow errors in `transfer(...)` and `transferFrom(...)` have the logic to prevent underflows
* [ ] Function and event names are differentiated by case - function names begin with a lowercase character and event names begin with an uppercase character
* [ ] The default function will NOT receive contributions during the crowdsale phase and mint tokens. Users have to execute a specific function to contribute to the crowdsale contract
* [ ] The testing has been done using geth v1.6.5-stable-cf87713d/darwin-amd64/go1.8.3 and solc 0.4.11+commit.68ef5810.Darwin.appleclang instead of one of the testing frameworks and JavaScript VMs to simulate the live environment as closely as possible
* [ ] The test scripts can be found in [test/01_test1.sh](test/01_test1.sh)
* [ ] The test results can be found in [test/test1results.txt](test/test1results.txt) for the results and [test/test1output.txt](test/test1output.txt) for the full output
* [ ] There is a switch to pause and then restart the contract being able to receive contributions
* [ ] The [`transfer(...)`](https://github.com/ConsenSys/smart-contract-best-practices#be-aware-of-the-tradeoffs-between-send-transfer-and-callvalue) call is the last statements in the control flow of `investInternal(...)` to prevent the hijacking of the control flow
* [ ] The token contract does not implement the check for the number of bytes sent to functions to reject errors from the [short address attack](http://vessenes.com/the-erc20-short-address-attack-explained/). This technique is now NOT recommended
* [ ] This contract implement a modified `approve(...)` functions to mitigate the risk of [double spending](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#) by requiring the account to set a non-zero approval limit to 0 before modifying this limit

<br />

<hr />

## Code Review

* [x] [AIT.md](code-review/AIT.md)
  * [x] contract AIT is MiniMeToken
* [x] [Migrations.md](code-review/Migrations.md) (Used by [truffle](http://truffle.readthedocs.io/en/beta/getting_started/migrations/)).
  * [x] contract Migrations
* [x] [MiniMeToken.md](code-review/MiniMeToken.md)
  * [x] contract TokenController
  * [x] contract Controlled
  * [x] contract ApproveAndCallFallBack
  * [x] contract MiniMeToken is Controlled
  * [x] contract MiniMeTokenFactory
* [x] [PreSale.md](code-review/PreSale.md)
  * [x] contract PreSale is Controlled, TokenController
    * [x] using SafeMath for uint256
* [x] [SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath

<br />

Outside Scope:

* [MultiSigWallet.md](code-review/MultiSigWallet.md)

  This is the same source code as the ConsenSys [MultiSigWallet.sol](https://github.com/ConsenSys/MultiSigWallet/blob/e3240481928e9d2b57517bd192394172e31da487/contracts/solidity/MultiSigWallet.sol), with the 
  solidity version upgraded from 0.4.4 to 0.4.11.

  This is also the same source code as Status.im's multisig wallet at [0xa646e29877d52b9e2de457eca09c724ff16d0a2b](https://etherscan.io/address/0xa646e29877d52b9e2de457eca09c724ff16d0a2b#code) 
  currently holding 299,902.24 ethers.

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Aigang Network - July 15 2017