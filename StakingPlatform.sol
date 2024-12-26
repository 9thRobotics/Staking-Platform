// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingPlatform is Ownable, ReentrancyGuard {
    address public tokenAddress;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewardBalance;
    mapping(address => uint256) public lastStakedTime;

    uint256 public rewardRate = 10; // 10% annual rate

    event TokensStaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRewardRate);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        lastStakedTime[msg.sender] = block.timestamp;
        emit TokensStaked(msg.sender, amount);
    }

    function claimRewards() external nonReentrant {
        uint256 rewards = calculateRewards(msg.sender);
        rewardBalance[msg.sender] += rewards;
        IERC20(tokenAddress).transfer(msg.sender, rewards);
        emit RewardsClaimed(msg.sender, rewards);
    }

    function calculateRewards(address user) public view returns (uint256) {
        uint256 stakedTime = block.timestamp - lastStakedTime[user];
        uint256 annualRewards = (stakedBalance[user] * rewardRate) / 100;
        return (annualRewards * stakedTime) / 365 days;
    }

    function updateRewardRate(uint256 newRewardRate) external onlyOwner {
        rewardRate = newRewardRate;
        emit RewardRateUpdated(newRewardRate);
    }
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
