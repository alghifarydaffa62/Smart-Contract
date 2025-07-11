# Voting Smart Contract

A secure and transparent voting system built on Ethereum that enables democratic decision-making with complete transparency and immutability.

## 🔍 Overview

This Voting smart contract provides a comprehensive voting mechanism for organizations where:
- An **Admin** (contract deployer) manages the entire voting process
- **Voters** are registered and can cast their votes for candidates
- **Candidates** are registered and compete for votes
- **Transparent results** are available in real-time and after voting concludes

The contract eliminates the need for traditional voting systems and provides complete transparency through blockchain technology.

## ✨ Features

- **Admin-controlled Process**: Only the contract deployer can manage voting operations
- **Voter Registration**: Secure registration system for eligible voters
- **Candidate Management**: Register candidates with unique IDs
- **Vote Casting**: One-vote-per-voter system with validation
- **Real-time Progress**: Monitor voting progress during active sessions
- **Immutable Results**: Transparent and tamper-proof voting results
- **Event Logging**: Comprehensive event emission for tracking all activities
- **Access Control**: Role-based permissions for different participants

## 🏗️ Contract Architecture

### Participants

1. **Admin**: The party that deploys the contract and manages the voting process
2. **Voters**: Registered participants who can cast votes
3. **Candidates**: Registered participants who compete for votes

### State Variables

- `admin`: Address of the contract administrator
- `voteStart`: Boolean flag indicating if voting is active
- `ID`: Counter for generating unique candidate IDs
- `voters`: Mapping of voter addresses to their details
- `candidates`: Mapping of candidate addresses to their details
- `candidateList`: Array of all registered candidates

### Data Structures

```solidity
struct Voter {
    address voter;           // Voter's wallet address
    uint votedCandidate;     // ID of candidate they voted for
    bool hasVoted;           // Flag indicating if they have voted
    bool isRegistered;       // Flag indicating if they are registered
}

struct Candidate {
    address candidateAddr;   // Candidate's wallet address
    uint candidateID;        // Unique candidate identifier
    uint totalVote;          // Total votes received
    bool isCandidate;        // Flag indicating if they are a candidate
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
cd voting-smart-contract

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
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/Voting.sol:Voting

# Or using Hardhat
npx hardhat run scripts/deploy.js --network <network-name>
```

### 2. Admin Operations

```bash
# Register a voter
cast send <CONTRACT_ADDRESS> "registerVoter(address)" <VOTER_ADDRESS> --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Register a candidate
cast send <CONTRACT_ADDRESS> "registerCandidate(address)" <CANDIDATE_ADDRESS> --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Start voting
cast send <CONTRACT_ADDRESS> "startVoting()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Close voting
cast send <CONTRACT_ADDRESS> "closeVoting()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Voter Operations

```bash
# Cast a vote (using voter's private key)
cast send <CONTRACT_ADDRESS> "castVote(uint256)" <CANDIDATE_ID> --rpc-url $RPC_URL --private-key $VOTER_PRIVATE_KEY
```

### 4. Query Contract State

```bash
# Check voting status
cast call <CONTRACT_ADDRESS> "voteStart()" --rpc-url $RPC_URL

# Show current progress
cast call <CONTRACT_ADDRESS> "showProgress()" --rpc-url $RPC_URL

# Show final results (after voting ends)
cast call <CONTRACT_ADDRESS> "showResult()" --rpc-url $RPC_URL

```

## 🔧 Functions

### Administrative Functions

#### `registerVoter(address _voterAdd)`
- **Caller**: Admin only
- **Purpose**: Register a new voter
- **Requirements**: Voting not started, voter not already registered, valid address
- **Emits**: `registerVoterSuccess`

#### `registerCandidate(address _candidateAdd)`
- **Caller**: Admin only
- **Purpose**: Register a new candidate
- **Requirements**: Voting not started, candidate not already registered, not a registered voter
- **Emits**: `registerCandidateSuccess`

#### `startVoting()`
- **Caller**: Admin only
- **Purpose**: Start the voting process
- **Requirements**: Voting not already started
- **Emits**: `VotingStarted`

#### `closeVoting()`
- **Caller**: Admin only
- **Purpose**: End the voting process
- **Requirements**: Voting must be active
- **Emits**: `VotingEnded`

### Voter Functions

#### `castVote(uint candidateId)`
- **Caller**: Registered voters only
- **Purpose**: Cast a vote for a candidate
- **Requirements**: Voter registered, voting active, haven't voted yet, valid candidate ID
- **Emits**: `castVoteSuccess`

## 📡 Events

```solidity
event registerVoterSuccess(address indexed admin, address indexed voter);
event registerCandidateSuccess(address indexed admin, address indexed candidate);
event castVoteSuccess(address indexed voter, uint indexed candidateVoted);
event VotingStarted(address indexed admin);
event VotingEnded(address indexed admin);
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Using Foundry
forge test

# Using Hardhat
npx hardhat test

# Run tests with detailed output
forge test -vvv

# Run specific test function
forge test --match-test testCastVote
```

## 🚢 Deployment

### Deployment Script Example

Create `script/Deploy.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Voting.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Voting voting = new Voting();
        
        vm.stopBroadcast();
        
        console.log("Voting contract deployed to:", address(voting));
        console.log("Admin address:", voting.admin());
    }
}
```

## 👨‍💻 Author

**M Daffa Al Ghifary (alghifarydaffa62)**

## ⚠️ Disclaimer

This smart contract is provided as-is for educational and demonstration purposes. Users should conduct thorough testing and security audits before using in production environments. The authors are not responsible for any loss of funds or damages resulting from the use of this contract.

## 📜 License

This project is licensed under the MIT License.

---

*Built with ❤️ for transparent democratic processes*