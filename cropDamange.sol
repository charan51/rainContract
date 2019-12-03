pragma solidity ^0.5.0;
import {Iterator} from './utils.sol';
contract CropDamagev1 {
    address private admin;
    Iterator.Status ClaimStatus;
    Iterator.Data farmValues;
    constructor() public {
        admin = msg.sender;
    }
    
    // Modifiers 
    modifier onlyAdmin() {
        require(msg.sender == admin, 'Only admin has access');
        _;
    }
    modifier onlyFarmer() {
        require(msg.sender != admin, 'Only Farmer has access');
        _;
    }
    modifier claimInActive(uint _kissanNumber) {
        Iterator.Status status = farmValues.farmerList[_kissanNumber].status;
        require(status == Iterator.Status.INACTIVE, "policy already bought! or Policy is not activate");
        _;
    }
    modifier claimActive(uint _kissanNumber) {
        Iterator.Status status = Iterator.getClaimStatus(farmValues, _kissanNumber);
        require(status == Iterator.Status.ACTIVE, "policy already bought!");
        _;
    }
    // events
    event farmerActionStatus(string);
    
    // function 
    function addFarmer(uint _kissanNumber, string memory _name, string memory _location) public onlyFarmer returns(bool) {
        bool exists = farmValues.farmerList[_kissanNumber].farmerAddress != address(0);
        if(!exists) {
            Iterator.add(farmValues, address(msg.sender), _name, _location, _kissanNumber);
            emit farmerActionStatus("Farmer register successfully");
            return true;
        } else {
            emit farmerActionStatus("Farmer register failed, already registered!!!");
            return false;
        }
    }
    // Buy crop policy
    
    function buyPolicy(uint _kissanNumber, uint _cropPrice, uint _landArea, string memory _cropLocaton) public onlyFarmer claimInActive(_kissanNumber) payable {
        
        if(_kissanNumber != 0 && _cropPrice != 0 && _landArea != 0 && bytes(_cropLocaton).length != 0){
        uint PremiumCost = (uint(6000)/uint(100))*(uint(_cropPrice)*uint(_landArea));
        uint totalPremiumCost = (uint(_cropPrice)*uint(_landArea)) - PremiumCost;
        uint totalCoverage =  uint(_cropPrice)*uint(_landArea);
        require(msg.value == totalPremiumCost, 'Premium amount paid too less');
        farmValues.farmerList[_kissanNumber].premium = totalPremiumCost;
        farmValues.farmerList[_kissanNumber].coverage = totalCoverage;
        farmValues.farmerList[_kissanNumber].landAcers = _landArea;
        farmValues.farmerList[_kissanNumber].status = Iterator.Status.ACTIVE;
        farmValues.farmerList[_kissanNumber].cropLocation = _cropLocaton;
        farmValues.farmerList[_kissanNumber].policyNumber +=1;
        emit farmerActionStatus("Farmer purchased policy successfully");
        } else {
            emit farmerActionStatus("Farmer failed to purchase, payment reverted");
            revert();
        }
    }
    function checkElement(uint _kissanNumber) public view returns(Iterator.Status) {
        return Iterator.getClaimStatus(farmValues, _kissanNumber);
    }
    

}
