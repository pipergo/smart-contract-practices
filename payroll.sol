pragma solidity ^0.4.14;

contract Payroll {
    uint salary = 1 ether;
    address employee;
    address owner;
    uint payDuration = 30 days;
    uint lastPayday = now;
    
    modifier onlyOwnerOf() {
        require(owner == msg.sender);
        _;
    }
    
    function Payroll() public {
        owner = msg.sender;
    }
    
    function getOwner() public returns (address) {
        return owner;
    }
    
    function setEmployee(address account) public onlyOwnerOf {
        employee = account;
    }
    
    function setSalary(uint amount) public onlyOwnerOf {
        salary = amount;
    }
    
    function addFund() public payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() public returns (uint){
        return this.balance / salary;
    }
    
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public payable {
        require(msg.sender == employee);
        uint nextPayday = lastPayday + payDuration;
        require(nextPayday <= now);
        
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
}