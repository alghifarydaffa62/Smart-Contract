// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Staking is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public stakingTokens;
    IERC20 public rewardToken;

    uint public rewardRate = 100;

    struct User {
        uint stakeAmount;
        uint rewardDebt;
        uint lastUpdate;
    }
    
    mapping(address => User) public allUser;

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingTokens = _stakingToken;
        rewardToken = _rewardToken;
    }

    function stake(uint _amount) external nonReentrant {
        require(_amount > 0, "Invalid amount!");

        User storage user = allUser[msg.sender];

        if(user.stakeAmount > 0) {
            uint pending = (block.number - user.lastUpdate) * user.stakeAmount * rewardRate;
            user.rewardDebt += pending;
        }       

        stakingTokens.safeTransferFrom(msg.sender, address(this), _amount);

        user.stakeAmount += _amount;
        user.lastUpdate += block.number;
    }

    function claimRewards() external nonReentrant {
        User storage user = allUser[msg.sender];
        require(user.stakeAmount > 0, "No stake found");

        uint pending = (block.number - user.lastUpdate) * user.stakeAmount * rewardRate;
        uint totalRewards = user.rewardDebt + pending;

        require(totalRewards > 0, "No rewards!");

        user.rewardDebt = 0;
        user.lastUpdate = block.number;

        rewardToken.safeTransfer(msg.sender, totalRewards);
    }

    function unStake(uint _amount) external nonReentrant {
        User storage user = allUser[msg.sender];

        uint pending = (block.number - user.lastUpdate) * user.stakeAmount * rewardRate;
        uint totalRewards = user.rewardDebt + pending;

        user.stakeAmount -= _amount;
        user.rewardDebt = 0;
        user.lastUpdate = block.number;

        stakingTokens.safeTransfer(msg.sender, _amount);

        if(totalRewards > 0) {
            rewardToken.safeTransfer(msg.sender, totalRewards);
        }
    }
}