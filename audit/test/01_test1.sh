#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`

APTSOL=`grep ^APTSOL= settings.txt | sed "s/^.*=//"`
APTTEMPSOL=`grep ^APTTEMPSOL= settings.txt | sed "s/^.*=//"`
APTJS=`grep ^APTJS= settings.txt | sed "s/^.*=//"`

ERC20SOL=`grep ^ERC20SOL= settings.txt | sed "s/^.*=//"`
ERC20TEMPSOL=`grep ^ERC20TEMPSOL= settings.txt | sed "s/^.*=//"`
ERC20JS=`grep ^ERC20JS= settings.txt | sed "s/^.*=//"`

MIGRATIONSSOL=`grep ^MIGRATIONSSOL= settings.txt | sed "s/^.*=//"`
MIGRATIONSTEMPSOL=`grep ^MIGRATIONSTEMPSOL= settings.txt | sed "s/^.*=//"`
MIGRATIONSJS=`grep ^MIGRATIONSJS= settings.txt | sed "s/^.*=//"`

MINIMETOKENSOL=`grep ^MINIMETOKENSOL= settings.txt | sed "s/^.*=//"`
MINIMETOKENTEMPSOL=`grep ^MINIMETOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
MINIMETOKENJS=`grep ^MINIMETOKENJS= settings.txt | sed "s/^.*=//"`

PLACEHOLDERSOL=`grep ^PLACEHOLDERSOL= settings.txt | sed "s/^.*=//"`
PLACEHOLDERTEMPSOL=`grep ^PLACEHOLDERTEMPSOL= settings.txt | sed "s/^.*=//"`
PLACEHOLDERJS=`grep ^PLACEHOLDERJS= settings.txt | sed "s/^.*=//"`

PRESALESOL=`grep ^PRESALESOL= settings.txt | sed "s/^.*=//"`
PRESALETEMPSOL=`grep ^PRESALETEMPSOL= settings.txt | sed "s/^.*=//"`
PRESALEJS=`grep ^PRESALEJS= settings.txt | sed "s/^.*=//"`

SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHTEMPSOL=`grep ^SAFEMATHTEMPSOL= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+75" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*4" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                 = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT      = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD             = '$PASSWORD'\n" | tee -a $TEST1OUTPUT

printf "CONTRACTSDIR         = '$CONTRACTSDIR'\n" | tee -a $TEST1OUTPUT

printf "APTSOL               = '$APTSOL'\n" | tee -a $TEST1OUTPUT
printf "APTTEMPSOL           = '$APTTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "APTJS                = '$APTJS'\n" | tee -a $TEST1OUTPUT

printf "ERC20SOL             = '$ERC20SOL'\n" | tee -a $TEST1OUTPUT
printf "ERC20TEMPSOL         = '$ERC20TEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "ERC20JS              = '$ERC20JS'\n" | tee -a $TEST1OUTPUT

printf "MIGRATIONSSOL        = '$MIGRATIONSSOL'\n" | tee -a $TEST1OUTPUT
printf "MIGRATIONSTEMPSOL    = '$MIGRATIONSTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "MIGRATIONSJS         = '$MIGRATIONSJS'\n" | tee -a $TEST1OUTPUT

printf "MINIMETOKENSOL       = '$MINIMETOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "MINIMETOKENTEMPSOL   = '$MINIMETOKENTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "MINIMETOKENJS        = '$MINIMETOKENJS'\n" | tee -a $TEST1OUTPUT

printf "PLACEHOLDERSOL       = '$PLACEHOLDERSOL'\n" | tee -a $TEST1OUTPUT
printf "PLACEHOLDERTEMPSOL   = '$PLACEHOLDERTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "PLACEHOLDERJS        = '$PLACEHOLDERJS'\n" | tee -a $TEST1OUTPUT

printf "PRESALESOL           = '$PRESALESOL'\n" | tee -a $TEST1OUTPUT
printf "PRESALETEMPSOL       = '$PRESALETEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "PRESALEJS            = '$PRESALEJS'\n" | tee -a $TEST1OUTPUT

printf "SAFEMATHSOL          = '$SAFEMATHSOL'\n" | tee -a $TEST1OUTPUT
printf "SAFEMATHTEMPSOL      = '$SAFEMATHTEMPSOL'\n" | tee -a $TEST1OUTPUT

printf "DEPLOYMENTDATA       = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS            = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT          = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS         = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME          = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME            = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME              = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $CONTRACTSDIR/$APTSOL $APTTEMPSOL`
`cp $CONTRACTSDIR/$ERC20SOL $ERC20TEMPSOL`
`cp $CONTRACTSDIR/$MIGRATIONSSOL $MIGRATIONSTEMPSOL`
# `cp $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
`cp modifiedContracts/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
`cp $CONTRACTSDIR/$PLACEHOLDERSOL $PLACEHOLDERTEMPSOL`
`cp $CONTRACTSDIR/$PRESALESOL $PRESALETEMPSOL`
`cp $CONTRACTSDIR/$SAFEMATHSOL $SAFEMATHTEMPSOL`

# --- Modify dates ---
#`perl -pi -e "s/startTime \= 1498140000;.*$/startTime = $STARTTIME; \/\/ $STARTTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$APTSOL $APTTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$APTSOL $APTTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$ERC20SOL $ERC20TEMPSOL`
echo "--- Differences $CONTRACTSDIR/$ERC20SOL $ERC20TEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$MIGRATIONSSOL $MIGRATIONSTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$MIGRATIONSSOL $MIGRATIONSTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$PLACEHOLDERSOL $PLACEHOLDERTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$PLACEHOLDERSOL $PLACEHOLDERTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$PRESALESOL $PRESALETEMPSOL`
echo "--- Differences $CONTRACTSDIR/$PRESALESOL $PRESALETEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

echo "var aptOutput=`solc --optimize --combined-json abi,bin,interface $APTTEMPSOL`;" > $APTJS

echo "var migOutput=`solc --optimize --combined-json abi,bin,interface $MIGRATIONSTEMPSOL`;" > $MIGRATIONSJS

echo "var mmOutput=`solc --optimize --combined-json abi,bin,interface $MINIMETOKENSOL`;" > $MINIMETOKENJS

echo "var phOutput=`solc --optimize --combined-json abi,bin,interface $PLACEHOLDERTEMPSOL`;" > $PLACEHOLDERJS

echo "var psOutput=`solc --optimize --combined-json abi,bin,interface $PRESALETEMPSOL`;" > $PRESALEJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$APTJS");
loadScript("$MIGRATIONSJS");
loadScript("$MINIMETOKENJS");
loadScript("$PLACEHOLDERJS");
loadScript("$PRESALEJS");
loadScript("functions.js");

var aptAbi = JSON.parse(aptOutput.contracts["$APTTEMPSOL:APT"].abi);
var aptBin = "0x" + aptOutput.contracts["$APTTEMPSOL:APT"].bin;

var migAbi = JSON.parse(migOutput.contracts["$MIGRATIONSTEMPSOL:Migrations"].abi);
var migBin = "0x" + migOutput.contracts["$MIGRATIONSTEMPSOL:Migrations"].bin;

var mmtfAbi = JSON.parse(mmOutput.contracts["$MINIMETOKENSOL:MiniMeTokenFactory"].abi);
var mmtfBin = "0x" + mmOutput.contracts["$MINIMETOKENSOL:MiniMeTokenFactory"].bin;

var phAbi = JSON.parse(phOutput.contracts["$PLACEHOLDERTEMPSOL:PlaceHolder"].abi);
var phBin = "0x" + phOutput.contracts["$PLACEHOLDERTEMPSOL:PlaceHolder"].bin;

var psAbi = JSON.parse(psOutput.contracts["$PRESALETEMPSOL:PreSale"].abi);
var psBin = "0x" + psOutput.contracts["$PRESALETEMPSOL:PreSale"].bin;

// console.log("DATA: aptAbi=" + JSON.stringify(aptAbi));
// console.log("DATA: migAbi=" + JSON.stringify(migAbi));
// console.log("DATA: mmtfAbi=" + JSON.stringify(mmtfAbi));
// console.log("DATA: phAbi=" + JSON.stringify(phAbi));
// console.log("DATA: psAbi=" + JSON.stringify(psAbi));
// console.log("DATA: psBin=" + psBin);

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
// Deploy MiniMeTokenFactory
// -----------------------------------------------------------------------------
var mmtfMessage = "Deploy MiniMeTokenFactory";
console.log("RESULT: " + mmtfMessage);
var mmtfContract = web3.eth.contract(mmtfAbi);
var mmtfTx = null;
var mmtfAddress = null;
var mmtf = mmtfContract.new({from: contractOwnerAccount, data: mmtfBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mmtfTx = contract.transactionHash;
      } else {
        mmtfAddress = contract.address;
        addAccount(mmtfAddress, "MiniMeTokenFactory");
        printTxData("mmtfAddress=" + mmtfAddress, mmtfTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(mmtfTx, mmtfMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Deploy APT
// -----------------------------------------------------------------------------
var aptMessage = "Deploy APT";
console.log("RESULT: " + aptMessage);
var aptContract = web3.eth.contract(aptAbi);
var aptTx = null;
var aptAddress = null;
var apt = aptContract.new(mmtfAddress, {from: contractOwnerAccount, data: aptBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        aptTx = contract.transactionHash;
      } else {
        aptAddress = contract.address;
        addAccount(aptAddress, "APT");
        addTokenContractAddressAndAbi(aptAddress, aptAbi);
        printTxData("aptAddress=" + aptAddress, aptTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(aptTx, aptMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Deploy PlaceHolder
// -----------------------------------------------------------------------------
var phMessage = "Deploy PlaceHolder";
console.log("RESULT: " + phMessage);
var phContract = web3.eth.contract(phAbi);
var phTx = null;
var phAddress = null;
var ph = phContract.new(aptAddress, {from: contractOwnerAccount, data: phBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        phTx = contract.transactionHash;
      } else {
        phAddress = contract.address;
        addAccount(phAddress, "PlaceHolder");
        addPlaceHolderContractAddressAndAbi(phAddress, phAbi);
        printTxData("phAddress=" + phAddress, phTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(phTx, phMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Deploy PreSale
// -----------------------------------------------------------------------------
var psMessage = "Deploy PreSale";
console.log("RESULT: " + psMessage);
var psContract = web3.eth.contract(psAbi);
var psTx = null;
var psAddress = null;
var ps = psContract.new(aptAddress, phAddress, {from: contractOwnerAccount, data: psBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        psTx = contract.transactionHash;
      } else {
        psAddress = contract.address;
        addAccount(psAddress, "PreSale");
        addCrowdsaleContractAddressAndAbi(psAddress, psAbi);
        printTxData("psAddress=" + psAddress, psTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(psTx, psMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// APT ChangeController To PreSale 
// -----------------------------------------------------------------------------
var aptChangeControllerMessage = "APT ChangeController To PreSale";
console.log("RESULT: " + aptChangeControllerMessage);
var aptChangeControllerTx = apt.changeController(psAddress, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("aptChangeControllerTx", aptChangeControllerTx);
printBalances();
failIfGasEqualsGasUsed(aptChangeControllerTx, aptChangeControllerMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Initialise PreSale 
// -----------------------------------------------------------------------------
var initialisePresaleMessage = "Initialise PreSale";
var maxSupply = "1000000000000000000000000";
// Minimum investment in wei
var minimumInvestment = 10;
var startBlock = parseInt(eth.blockNumber) + 5;
var endBlock = parseInt(eth.blockNumber) + 20;
console.log("RESULT: " + initialisePresaleMessage);
var initialisePresaleTx = ps.initialize(multisig, maxSupply, minimumInvestment, startBlock, endBlock,
  {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initialisePresaleTx", initialisePresaleTx);
printBalances();
failIfGasEqualsGasUsed(initialisePresaleTx, initialisePresaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until startBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= startBlock) {
}
console.log("RESULT: Waited until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account3";
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("87", "ether")});
var validContribution2Tx = eth.sendTransaction({from: account4, to: aptAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message + " ac3->ps 100 ETH");
failIfGasEqualsGasUsed(validContribution2Tx, validContribution1Message + " ac4->apt 10 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 1 ETH From Account3";
console.log("RESULT: " + validContribution2Message);
var validContribution3Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution3Tx", validContribution3Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution3Tx, validContribution2Message + " ac3->ps 1 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution3Message = "Send Valid Contribution - 3 ETH From Account3";
console.log("RESULT: " + validContribution3Message);
var validContribution4Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("3", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution4Tx", validContribution4Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution4Tx, validContribution3Message + " ac3->ps 3 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until endBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= endBlock) {
}
console.log("RESULT: Waited until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Claim ETH 
// -----------------------------------------------------------------------------
var claimEthersMessage = "Claim Ethers";
console.log("RESULT: " + claimEthersMessage);
var claimEthersTx = ps.claimTokens(0, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("claimEthersTx", claimEthersTx);
printBalances();
failIfGasEqualsGasUsed(claimEthersTx, claimEthersMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Finalise PreSale 
// -----------------------------------------------------------------------------
var finalisePresaleMessage = "Finalise PreSale";
console.log("RESULT: " + finalisePresaleMessage);
var finalisePresaleTx = ps.finalize({from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("finalisePresaleTx", finalisePresaleTx);
printBalances();
failIfGasEqualsGasUsed(finalisePresaleTx, finalisePresaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


exit;


var name = "Feed";
var symbol = "FEED";
var initialSupply = 0;
// NOTE: 8 or 18, does not make a difference in the tranches calculations
var decimals = 18;
var mintable = true;

var minimumFundingGoal = new BigNumber(1000).shift(18);
var cap = new BigNumber(2000).shift(18);

#      0 to 15,000 ETH 10,000 FEED = 1 ETH
# 15,000 to 28,000 ETH  9,000 FEED = 1 ETH
var tranches = [ \
  0, new BigNumber(1).shift(18).div(10000), \
  new BigNumber(1500).shift(18), new BigNumber(1).shift(18).div(9000), \
  cap, 0 \
];

var teamMembers = [ team1, team2, team3 ];
var teamBonus = [150, 150, 150];

// -----------------------------------------------------------------------------
var cstMessage = "Deploy CrowdsaleToken Contract";
console.log("RESULT: " + cstMessage);
var cstContract = web3.eth.contract(cstAbi);
console.log(JSON.stringify(cstContract));
var cstTx = null;
var cstAddress = null;

var cst = cstContract.new(name, symbol, initialSupply, decimals, mintable, {from: contractOwnerAccount, data: cstBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        cstTx = contract.transactionHash;
      } else {
        cstAddress = contract.address;
        addAccount(cstAddress, "Token '" + symbol + "' '" + name + "'");
        addTokenContractAddressAndAbi(cstAddress, cstAbi);
        console.log("DATA: teAddress=" + cstAddress);
      }
    }
  }
);


// -----------------------------------------------------------------------------
var etpMessage = "Deploy PricingStrategy Contract";
console.log("RESULT: " + etpMessage);
var etpContract = web3.eth.contract(etpAbi);
console.log(JSON.stringify(etpContract));
var etpTx = null;
var etpAddress = null;

var etp = etpContract.new(tranches, {from: contractOwnerAccount, data: etpBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        etpTx = contract.transactionHash;
      } else {
        etpAddress = contract.address;
        addAccount(etpAddress, "PricingStrategy");
        // addCstContractAddressAndAbi(etpAddress, etpAbi);
        console.log("DATA: etpAddress=" + etpAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("cstAddress=" + cstAddress, cstTx);
printTxData("etpAddress=" + etpAddress, etpTx);
printBalances();
failIfGasEqualsGasUsed(cstTx, cstMessage);
failIfGasEqualsGasUsed(etpTx, etpMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mecMessage = "Deploy MintedEthCappedCrowdsale Contract";
console.log("RESULT: " + mecMessage);
var mecContract = web3.eth.contract(mecAbi);
console.log(JSON.stringify(mecContract));
var mecTx = null;
var mecAddress = null;

var mec = mecContract.new(cstAddress, etpAddress, multisig, $STARTTIME, $ENDTIME, minimumFundingGoal, cap, {from: contractOwnerAccount, data: mecBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mecTx = contract.transactionHash;
      } else {
        mecAddress = contract.address;
        addAccount(mecAddress, "Crowdsale");
        addCrowdsaleContractAddressAndAbi(mecAddress, mecAbi);
        console.log("DATA: mecAddress=" + mecAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("mecAddress=" + mecAddress, mecTx);
printBalances();
failIfGasEqualsGasUsed(mecTx, mecMessage);
printCrowdsaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var bfaMessage = "Deploy BonusFinalizerAgent Contract";
console.log("RESULT: " + bfaMessage);
var bfaContract = web3.eth.contract(bfaAbi);
console.log(JSON.stringify(bfaContract));
var bfaTx = null;
var bfaAddress = null;

var bfa = bfaContract.new(cstAddress, mecAddress, teamBonus, teamMembers, {from: contractOwnerAccount, data: bfaBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        bfaTx = contract.transactionHash;
      } else {
        bfaAddress = contract.address;
        addAccount(bfaAddress, "BonusFinalizerAgent");
        console.log("DATA: bfaAddress=" + bfaAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("bfaAddress=" + bfaAddress, bfaTx);
printBalances();
failIfGasEqualsGasUsed(bfaTx, bfaMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var invalidContribution1Message = "Send Invalid Contribution - 100 ETH From Account6 - Before Crowdsale Start";
console.log("RESULT: " + invalidContribution1Message);
var invalidContribution1Tx = eth.sendTransaction({from: account6, to: mecAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("invalidContribution1Tx", invalidContribution1Tx);
printBalances();
passIfGasEqualsGasUsed(invalidContribution1Tx, invalidContribution1Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var stitchMessage = "Stitch Contracts Together";
console.log("RESULT: " + stitchMessage);
var stitch1Tx = cst.setMintAgent(mecAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch2Tx = cst.setMintAgent(bfaAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch3Tx = cst.setReleaseAgent(bfaAddress, {from: contractOwnerAccount, gas: 400000});
var stitch4Tx = cst.setTransferAgent(mecAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch5Tx = mec.setFinalizeAgent(bfaAddress, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("stitch1Tx", stitch1Tx);
printTxData("stitch2Tx", stitch2Tx);
printTxData("stitch3Tx", stitch3Tx);
printTxData("stitch4Tx", stitch4Tx);
printTxData("stitch5Tx", stitch5Tx);
printBalances();
failIfGasEqualsGasUsed(stitch1Tx, stitchMessage + " 1");
failIfGasEqualsGasUsed(stitch2Tx, stitchMessage + " 2");
failIfGasEqualsGasUsed(stitch3Tx, stitchMessage + " 3");
failIfGasEqualsGasUsed(stitch4Tx, stitchMessage + " 4");
failIfGasEqualsGasUsed(stitch5Tx, stitchMessage + " 5");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startsAtTime = mec.startsAt();
var startsAtTimeDate = new Date(startsAtTime * 1000);
console.log("RESULT: Waiting until startAt date at " + startsAtTime + " " + startsAtTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startsAtTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startsAtTime + " " + startsAtTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account6 - After Crowdsale Start";
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = mec.investWithCustomerId(account6, 123, {from: account6, to: mecAddress, gas: 400000, value: web3.toWei("100", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 1900 ETH From Account7 - After Crowdsale Start";
console.log("RESULT: " + validContribution1Message);
var validContribution2Tx = mec.investWithCustomerId(account7, 124, {from: account7, to: mecAddress, gas: 400000, value: web3.toWei("1900", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution2Tx, validContribution2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finaliseMessage = "Finalise Crowdsale";
console.log("RESULT: " + finaliseMessage);
var finaliseTx = mec.finalize({from: contractOwnerAccount, to: mecAddress, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("finaliseTx", finaliseTx);
printBalances();
failIfGasEqualsGasUsed(finaliseTx, finaliseMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transfersMessage = "Testing token transfers";
console.log("RESULT: " + transfersMessage);
var transfers1Tx = cst.transfer(account8, "1000000000000000000", {from: account6, gas: 100000});
var transfers2Tx = cst.approve(account9,  "2000000000000000000", {from: account7, gas: 100000});
while (txpool.status.pending > 0) {
}
var transfers3Tx = cst.transferFrom(account7, account9, "2000000000000000000", {from: account9, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("transfers1Tx", transfers1Tx);
printTxData("transfers2Tx", transfers2Tx);
printTxData("transfers3Tx", transfers3Tx);
printBalances();
failIfGasEqualsGasUsed(transfers1Tx, transfersMessage + " - transfer 1 token ac6 -> ac8");
failIfGasEqualsGasUsed(transfers2Tx, transfersMessage + " - approve 2 tokens ac7 -> ac9");
failIfGasEqualsGasUsed(transfers3Tx, transfersMessage + " - transferFrom 2 tokens ac7 -> ac9");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var invalidPaymentMessage = "Send invalid payment to token contract";
console.log("RESULT: " + invalidPaymentMessage);
var invalidPaymentTx = eth.sendTransaction({from: account7, to: cstAddress, gas: 400000, value: web3.toWei("123", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("invalidPaymentTx", invalidPaymentTx);
printBalances();
passIfGasEqualsGasUsed(invalidPaymentTx, invalidPaymentMessage);
printTokenContractDetails();
console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
// Wait for crowdsale end
// -----------------------------------------------------------------------------
var endsAtTime = mec.endsAt();
var endsAtTimeDate = new Date(endsAtTime * 1000);
console.log("RESULT: Waiting until startAt date at " + endsAtTime + " " + endsAtTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= endsAtTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + endsAtTime + " " + endsAtTimeDate +
  " currentDate=" + new Date());

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
