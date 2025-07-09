# Charity Smart Contract

A transparent and secure charity donation smart contract built on Ethereum that allows anyone to donate and enables the owner to distribute collected funds to designated recipients.

## 🔍 Overview

This Charity smart contract provides a decentralized solution for collecting and distributing donations where:
- **Anyone** can donate Ether to the charity
- **Owner** manages the charity lifecycle (open/close)
- **Transparent** fund tracking on the blockchain
- **Secure** fund distribution to verified recipients

The contract ensures transparency in charitable giving by recording all donations and distributions on the blockchain.

## ✨ Features

- **Open Donations**: Anyone can contribute to the charity
- **Owner Control**: Only owner can close charity and distribute funds
- **Transparent Tracking**: All donations and distributions are publicly visible
- **Secure Transfers**: Safe fund handling with proper validation
- **Event Logging**: Comprehensive event emission for transparency

## 🏗️ Contract Architecture

### Participants

1. **Owner**: The charity organizer who deploys and manages the contract
2. **Donators**: Anyone who contributes Ether to the charity
3. **Recipients**: Addresses that receive distributed charity funds

### State Variables

- `owner`: Address of the charity contract owner
- `TotalCharity`: Total amount of Ether collected from donations
- `isActive`: Boolean indicating if the charity is accepting donations

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) toolkit
- Git
- MetaMask or similar Web3 wallet

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd charity-smart-contract

# Install Foundry dependencies
forge install

# Initialize Foundry project (if not already done)
forge init --force
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

Deploy the charity contract:

```bash
# Deploy using Forge
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/Charity.sol:Charity

# Or using deployment script
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 2. Donation Process

Anyone can donate to the charity:

```bash
# Donate 1 ETH to the charity
cast send <CONTRACT_ADDRESS> "donate()" --value 1ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Charity Management

Owner can manage the charity:

```bash
# Check charity status
cast call <CONTRACT_ADDRESS> "getStatus()" --rpc-url $RPC_URL

# Close charity (stop accepting donations)
cast send <CONTRACT_ADDRESS> "closeCharity()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Send collected funds to recipient
cast send <CONTRACT_ADDRESS> "SendCharity(address)" <RECIPIENT_ADDRESS> --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 4. Query Contract State

```bash
# Check total charity amount
cast call <CONTRACT_ADDRESS> "TotalCharity()" --rpc-url $RPC_URL

# Check contract owner
cast call <CONTRACT_ADDRESS> "owner()" --rpc-url $RPC_URL

# Check charity status
cast call <CONTRACT_ADDRESS> "getStatus()" --rpc-url $RPC_URL
```

## 🔧 Functions

### Public Functions

#### `donate()`
- **Caller**: Anyone
- **Purpose**: Donate Ether to the charity
- **Requirements**: Must send Ether (value > 0), charity must be active
- **Emits**: `donateSuccess`

#### `SendCharity(address recipient)`
- **Caller**: Owner only
- **Purpose**: Send collected funds to specified recipient
- **Requirements**: Charity must be closed, valid recipient address
- **Emits**: `CharitySended`

#### `closeCharity()`
- **Caller**: Owner only
- **Purpose**: Close the charity (stop accepting donations)
- **Requirements**: Only owner can call
- **Emits**: `CharityClosed`

#### `getStatus()`
- **Caller**: Anyone
- **Purpose**: Check if charity is active
- **Returns**: Boolean indicating charity status

## 📡 Events

```solidity
event donateSuccess(address indexed donator, uint amount);
event CharitySended(address indexed owner, address indexed recipient, uint amount);
event CharityClosed(address indexed owner);
```

## 🧪 Testing

Run the comprehensive test suite using Forge:

```bash
# Run all tests
forge test

# Run specific test contract
forge test --match-contract CharityTest

# Run specific test function
forge test --match-test testDonate
```

## 🚢 Deployment

### Local Network

```bash
# Start local Anvil node
anvil

# Deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

### Testnet Deployment

```bash
# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Or using forge create
forge create --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY src/Charity.sol:Charity --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Mainnet Deployment

```bash
# Deploy to Ethereum mainnet
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Verify deployment
cast code <DEPLOYED_CONTRACT_ADDRESS> --rpc-url $MAINNET_RPC_URL
```

### Deployment Script Example

Create `script/Deploy.s.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Charity.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Charity charity = new Charity();
        
        vm.stopBroadcast();
        
        console.log("Charity deployed to:", address(charity));
        console.log("Owner:", charity.owner());
        console.log("Status:", charity.getStatus());
    }
}
```

## 👨‍💻 Author

**M Daffa Al Ghifary (alghifarydaffa62)**

## ⚠️ Disclaimer

This smart contract is provided as-is. Users should conduct their own security audits before using in production. The authors are not responsible for any loss of funds or damages resulting from the use of this contract.

---

*Built with ❤️ for transparent charitable giving*