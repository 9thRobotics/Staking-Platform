// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingPlatform {
    address public tokenAddress;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewardBalance;

    uint256 public rewardRate = 10; // 10% annual rate

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
    }

    function claimRewards() public {
        uint256 rewards = calculateRewards(msg.sender);
        rewardBalance[msg.sender] += rewards;
        IERC20(tokenAddress).transfer(msg.sender, rewards);
    }

    function calculateRewards(address user) public view returns (uint256) {
        return (stakedBalance[user] * rewardRate) / 100;
    }
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
