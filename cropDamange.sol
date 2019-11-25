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
    event verifyKissanNumber(uint);
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
            // reject();
        }
    }
   
    // Apply for new policy
    function check(uint _number) public returns(Iterator.Status) {
        claimState = Iterator.getClaimStatus(knownValues, _number);
    }
    function applyPolicy() public view returns(Iterator.Status) {
       
       
        if(claimState == Iterator.Status.INACTIVE) {
            return claimState;
        }
       
    }
}
