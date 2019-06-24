pragma solidity ^0.4.25;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

//TODOs:

//Use SafeMath
//Give beans powers

contract DigiBeans is Ownable {
    
    mapping (uint => address) beanToOwner;
    mapping (address => uint) ownerBeanCount;

    event NewBean(uint id, uint _dna);

    uint startingBeanPrice = 0.001 ether; //Will increase over time
    uint beanDnaDigits = 8;
    uint beanDnaMod = 10**beanDnaDigits;
    uint startTime = now; //will be used as a hack to save space
    uint nonce = 1;

    uint specialBeanPrice = 1 ether; //Locked at 1 ether
    //A special bean will have the dna 0 to 100000, so 1 in 1000 chance of getting special bean
    //by buying a regular bean
    
    struct DigiBean {
        uint8 power;
        uint32 dna;
        uint32 creationTime;
        bool special;
    }

    DigiBean[] public digibeans;
    
    function _generateRandomDna() private view returns (uint) {
      return uint(keccak256(abi.encodePacked(now, msg.sender, ownerBeanCount[msg.sender], startingBeanPrice))) % beanDnaMod;
    }

    function _generateRandomPower() private view returns (uint) {
      return uint(keccak256(abi.encodePacked(now, msg.sender, ownerBeanCount[msg.sender], startingBeanPrice))) % 257;
    }

    function buyRandomBean() external payable {
      require(msg.value == startingBeanPrice);
      uint id = digibeans.push(DigiBean(uint8(_generateRandomPower()), uint32(_generateRandomDna()), uint32(now-startTime), false));
      beanToOwner[id] = msg.sender;
      ownerBeanCount[msg.sender]++;
      emit NewBean(id, digibeans[id].dna);
    }

    function withdraw() external onlyOwner {
        address _owner = owner();
        _owner.transfer(address(this).balance);
    }
    
}
