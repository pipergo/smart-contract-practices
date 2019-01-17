pragma solidity ^0.4.14;

contract AdvancedPayroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }


    uint constant payDuration = 30 days;
    address owner;
    // using mapping instead
    mapping(address => Employee) employees;

    uint totalSalary;
    
    modifier onlyOwnerOf() {
        require(owner == msg.sender);
        _;
    }
    
    function AdvancedPayroll() public {
        owner = msg.sender;
    }
    
    function getOwner() public returns (address) {
        return owner;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) public onlyOwnerOf {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);

        totalSalary += salary;

        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
    }

    function removeEmployee(address employeeId) public onlyOwnerOf {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);

        _partialPaid(employee);

        totalSalary -= employee.salary;

        delete employees[employeeId];    // delete will initiate the variable.
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwnerOf {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);

        _partialPaid(employee);
        totalSalary -= employee.salary;
        employees[employeeId].salary = salary * 1 ether;   // the parameter is in ether unit for convenient;
        totalSalary += employees[employeeId].salary;
        employees[employeeId].lastPayday = now;
    }
    
    function addFund() public payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() public returns (uint){
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public {
        var employee = employees[msg.sender];
        assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        require(nextPayday <= now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
}
