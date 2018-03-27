pragma solidity ^0.4.14;
contract SplitFund{
    
    mapping (address => uint) paidForTheGas;
    
    struct shareHodler{
        address wallet;
        uint percentage;
    }
    uint gaswithHold = 0;
    mapping(address => shareHodler) shareBook;
    uint totalPercentage = 0;
    address _owner = 0x0;
    address [] addressList;
    
    modifier _onlyOwner(){
        require(msg.sender == _owner);    
        _;
    }
    
    modifier _gasCredit(){
        uint gasInitial = gasleft();
        _;
        uint gasUsed = gasInitial - gasleft() + 30000;
        uint gasCost = gasUsed * tx.gasprice;
        paidForTheGas[msg.sender] += gasCost;
        gaswithHold += gasCost;
    }
    bool mutex = false;
    modifier _isMutexed(){
        require(!mutex);
        mutex = true;
        _;
        mutex = false;
        return;
    }
    
    event newFund(
        uint  balance
    );
    
    function addPeople(address wallet, uint percentage)  _onlyOwner _gasCredit  public{
        shareHodler storage p = shareBook[wallet];
        require(p.wallet == 0x0);
        require(totalPercentage + percentage <= 100);
        shareBook[wallet] = shareHodler(wallet, percentage);
        totalPercentage += percentage;
        addressList.push(wallet);
    }
    
    function SplitFund() public{
        _owner = msg.sender;
    }
    
    function () payable public{}
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function withdraw() _isMutexed _gasCredit public{
        require(address(this).balance - gaswithHold > 0);
        uint splitPayForeach = (address(this).balance - gaswithHold) / 100;
        gaswithHold = 0;
        uint addressLen = addressList.length;
        for(uint i = 0 ; i < addressLen ; i++){
            address tmp = addressList[i];
            shareHodler storage tHolder = shareBook[tmp];
            tmp.transfer(tHolder.percentage * splitPayForeach + paidForTheGas[tmp]);
            paidForTheGas[tmp] = 0;
        }
    }
}
