pragma solidity 0.5.12;
import {Iterator} from './utils.sol';
contract CropDamage {
    address public admin;
    Iterator.Status internal ClaimStatus;
    Iterator.Data internal farmValues;
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
    function verifyFarmer(uint number) external view returns (address) {
        bool exists = farmValues.farmerList[number].farmerAddress == address(0);
        require(exists == true, 'Farmer not register');
        return farmValues.farmerList[number].farmerAddress;
    }
    // to add a new farmer 
    function addFarmer(uint _kissanNumber, string calldata _name, string calldata _location) external onlyFarmer returns(bool) {
        require(_kissanNumber != 0 && bytes(_name).length != 0 && bytes(_location).length != 0, 'Empty fields not accepted');
        bool exists = farmValues.farmerList[_kissanNumber].farmerAddress == address(0);
        require(exists == true, 'Farmer register failed, already registered!!!');
        emit farmerActionStatus("Farmer register successfully");
        Iterator.add(farmValues, msg.sender, _name, _location, _kissanNumber);
        return true;
    }
    // calulate the policy crop policy
    function calculatePremium(uint _cropPrice, uint _landArea) external pure returns (uint, uint) {
        uint PremiumCost = (uint(60)*uint(_cropPrice)*uint(_landArea))/(uint(100));
        uint totalPremiumCost = (uint(_cropPrice)*uint(_landArea)) - PremiumCost;
        uint totalCoverage =  uint(_cropPrice)*uint(_landArea)+PremiumCost;
        return (totalPremiumCost, totalCoverage);
    }
    // buyPolicy for crop
    function buyPolicy(uint _kissanNumber, uint _cropPrice, uint _landArea, uint _premiumCost, uint _coverageCost, string calldata _cropLocaton) external onlyFarmer claimInActive(_kissanNumber) payable {
        require(_kissanNumber != 0 && _cropPrice != 0 && _landArea != 0 && bytes(_cropLocaton).length != 0, 'Empty fields not accepted');
        require(msg.value == _premiumCost, 'Premium amount paid too less');
        emit farmerActionStatus("Farmer purchased policy successfully");
        farmValues.farmerList[_kissanNumber].premium = _premiumCost;
        farmValues.farmerList[_kissanNumber].coverage = _coverageCost;
        farmValues.farmerList[_kissanNumber].landAcers = _landArea;
        farmValues.farmerList[_kissanNumber].status = Iterator.Status.ACTIVE;
        farmValues.farmerList[_kissanNumber].cropLocation = _cropLocaton;
    }
    function getClaimDetails(uint _kissanNumber) external view returns(uint _premium, string memory _location, uint _landAcers, Iterator.Status _status, uint _totalCoverage) {
       Iterator.RegisterFarmer memory c = farmValues.farmerList[_kissanNumber];
       _premium = c.premium;
       _location = c.location;
       _landAcers = c.landAcers;
       _status = c.status;
       _totalCoverage = c.coverage;
       return (_premium, _location, _landAcers, _status, _totalCoverage);
   } 
    // claim for policy
    function claim_for_damage(uint _kissanNumber, string calldata _reason) external onlyFarmer claimActive(_kissanNumber) {
        require(address(farmValues.farmerList[_kissanNumber].farmerAddress) == msg.sender, "Invalid farmer address");
        emit farmerActionStatus("farmer claimed successfully");
        farmValues.farmerList[_kissanNumber].status = Iterator.Status.INACTIVE;
        farmValues.farmerList[_kissanNumber].totalClaim++;
        farmValues.farmerList[_kissanNumber].premium = 0;
        farmValues.farmerList[_kissanNumber].claimReason = _reason;
        address(msg.sender).transfer(farmValues.farmerList[_kissanNumber].coverage);   
    }
}
