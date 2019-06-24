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

contract DigiSeeds is Ownable {
    
    mapping (uint => address) itemToOwner;
    mapping (address => uint) ownerItemCount;

    event NewSeed(uint id, uint dna);
    event NewPlant(uint id, uint dna);

    uint seedPrice = 1000000000000000; //Will increase over time 0.001
    uint seedDnaDigits = 8;
    uint growSeedPrice = 10000000000000000; //0.01, locked
    uint seedDnaMod = 10**seedDnaDigits;
    uint startTime = now; //will be used as a hack to save space
    uint nonce = 1;

    uint specialSeedPrice = 1000000000000000000; //Locked at 1 ether
    //A special seed will have the dna 0 to 10000, so 1 in 10000 chance of getting special seed
    //by buying a regular seed
    
    struct DigiSeed {
      uint32 dna;
      uint32 cooldownTime;
      bool special;
    }

    struct DigiPlant {
      uint8 level;
      uint8 power;
      uint32 cooldownTime;
      uint32 creationTime;
      uint32 dna;
      bool special;
    }

    DigiSeed[] public digiseeds;
    DigiPlant[] public digiplants;
    
    function _generateRandomDna() private returns (uint32) {
      nonce++;
      return uint32(uint32(keccak256(abi.encodePacked(nonce, now, msg.sender, ownerItemCount[msg.sender], seedPrice))) % seedDnaMod);
    }

    function _generateRandomPower() private returns (uint8) {
      nonce++;
      return uint8(uint8(keccak256(abi.encodePacked(nonce, now, msg.sender, ownerItemCount[msg.sender], seedPrice))) % 256);
    }

    function makeRandomSeed() private {
      uint id = digiseeds.push(DigiSeed(_generateRandomDna(), uint32(now-startTime), uint32(now-startTime), false));
      itemToOwner[id] = msg.sender;
      ownerItemCount[msg.sender]++;
      emit NewSeed(id, digiseeds[id].dna);
    }

    function buyRandomSeed() external payable {
      require(msg.value == seedPrice);
      makeRandomSeed();
    }

    function triggerCooldown(uint _id) internal {
      digiseeds[_id].cooldownTime = uint32(now+1 days);
    }

    function dnaEditor(uint _dna) private returns (uint) {
      return _dna;
    }

    function growSeed(uint _id) external payable {
      require(msg.value == growSeedPrice);
      require(msg.sender == itemToOwner[_id]);
      DigiSeed storage digiseed = digiseeds[_id];
      _plantId = digiplants.push(DigiPlant(1, _generateRandomPower(), uint32(now-startTime), uint32(now-startTime), false));
    }

    function withdraw() external onlyOwner {
        address _owner = owner();
        _owner.transfer(address(this).balance);
    }
    
}
