# Payroll Smart Contract

A decentralized payroll management system built on Ethereum that allows administrators to manage employee salaries with transparency and automation.

## 🔍 Overview

This Payroll smart contract provides a secure payroll management mechanism for organizations where:
- **Admin** (contract deployer) manages the payroll system
- **Employees** are registered with their wallet addresses and salary amounts
- **Automated payments** are executed to all employees in batch transactions
- **Transparent operations** are recorded on the blockchain for accountability

The contract eliminates the need for traditional payroll services and provides transparency through blockchain technology.

## ✨ Features

- **Admin-only Access**: Only the contract deployer can manage payroll operations
- **Employee Management**: Add and remove employees with their respective salaries
- **Batch Salary Payments**: Pay all employees in a single transaction
- **Balance Management**: Deposit funds to the contract for salary payments
- **Employee Verification**: Prevents duplicate employee registration
- **Event Logging**: Comprehensive event emission for tracking

## 🏗️ Contract Architecture

### Participants

1. **Admin**: The party that deploys the contract and manages payroll operations
2. **Employees**: The parties that receive salary payments from the contract

### State Variables

- `employees[]`: Array of registered employees with their details
- `Admin`: Address of the contract administrator
- `companyBalance`: Current balance available for salary payments

### Employee Structure

```solidity
struct Employee {
    address employee;  // Employee's wallet address
    uint salary;       // Employee's salary amount (in wei)
}
```

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) toolkit or [Hardhat](https://hardhat.org/)
- Git
- MetaMask or similar Web3 wallet

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd payroll-smart-contract

# For Foundry
forge install

# For Hardhat
npm install
```

### Environment Setup

Create a `.env` file in the root directory:

```env
PRIVATE_KEY=your_private_key_here
RPC_URL=your_rpc_url_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## 📖 Usage

### 1. Contract Deployment

Deploy the contract (admin is automatically set as deployer):

```bash
# Deploy using Forge
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/Payroll.sol:Payroll

# Or using Hardhat
npx hardhat run scripts/deploy.js --network <network-name>
```

### 2. Interact with Contract

Use cast for contract interactions:

```bash
# Deposit funds (replace with actual contract address)
cast send <CONTRACT_ADDRESS> "deposit()" --value 10ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Add employee
cast send <CONTRACT_ADDRESS> "addEmployee(address,uint256)" <EMPLOYEE_ADDRESS> 1000000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Pay all salaries
cast send <CONTRACT_ADDRESS> "paySalaries()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Remove employee
cast send <CONTRACT_ADDRESS> "removeEmployee(address)" <EMPLOYEE_ADDRESS> --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Query Contract State

```bash
# Check employee count
cast call <CONTRACT_ADDRESS> "getEmployeeCount()" --rpc-url $RPC_URL

# Check total salaries
cast call <CONTRACT_ADDRESS> "getTotalSalaries()" --rpc-url $RPC_URL

# Check specific employee details
cast call <CONTRACT_ADDRESS> "getEmployee(uint256)" 0 --rpc-url $RPC_URL
```

## 🔧 Functions

### Administrative Functions

#### `deposit()`
- **Caller**: Admin only
- **Purpose**: Deposit Ether into the payroll contract
- **Requirements**: Must send Ether (value > 0)
- **Emits**: `depositSuccess`

#### `addEmployee(address _employee, uint _salary)`
- **Caller**: Admin only
- **Purpose**: Register a new employee with their salary
- **Requirements**: Employee not already registered, salary > 0
- **Emits**: `employeeRegisterSuccess`

#### `paySalaries()`
- **Caller**: Admin only
- **Purpose**: Pay salaries to all registered employees
- **Requirements**: Contract balance >= total salaries
- **Emits**: `salaryPayed` (for each employee)

#### `removeEmployee(address _employee)`
- **Caller**: Admin only
- **Purpose**: Remove an employee from the payroll
- **Requirements**: Employee must exist
- **Emits**: `employeeFired`

## 📡 Events

```solidity
event depositSuccess(address indexed admin, uint amount);
event employeeRegisterSuccess(address indexed admin, address indexed employee, uint salary);
event salaryPayed(address indexed admin, address indexed employee, uint salary);
event employeeFired(address indexed admin, address employee);
```

## 🧪 Testing

Run the comprehensive test suite using your preferred framework:

```bash
# Using Foundry
forge test

# Using Hardhat
npx hardhat test

# Run tests with detailed output
forge test -vvv

# Run specific test function
forge test --match-test testAddEmployee
```

### Detailed Test Coverage

**✅ Core Functionality Tests:**
- `testDeposit()` - Validates successful Ether deposits
- `testAddEmployee()` - Confirms employee registration
- `testPaySalaries()` - Verifies batch salary payments
- `testRemoveEmployee()` - Tests employee removal

**✅ Access Control Tests:**
- `testOnlyAdminCanDeposit()` - Ensures only admin can deposit
- `testOnlyAdminCanAddEmployee()` - Blocks non-admin employee additions
- `testOnlyAdminCanPaySalaries()` - Restricts salary payments to admin
- `testOnlyAdminCanRemoveEmployee()` - Limits employee removal to admin

**✅ Input Validation Tests:**
- `testCannotDepositZeroEther()` - Prevents zero-value deposits
- `testCannotAddDuplicateEmployee()` - Blocks duplicate registrations
- `testCannotAddEmployeeWithZeroSalary()` - Prevents zero salary
- `testCannotPaySalariesWithInsufficientBalance()` - Blocks payment when underfunded

## 🚢 Deployment

### Deployment Script Example

Create `script/Deploy.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Payroll.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Payroll payroll = new Payroll();
        
        vm.stopBroadcast();
        
        console.log("Payroll deployed to:", address(payroll));
        console.log("Admin address:", payroll.Admin());
    }
}
```

### Hardhat Deployment Script

Create `scripts/deploy.js`:

```javascript
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    
    console.log("Deploying Payroll with account:", deployer.address);
    
    const Payroll = await ethers.getContractFactory("Payroll");
    const payroll = await Payroll.deploy();
    
    await payroll.deployed();
    
    console.log("Payroll deployed to:", payroll.address);
    console.log("Admin address:", await payroll.Admin());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

## 👨‍💻 Author

**M Daffa Al Ghifary (dfpro)**

## ⚠️ Disclaimer

This smart contract is provided as-is for educational purposes. Users should conduct their own security audits before using in production. The authors are not responsible for any loss of funds or damages resulting from the use of this contract.

---

*Built with ❤️ for the Ethereum community*