pragma solidity  ^0.5.0;
contract CropDamage {
    enum Status {ACTIVE, INACTIVE, CANCLED, REJECTED}
    struct Claim {
        Status status;
        uint premium;
        uint acers;
        string location;
        string reason;
        uint totalClaim;
    }
    struct RegisterFarmer{
        address farmer;
        string name;
        string location;
        uint kisanNumber;
        mapping(address => Claim) claims;
    }
      uint[] keys;
    mapping(uint => RegisterFarmer) public elements;
    address private admin;
    constructor() public {
        admin = msg.sender;
    }
    event claimPolicyStatus(string);
    event CallForRegister(string);
    event RejectUserRegister(string, uint);
    event verifyKissanNumber(uint);
    event sendCropAnyalsis(string, uint, uint);
    function verifyFarmer(uint number) public view returns (address) {
        bool exists = elements[number].farmer != address(0);
            if(exists){
           return elements[number].farmer;
            }else{
                return address(0);
            }
    }
   
    function buyPolicy(uint _kissanNumber, uint _acers, uint _premium, string memory _location) public payable {
        Status stat = elements[_kissanNumber].claims[elements[_kissanNumber].farmer].status; 
        if (stat == Status.INACTIVE) {
            require (msg.value >= _premium);
            RegisterFarmer storage updateClaim = elements[_kissanNumber];
            updateClaim.claims[elements[_kissanNumber].farmer].status = Status.ACTIVE;
            updateClaim.claims[elements[_kissanNumber].farmer].premium = _premium;
            updateClaim.claims[elements[_kissanNumber].farmer].totalClaim += 1;
            updateClaim.claims[elements[_kissanNumber].farmer].acers = _acers;
            updateClaim.claims[elements[_kissanNumber].farmer].location = _location;
            emit claimPolicyStatus('policy activate successfully');
        }else {
            address(msg.sender).transfer(msg.value);
            emit claimPolicyStatus('Not Allowed to buy new policy');
        }
        
    }
    function claimForDamage(uint _kissanNumber, string memory _reason, uint _claimCost) public payable{
        Status stat = elements[_kissanNumber].claims[elements[_kissanNumber].farmer].status; 
        if (stat == Status.ACTIVE) {
            require(address(this).balance >= _claimCost);
            address(uint160(elements[_kissanNumber].farmer)).transfer(_claimCost);
            RegisterFarmer storage updateClaim = elements[_kissanNumber];
            updateClaim.claims[elements[_kissanNumber].farmer].status = Status.INACTIVE;
            updateClaim.claims[elements[_kissanNumber].farmer].reason = _reason;
            emit claimPolicyStatus('farmer claimed success');
        } else {
            
            emit claimPolicyStatus('farmer claimed failed');
        }

    }
    function addUser(string memory _name, string memory _location, uint _kissanNumber) public returns (bool) {
        bool exists = elements[_kissanNumber].farmer != address(0);
          if (!exists) {
             keys.push(_kissanNumber);
          }
            elements[_kissanNumber].name = _name;
            elements[_kissanNumber].location = _location;
            elements[_kissanNumber].kisanNumber = _kissanNumber;
            elements[_kissanNumber].farmer = msg.sender;
            elements[_kissanNumber].claims[msg.sender].status = Status.INACTIVE;
            elements[_kissanNumber].claims[msg.sender].premium = 0;
            elements[_kissanNumber].claims[msg.sender].totalClaim = 0;
            
          return true;
    }
}
