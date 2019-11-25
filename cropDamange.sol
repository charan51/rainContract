pragma solidity ^0.5.0;
import {Iterator} from './utils.sol';
contract CropDamage {
    Iterator.Status claimState;
    address private admin;
    uint private adminFunds;
    uint private insuranceFunds;
    constructor(uint _funds) public {
        admin = msg.sender;
        insuranceFunds = _funds;
    }
    address public currentUser;
    // library for Iterator mapping
    Iterator.Data knownValues;
   
    // Events List
    event CallForRegister(string);
    event RejectUserRegister(string, uint);
    event verifyKissanNumber(uint);
    event sendCropAnyalsis(string, uint, uint);
    // To check if user exists on the contract
    function checkUser(uint _kissanNumber) public returns(bool) {
        bool exists = Iterator.getElement(knownValues, _kissanNumber) != address(0);
        if(exists) {
            currentUser = Iterator.getElement(knownValues, _kissanNumber);
            return true;
        } else {
            emit CallForRegister("Please register in smartContract");
            return false;
        }
    }
    function verifiyKissanNumberOracle(uint number) public {
         
    }
    function addUser(string memory _name, string memory _location, uint _kissanNumber) public {
        // bool valid = verifiyKissanNumber(_kissanNumber)
        bool valid = true;
        emit verifyKissanNumber(_kissanNumber);
        if(valid) {
        Iterator.put(knownValues, msg.sender, _name, _location, _kissanNumber);
        } else {
            // reject user for invalid kissan Number;
            emit RejectUserRegister('Invalid Kissan Number, Please verifiy with valid number', _kissanNumber);
        }
    }
//   Adverse weather conditions
// Fire
// Insects*
// Plant disease*
// Wildlife
// Earthquake
// Volcanic eruption
// Failure of the irrigation water supply, if applicable, due to an unavoidable cause of loss occurring within the insurance period.
    // Apply for new policy
    function check(uint _number) public returns(Iterator.Status) {
        claimState = Iterator.getClaimStatus(knownValues, _number);
    }
    function applyPolicy(string memory _cropName, uint _cropPrice, uint _landArea, uint _kissanNumber) public returns(Iterator.Status) {
        if(claimState == Iterator.Status.INACTIVE || claimState == Iterator.Status.CANCLED) {
            // Send details to oracle to calculate the crop risk premium
           emit sendCropAnyalsis(_cropName, _cropPrice, _landArea, _kissanNumber);
        }
    }
    
    // Once the oracle confirmed risk as user to pay 
    
    function payForPolicy(uint _kissanNumber, uint _premium) public payable {
        require(msg.value == _premium)
    }
}
