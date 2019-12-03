pragma solidity >=0.4.22 <0.7.0;

library Iterator {
    enum Status {ACTIVE, INACTIVE}
    struct RegisterFarmer{
        uint kissanNumber;
        address payable farmerAddress;
        string name;
        string location;
        string cropLocation;
        uint policyNumber;
        uint premium;
        uint coverage;
        Status status;
        uint totalClaim;
        string claimReason;
        uint landAcers;
    }
    struct Data {
        mapping(uint => RegisterFarmer) farmerList;
        uint[] keys;
    }
       function add(Data storage self, address payable addr, string memory _name, string memory _location, uint _kissanNumber) public {
            self.farmerList[_kissanNumber].name = _name;
            self.farmerList[_kissanNumber].location = _location;
            self.farmerList[_kissanNumber].kissanNumber = _kissanNumber;
            self.farmerList[_kissanNumber].farmerAddress = addr;
            self.farmerList[_kissanNumber].status = Status.INACTIVE;
            self.farmerList[_kissanNumber].premium = 0;
            self.farmerList[_kissanNumber].totalClaim = 0;
            self.farmerList[_kissanNumber].claimReason = '0';
            self.farmerList[_kissanNumber].landAcers = 0;
            self.farmerList[_kissanNumber].policyNumber = 0;
            self.farmerList[_kissanNumber].coverage = 0;
            self.farmerList[_kissanNumber].cropLocation = '0';
        }
        function getKeyCount(Data storage self) public view returns (uint) {
           return self.keys.length;
        }
        function getElementAtIndex(Data storage self, uint index) public view returns (address) {
           return self.farmerList[self.keys[index]].farmerAddress;
        }
        function getElement(Data storage self, uint number) public view returns (address) {
           return self.farmerList[number].farmerAddress;
        }
        function getClaimStatus(Data storage self, uint number) public view returns (Status) {
            return self.farmerList[number].status;
        }
        function updateElements(Data storage self, uint number) public returns (bool) {
            self.farmerList[number].status  = Status.ACTIVE;
            return true;
        }
         
}
