pragma solidity >=0.4.22 <0.7.0;

library Iterator {
    enum Status {ACTIVE, INACTIVE, CANCLED, REJECTED}
    struct Claim {
        Status status;
        uint premium;
        uint totalClaim;
    }
    struct RegisterFarmer{
        address farmer;
        string name;
        string location;
        uint kisanNumber;
        mapping(address => Claim) claims;
    }
    struct Data {
        mapping(uint => RegisterFarmer) elements;
        uint[] keys;
    }
       function put(Data storage self, address addr, string memory _name, string memory _location, uint _kissanNumber) public returns (bool) {
          bool exists = self.elements[_kissanNumber].farmer != address(0);
          if (!exists) {
             self.keys.push(_kissanNumber);
          }
            self.elements[_kissanNumber].name = _name;
            self.elements[_kissanNumber].location = _location;
            self.elements[_kissanNumber].kisanNumber = _kissanNumber;
            self.elements[_kissanNumber].farmer = addr;
            self.elements[_kissanNumber].claims[addr].status = Status.INACTIVE;
            self.elements[_kissanNumber].claims[addr].premium = 0;
            self.elements[_kissanNumber].claims[addr].totalClaim = 0;
          return true;
        }
        function getKeyCount(Data storage self) public view returns (uint) {
           return self.keys.length;
        }
        function getElementAtIndex(Data storage self, uint index) public view returns (address) {
           return self.elements[self.keys[index]].farmer;
        }
        function getElement(Data storage self, uint number) public view returns (address) {
           return self.elements[number].farmer;
        }
        function getClaimStatus(Data storage self, uint number) public view returns (Status) {
            return self.elements[number].claims[self.elements[number].farmer].status;
        }
         
}
