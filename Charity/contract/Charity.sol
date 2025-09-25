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
    /// @notice Address of the owner of the charity
    address public owner;

    /// @notice Address of the recipient to sent the charity collected
    address public recipient;

    /// @notice Title of the charity
    string public title;

    /// @notice Description of the charity
    string public desc;

    /// @notice The target amount of the charity
    uint public targetAmount;

    /// @notice The current balance of the charity
    uint public balance;

    /// @notice The deadline of the charity
    uint public deadline;

    /// @notice Indicator the charity has completed or not
    bool public isCompleted;

    /// @notice Struct to store donation details
    /// @param donator Address of the person who made the donation
    /// @param amount Amount donated in wei
    /// @param timestamp Time when the donation was made
    struct Donation {
        address donator;
        uint amount;
        uint timestamp;
    }

    /// @notice Array of all donations made to this charity
    Donation[] public donations;
    
    /// @notice Mapping of donor address to their total contribution amount
    mapping(address => uint) public donorContributions;
    
    /// @notice Array of all unique donor addresses
    address[] public donorAddresses;

    /// @notice Emitted when a successful donation is made
    /// @param donator Address of the donor
    /// @param amount Amount donated in wei
    /// @param timestamp Time when donation was made
    event donateSuccess(address indexed donator, uint amount, uint timestamp);

    /// @notice Emitted when charity funds are sent to recipient
    /// @param owner Address of the charity owner
    /// @param recipient Address of the fund recipient
    /// @param amount Amount sent to recipient in wei
    event CharitySended(address indexed owner, address indexed recipient, uint amount);

    /// @notice Emitted when charity is manually closed
    /// @param owner Address of the charity owner
    /// @param timestamp Time when charity was closed
    event CharityClosed(address indexed owner, uint timestamp);

    /**
     * @notice Constructor to initialize the charity contract
     * @param _title Title of the charity campaign
     * @param _desc Description of the charity campaign
     * @param _recipient Address that will receive the collected funds
     * @param _targetAmount Target amount to be raised in wei
     * @param _deadline Deadline timestamp for the campaign
     * @param _owner Address of the charity owner
     * @dev Validates that recipient is not zero address, target amount is positive, and deadline is in future
     */
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

    /// @notice Modifier to ensure only the owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    /// @notice Modifier to ensure charity is still active and accepting donations
    modifier charityActive() {
        require(!isCompleted, "Charity is completed!");
        require(block.timestamp <= deadline, "Charity deadline has passed!");
        _;
    }

    /**
     * @notice Function to donate Ether to the charity
     * @dev Uses nonReentrant to prevent reentrancy attacks and charityActive to ensure charity is accepting donations
     * @dev Automatically marks charity as completed if target amount is reached
     * @dev Adds new donors to the donorAddresses array on their first donation
     */
    function donate() external payable nonReentrant charityActive {
        require(msg.value > 0, "Must send ether!");

        donations.push(Donation({
            donator: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp
        }));

        // Add donor to addresses array if this is their first donation
        if(donorContributions[msg.sender] == 0) {
            donorAddresses.push(msg.sender);
        }

        donorContributions[msg.sender] += msg.value;
        balance += msg.value;

        emit donateSuccess(msg.sender, msg.value, block.timestamp);

        // Mark as completed if target is reached
        if(balance >= targetAmount) {
            isCompleted = true;
        }
    }

    /**
     * @notice Function for owner to send collected funds to the recipient
     * @dev Can only be called by owner after charity is completed or deadline has passed
     * @dev Uses nonReentrant to prevent reentrancy attacks
     * @dev Transfers entire balance and marks charity as completed
     */
    function SendCharity() external payable onlyOwner nonReentrant {
        require(isCompleted || block.timestamp > deadline, "Charity is still active!");
        require(balance > 0, "No funds to send!");

        uint amount = balance;
        balance = 0;
        isCompleted = true;

        (bool success,) = recipient.call{value: amount}("");
        require(success, "Transfer failed!");

        emit CharitySended(msg.sender, recipient, amount);
    }

    /**
     * @notice Function to manually close the charity
     * @dev Can be called by anyone but only works if charity is not already completed
     * @dev Does not transfer funds, just marks charity as completed
     */
    function CloseCharity() public {
        require(!isCompleted, "Charity Already Completed!");
        isCompleted = true;
        emit CharityClosed(msg.sender, block.timestamp);
    }

    /**
     * @notice Get the total number of donations made
     * @return The total count of donations
     */
    function getDonationsCount() external view returns (uint) {
        return donations.length;
    }

    /**
     * @notice Get donation details by index
     * @param index The index of the donation in the donations array
     * @return donator Address of the donor
     * @return amount Amount donated in wei
     * @return timestamp Time when donation was made
     * @dev Reverts if index is out of bounds
     */
    function getDonation(uint index) external view returns(address donator, uint amount, uint timestamp) {
        require(index < donations.length, "Invalid Index");
        Donation memory donation = donations[index];
        return (donation.donator, donation.amount, donation.timestamp);
    }

    /**
     * @notice Get all donations made to this charity
     * @return Array of all Donation structs
     * @dev Be careful with gas costs for large arrays
     */
    function getAllDonation() external view returns(Donation[] memory) {
        return donations;
    }

    /**
     * @notice Get all unique donor addresses
     * @return Array of all donor addresses
     */
    function getDonorAddress() external view returns(address[] memory) {
        return donorAddresses;
    }

    /**
     * @notice Get total contribution amount from a specific donor
     * @param donor Address of the donor to query
     * @return Total amount contributed by the donor in wei
     */
    function getDonorContribution(address donor) external view returns(uint) {
        return donorContributions[donor];
    }

    /**
     * @notice Get complete charity information in a single call
     * @return _title Title of the charity
     * @return _desc Description of the charity
     * @return _owner Address of the charity owner
     * @return _recipient Address of the fund recipient
     * @return _targetAmount Target amount in wei
     * @return _balance Current balance in wei
     * @return _deadline Deadline timestamp
     * @return _isCompleted Whether charity is completed
     */
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