pragma solidity ^0.4.14;

contract AdvancedPayroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }


    uint constant payDuration = 30 days;
    address owner;
    Employee[] employees;
    
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

    // Fixme: employees是一个 storage 存储的变量，返回的变量不指定的情况下是 memory 存储类型，
    // 因此返回时会将内容进行一份拷贝而不是拷贝存储地址。如果在调用该函数之后想修改 storage 存储的
    // employees, 那么一种方式是在返回参数中声明 storage ,另一种方式是修改时根据返回的第二个参数
    // 直接修改 employees.
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) public onlyOwnerOf {
        //Employee employee = _findEmployee(employeeId);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);

        employees.push(Employee(employeeId, salary * 1 ether, now));
    }

    function removeEmployee(address employeeId) public onlyOwnerOf {
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        _partialPaid(employee);
        delete employees[index];    // delete will initiate the variable.
        // move the last employee to the deleted position to save space.
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwnerOf {
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        _partialPaid(employee);
        employee.salary = salary * 1 ether;   // the parameter is in ether unit for convenient;
        employee.lastPayday = now;
    }
    
    function addFund() public payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() public returns (uint){
        uint totalSalary = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }

        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        require(nextPayday <= now);
        
        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
}
