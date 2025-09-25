// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Charity
 * @author [M Daffa Al Ghifary a.k.a dfpro]
 * @notice A simple and secure charity wallet to receive donations and distribute them to the recipient
 * @dev Only the owner can close the charity and send collected funds into recipient
 */
contract Charity is ReentrancyGuard {
    address public owner;
    address public recipient;
    string public title;
    string public desc;
    uint public targetAmount;
    uint public balance;
    uint public deadline;
    bool public isCompleted;

    struct Donation {
        address donator;
        uint amount;
        uint timestamp;
    }

    Donation[] public donations;
    mapping(address => uint) public donorContributions;
    address[] public donorAddresses;

    event donateSuccess(address indexed donator, uint amount, uint timestamp);
    event CharitySended(address indexed owner, address indexed recipient, uint amount);
    event CharityClosed(address indexed owner, uint timestamp);

    constructor(
        string memory _title, 
        string memory _desc, 
        address _recipient, 
        uint _targetAmount, 
        uint _deadline,
        address _owner
    ) {
        require(_recipient != address(0), "Invalid Recipient Address");
        require(_targetAmount > 0, "Invalid Target Amount");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        title = _title;
        desc = _desc;
        recipient = _recipient;
        targetAmount = _targetAmount;
        deadline = _deadline;
        owner = _owner;
        balance = 0;
        isCompleted = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    modifier charityActive() {
        require(!isCompleted, "Charity is completed!");
        require(block.timestamp <= deadline, "Charity deadline has passed!");
        _;
    }

    function donate() external payable nonReentrant charityActive {
        require(msg.value > 0, "Must send ether!");

        donations.push(Donation({
            donator: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp
        }));

        if(donorContributions[msg.sender] == 0) {
            donorAddresses.push(msg.sender);
        }

        donorContributions[msg.sender] += msg.value;

        balance += msg.value;

        emit donateSuccess(msg.sender, msg.value, block.timestamp);

        if(balance >= targetAmount) {
            isCompleted = true;
        }
    }

    function SendCharity() external payable onlyOwner nonReentrant {
        require(!isCompleted || block.timestamp > deadline, "Charity is still active!");
        require(balance > 0, "No funds to send!");

        uint amount = balance;
        balance = 0;
        isCompleted = true;

        (bool success,) = recipient.call{value: amount}("");
        require(success, "Transfer failed!");

        emit CharitySended(msg.sender, recipient, amount);
    }

    function CloseCharity() public {
        require(!isCompleted, "Charity Already Completed!");
        isCompleted = true;
        emit CharityClosed(msg.sender, block.timestamp);
    }

    function getDonationsCount() external view returns (uint) {
        return donations.length;
    }

    function getDonation(uint index) external view returns(address donator, uint amount, uint timestamp) {
        require(index <= donations.length, "Invalid Index");
        Donation memory donation = donations[index];
        return (donation.donator, donation.amount, donation.timestamp);
    }

    function getAllDonation() external view returns(Donation[] memory) {
        return donations;
    }

    function getDonorAddress() external view returns(address[] memory) {
        return donorAddresses;
    }

    function getDonorContribution(address donor) external view returns(uint) {
        return donorContributions[donor];
    }

    function getCharityInfo() external view returns(
        string memory _title,
        string memory _desc,
        address _owner,
        address _recipient, 
        uint _targetAmount, 
        uint _balance,
        uint _deadline,
        bool _isCompleted
    ) {
        return (title, desc, owner, recipient, targetAmount, balance, deadline, isCompleted);
    }
}
