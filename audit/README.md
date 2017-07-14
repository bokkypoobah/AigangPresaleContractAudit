# Aigang Network Presale Contract Audit

This is an audit of [Aigang Network's crowdsale](https://aigang.network/) contracts.


Commit [https://github.com/AigangNetwork/aigang-contracts/commit/6ec3a02f67903fb88fa18af86e5325c967cb26f2](https://github.com/AigangNetwork/aigang-contracts/commit/6ec3a02f67903fb88fa18af86e5325c967cb26f2).

<br />

<hr />

## Table Of Contents

* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Trustlessness Of The Crowdsale Contract](#trustlessness-of-the-crowdsale-contract)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Notes](#notes)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds contributed to these contracts are not easily attacked or stolen by third parties. 
The secondary aim of this audit is that ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to highlight any areas of
weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Aigang Network's business proposition, the individuals involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition before funding the crowdsale.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on Aigang Network's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as duplicating crowdsale websites.
Potential participants should NOT just click on any links received through these messages.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address matches the audited source code, and that 
the deployment parameters are correctly set, including the constant parameters.

* [ ] TODO - Any further issues

<br />

<hr />

## Risks

* [ ] TODO - Evaluate

<br />

<hr />

## Trustlessness Of The Crowdsale Contract

* [ ] TODO - Evaluate

<br />

<hr />

## Potential Vulnerabilities

* [ ] TODO - Confirm that no potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Notes

* Funds can be contributed to the AIT token contract, or the Presale contract.

* The `Presale.investor_bonus = 25` variable is unused. There is no bonus in any calculations in this set of contracts.

* There is no minimum funding goal, and there is no refund mechanism if the non-existent funding goal is not reached.

* TODO - Check this again - Presale balances cannot be transferred to another account.

* There is a `Presale.minimum_investment` variable where contributions below this amount will be rejected.

* There is a `Presale.pauseContribution(...)` function that will allow the contract owner to pause and restart contributions.

* An account may send ETH to `Presale.proxyPayment(...)` with another account as the token holding account. If the send ETH results
  in the tokens generated hitting the cap, an ETH refund will be provided back to the account that sent the ETH, and NOT the token
  holding account. This is the correct behaviour.

* Owner must call `PreSale.claimTokens(0)` to transfer the ETH accumulated in the PreSale contract to the owner's account. Normally this
  function is used to collect stray ETH and ERC20 tokens accidentally sent to the PreSale contract, but in this case, it will be used
  to transfer out the ETH.

* TODO - Check this again - Owner must call `PreSale.allowTransfers(true)` to allow the tokens to be transferred.  

<br />

<hr />

## Testing

See [test/README.md](test/README.md), [test/01_test1.sh](test/01_test1.sh) and [test/test1results.txt](test/test1results.txt).

<br />

<hr />

## Code Review

* [AIT.md](code-review/AIT.md)
  * contract AIT is MiniMeToken
* [Migrations.md](code-review/Migrations.md)
  * contract Migrations
* [MiniMeToken.md](code-review/MiniMeToken.md)
  * contract TokenController
  * contract Controlled
  * contract ApproveAndCallFallBack
  * contract MiniMeToken is Controlled
  * contract MiniMeTokenFactory
* [PreSale.md](code-review/PreSale.md)
  * contract PreSale is Controlled, TokenController
    * using SafeMath for uint256
* [SafeMath.md](code-review/SafeMath.md)
  * library SafeMath

<br />

Outside Scope:

* [MultiSigWallet.md](code-review/MultiSigWallet.md)

  This is the same source code as the ConsenSys [MultiSigWallet.sol](https://github.com/ConsenSys/MultiSigWallet/blob/e3240481928e9d2b57517bd192394172e31da487/contracts/solidity/MultiSigWallet.sol), with the 
  solidity version upgraded from 0.4.4 to 0.4.11.

  This is also the same source code as Status.im's multisig wallet at [0xa646e29877d52b9e2de457eca09c724ff16d0a2b](https://etherscan.io/address/0xa646e29877d52b9e2de457eca09c724ff16d0a2b#code) 
  currently holding 299,902.24 ethers.