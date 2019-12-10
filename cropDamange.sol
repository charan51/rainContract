pragma solidity ^0.5.0;
import {Iterator} from './utils.sol';
contract CropDamage {
    address public admin;
    Iterator.Status ClaimStatus;
    Iterator.Data farmValues;
    uint public poolFunds;
    constructor() public payable {
        poolFunds = msg.value;
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
        require(status == Iterator.Status.ACTIVE, "policy already bought or policy inactive!");
        _;
    }
    // events
    event farmerActionStatus(string);
    event farmerActionValue(uint);
    // Verify Farmer details
    function verifyFarmer(uint number) public view returns (address) {
        bool exists = farmValues.farmerList[number].farmerAddress != address(0);
            if(exists){
           return farmValues.farmerList[number].farmerAddress;
            }else{
                return address(0);
            }
    }
    // function 
    function addFarmer(uint _kissanNumber, string memory _name, string memory _location) public onlyFarmer returns(bool) {
        if(_kissanNumber != 0 && bytes(_name).length != 0 && bytes(_location).length != 0) {
        bool exists = farmValues.farmerList[_kissanNumber].farmerAddress != address(0);
        if(!exists) {
            emit farmerActionStatus("Farmer register successfully");
            Iterator.add(farmValues, address(msg.sender), _name, _location, _kissanNumber);
            return true;
        } 
        } else {
              emit farmerActionStatus("Farmer register failed, already registered!!!");
            return false;
        }
    }
    // calulate the policy crop policy
    function calculatePremium(uint _cropPrice, uint _landArea) public pure returns (uint, uint) {
        uint PremiumCost = (uint(60)*uint(_cropPrice)*uint(_landArea))/(uint(100));
        uint totalPremiumCost = (uint(_cropPrice)*uint(_landArea)) - PremiumCost;
        uint totalCoverage =  uint(_cropPrice)*uint(_landArea)+PremiumCost;
        return (totalPremiumCost, totalCoverage);
    }
    // buyPolicy for crop
    function buyPolicy(uint _kissanNumber, uint _cropPrice, uint _landArea, uint _premiumCost, uint _coverageCost, string memory _cropLocaton) public onlyFarmer claimInActive(_kissanNumber) payable {
        if(_kissanNumber != 0 && _cropPrice != 0 && _landArea != 0 && bytes(_cropLocaton).length != 0){
        //require(msg.value == _premiumCost, 'Premium amount paid too less');
        emit farmerActionStatus("Farmer purchased policy successfully");
        farmValues.farmerList[_kissanNumber].premium = _premiumCost;
        farmValues.farmerList[_kissanNumber].coverage = _coverageCost;
        farmValues.farmerList[_kissanNumber].landAcers = _landArea;
        farmValues.farmerList[_kissanNumber].status = Iterator.Status.ACTIVE;
        farmValues.farmerList[_kissanNumber].cropLocation = _cropLocaton;
        } else {
            emit farmerActionStatus("Farmer failed to purchase, payment reverted");
            revert("Policy already activated");
        }
    }
    function getClaimDetails(uint _kissanNumber) public view returns(uint, string memory, uint, Iterator.Status, uint) {
       Iterator.RegisterFarmer memory c = farmValues.farmerList[_kissanNumber];
       return (c.premium, c.location, c.landAcers, c.status, c.coverage);
   } 
    // claim for policy
    function claim_for_damage(uint _kissanNumber, string memory _reason) public onlyFarmer claimActive(_kissanNumber) {
        require(address(farmValues.farmerList[_kissanNumber].farmerAddress) == msg.sender, "Invalid farmer address");
        emit farmerActionStatus("farmer claimed successfully");
        farmValues.farmerList[_kissanNumber].status = Iterator.Status.INACTIVE;
        farmValues.farmerList[_kissanNumber].totalClaim++;
        farmValues.farmerList[_kissanNumber].premium = 0;
        farmValues.farmerList[_kissanNumber].claimReason = _reason;
        address(msg.sender).transfer(farmValues.farmerList[_kissanNumber].coverage);   
    }
}
