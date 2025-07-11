# SecureWallet Smart Contract

A secure multi-user wallet smart contract built on Ethereum that enables users to store, withdraw, and transfer Ether in a decentralized and transparent manner.

## 🔍 Overview

SecureWallet is a multi-user wallet contract that provides:
- **User Registration**: Anyone can register as a wallet owner
- **Secure Storage**: Individual balance tracking for each user
- **Flexible Withdrawals**: Users can withdraw their own funds
- **Internal Transfers**: Transfer funds between registered users
- **Transparent Operations**: All transactions recorded on blockchain

This contract serves as a decentralized alternative to traditional multi-user wallet systems.

## ✨ Features

- **Multi-User Support**: Multiple users can register and use the wallet
- **Individual Balance Tracking**: Each user has their own balance within the contract
- **Secure Registration**: One-time registration per address
- **Flexible Deposits**: Users can deposit any amount of Ether
- **Safe Withdrawals**: Users can only withdraw their own funds
- **Internal Transfers**: Transfer funds between registered users without gas fees for recipients
- **Access Control**: Only registered owners can access wallet functions
- **Event Logging**: Comprehensive event emission for transparency
- **Gas Efficient**: Optimized for minimal gas consumption

## 🏗️ Contract Architecture

### User Structure

```solidity
struct User {
    uint balances;  // User's Ether balance in the contract
    bool isOwner;   // Registration status
}
```

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) toolkit
- Git
- MetaMask or similar Web3 wallet

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd Secure-Wallet

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

Deploy the SecureWallet contract:

```bash
# Deploy using Forge
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/SecureWallet.sol:SecureWallet

# Or using deployment script
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 2. User Registration

Register as a wallet owner:

```bash
# Register as owner
cast send <CONTRACT_ADDRESS> "registerOwner()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Wallet Operations

Perform wallet operations:

```bash
# Deposit 1 ETH
cast send <CONTRACT_ADDRESS> "depositEther()" --value 1ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Withdraw 0.5 ETH (amount in wei)
cast send <CONTRACT_ADDRESS> "withdrawEther(uint256)" 500000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Transfer 0.3 ETH to another user
cast send <CONTRACT_ADDRESS> "Transfer(address,uint256)" <RECIPIENT_ADDRESS> 300000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 4. Query User Information

```bash
# Check user information (returns balances and isOwner status)
cast call <CONTRACT_ADDRESS> "Owner(address)" <USER_ADDRESS> --rpc-url $RPC_URL

# Check if address is registered owner
cast call <CONTRACT_ADDRESS> "Owner(address)" <USER_ADDRESS> --rpc-url $RPC_URL | cut -d' ' -f2

# Check user balance
cast call <CONTRACT_ADDRESS> "Owner(address)" <USER_ADDRESS> --rpc-url $RPC_URL | cut -d' ' -f1
```

## 🔧 Functions

### Public Functions

#### `registerOwner()`
- **Caller**: Anyone (unregistered addresses only)
- **Purpose**: Register as a wallet owner
- **Requirements**: Address must not be already registered
- **Emits**: `registered`

#### `depositEther()`
- **Caller**: Registered owners only
- **Purpose**: Deposit Ether into the wallet
- **Requirements**: Must send Ether (value > 0), must be registered owner
- **Emits**: `deposited`

#### `withdrawEther(uint amount)`
- **Caller**: Registered owners only
- **Purpose**: Withdraw specified amount of Ether
- **Requirements**: Must be registered owner, sufficient balance
- **Emits**: `withdrawn`

#### `Transfer(address recipient, uint amount)`
- **Caller**: Registered owners only
- **Purpose**: Transfer Ether to another registered owner
- **Requirements**: Both sender and recipient must be registered, sufficient balance
- **Emits**: `transfered`

## 📡 Events

```solidity
event registered(address indexed user);
event deposited(address indexed user, uint amount);
event withdrawn(address indexed user, uint amount);
event transfered(address indexed sender, address indexed recipient, uint amount);
```

## 🧪 Testing

Run the comprehensive test suite using Forge:

```bash
# Run all tests
forge test

# Run tests with detailed output
forge test -vvv

# Run specific test contract
forge test --match-contract SecureWalletTest

# Run specific test function
forge test --match-test testRegisterOwner
```

## 🚢 Deployment

### Testnet Deployment

```bash
# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Or using forge create
forge create --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY src/SecureWallet.sol:SecureWallet --verify --etherscan-api-key $ETHERSCAN_API_KEY
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
import "../src/SecureWallet.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        SecureWallet wallet = new SecureWallet();
        
        vm.stopBroadcast();
        
        console.log("SecureWallet deployed to:", address(wallet));
        console.log("Contract ready for user registration");
    }
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./lib/forge-std/LICENSE-MIT) file for details.

## 👨‍💻 Author

**M Daffa Al Ghifary (alghifarydaffa62)**

## ⚠️ Disclaimer

This smart contract is provided as-is. Users should conduct their own security audits before using in production. The authors are not responsible for any loss of funds or damages resulting from the use of this contract.

---

*Built with ❤️ for secure decentralized wallet management*