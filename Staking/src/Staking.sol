// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Staking is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public stakingTokens;
    IERC20 public rewardToken;

    address private admin;

    uint public constant APR = 10;
    uint public constant SECONDS_IN_YEAR = 365 days;

    struct User {
        uint stakeAmount;
        uint rewards;
        uint lastUpdate;
    }

    modifier OnlyAdmin {
        require(msg.sender == admin, "Only Admin!");
        _;
    }
    
    mapping(address => User) public allUser;

    event stakeSuccess(address indexed user, uint indexed amount);
    event claimRewardSuccess(address indexed user, uint indexed rewardAmount);
    event unstakeSuccess(address indexed user, uint indexed amount);
    event fundRewardSuccess(address indexed user, uint indexed amount);

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingTokens = _stakingToken;
        rewardToken = _rewardToken;
        admin = msg.sender;
    }

    function stake(uint _amount) external nonReentrant {
        require(stakingTokens.balanceOf(msg.sender) >= _amount, "Insufficient balance!");
        require(_amount > 0, "Invalid amount!");

        User storage user = allUser[msg.sender];

        _updateRewards(msg.sender);      

        stakingTokens.safeTransferFrom(msg.sender, address(this), _amount);

        user.stakeAmount += _amount;
        emit stakeSuccess(msg.sender, _amount);
    }

    function claimRewards() external nonReentrant {
        User storage user = allUser[msg.sender];
        require(user.stakeAmount > 0, "No stake found");

        _updateRewards(msg.sender);

        uint reward = user.rewards;
        require(reward > 0, "No Reward");

        user.rewards = 0;
        rewardToken.safeTransfer(msg.sender, reward);

        emit claimRewardSuccess(msg.sender, reward);
    }

    function unStake(uint _amount) external nonReentrant {
        User storage user = allUser[msg.sender];
        require(user.stakeAmount >= _amount, "Invalid Amount");

        _updateRewards(msg.sender);

        user.stakeAmount -= _amount;

        stakingTokens.safeTransfer(msg.sender, _amount);

        emit unstakeSuccess(msg.sender, _amount);
    }

    function _updateRewards(address _user) internal {
        User storage user = allUser[_user];

        if(user.stakeAmount > 0 && user.lastUpdate > 0) {
            uint timeDiff = block.timestamp - user.lastUpdate;
            uint pending = (user.stakeAmount * APR * timeDiff) / (100 * SECONDS_IN_YEAR);

            user.rewards += pending;   
        }

        user.lastUpdate = block.timestamp;
    }

    function fundRewards(uint _amount) external OnlyAdmin {
        require(_amount > 0, "Invalid amount");

        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit fundRewardSuccess(msg.sender, _amount);
    }
}