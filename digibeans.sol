pragma solidity ^0.4.25 

import "./Ownable.sol";

contract DigiBeans is Ownable {
    
    uint startingBeanPrice = 0.001 ether; //Will increase over time
    uint beanDnaDigits = 4;
    uint beanDnaMod = 10**beanDnaDigits;
    
    uint specialBeanPrice = 1 ether; //Locked at 1 ether
    //A special bean will have the dna 1111, 2222... to 9999
    
    struct DigiBean {
        uint16 dna;
        uint64 creationTime;
        string power;
        bool special;
    }
    
    function withdraw() external onlyOwner {
        address _owner = owner();
        _owner.transfer(address(this).balance);
    }
    
}
