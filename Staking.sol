// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EtherSlotsStaking is Ownable {
    using SafeMath for uint256;

    enum StakingDuration { THIRTY_DAYS, SIXTY_DAYS }

    IERC20 public etherSlotsToken;
    uint256 public rewardRate; // Reward rate in tokens per block
    uint256 public constant BLOCKS_PER_DAY = 6500;
    uint256 public constant EARLY_UNSTAKE_PENALTY = 20; // 20% penalty for early unstaking

    struct StakeInfo {
        uint256 stakedAmount;
        uint256 lastClaimBlock;
        uint256 lockEndBlock;
    }

    mapping(address => StakeInfo) public stakes;

    event Staked(address indexed staker, uint256 amount, StakingDuration duration);
    event Unstaked(address indexed staker, uint256 amount);
    event Claimed(address indexed staker, uint256 reward);

    constructor(IERC20 _etherSlotsToken, uint256 _rewardRate) {
        etherSlotsToken = _etherSlotsToken;
        rewardRate = _rewardRate;
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    function stake(uint256 amount, StakingDuration duration) external {
        require(amount > 0, "Cannot stake 0 tokens");

        // Transfer tokens from the user to the staking contract
        etherSlotsToken.transferFrom(msg.sender, address(this), amount);

        uint256 lockEndBlock;
        if (duration == StakingDuration.THIRTY_DAYS) {
            lockEndBlock = block.number.add(30 * BLOCKS_PER_DAY);
        } else if (duration == StakingDuration.SIXTY_DAYS) {
            lockEndBlock = block.number.add(60 * BLOCKS_PER_DAY);
        }

        // Update the staked amount, the last claim block, and the lock end block
        stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount.add(amount);
        stakes[msg.sender].lastClaimBlock = block.number;
        stakes[msg.sender].lockEndBlock = lockEndBlock;

        emit Staked(msg.sender, amount, duration);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Cannot unstake 0 tokens");
        require(stakes[msg.sender].stakedAmount >= amount, "Not enough tokens staked");
        require(block.number >= stakes[msg.sender].lockEndBlock, "Staking duration has not ended");

        // Transfer the tokens back to the user
        etherSlotsToken.transfer(msg.sender, amount);

        // Update the staked amount
        stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount.sub(amount);

        emit Unstaked(msg.sender, amount);
    }

    function unstakeEarly(uint256 amount) external {
        require(amount > 0, "Cannot unstake 0 tokens");
        require(stakes[msg.sender].stakedAmount >= amount, "Not enough tokens staked");

        uint256 penaltyAmount = amount.mul(EARLY_UNSTAKE_PENALTY).div(100);
        uint256 returnedAmount = amount.sub(penaltyAmount);

                // Transfer the tokens back to the user
        etherSlotsToken.transfer(msg.sender, returnedAmount);

        // Add the penalty amount back to the staking pool
        uint256 updatedRewardRate = rewardRate.add(penaltyAmount.mul(1e18).div(totalStaked()));
        setRewardRate(updatedRewardRate);

        // Update the staked amount
        stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount.sub(amount);

        emit Unstaked(msg.sender, returnedAmount);
    }

    function claim() external {
        uint256 pendingReward = getPendingReward(msg.sender);

        require(pendingReward > 0, "No rewards to claim");

        // Update the last claim block
        stakes[msg.sender].lastClaimBlock = block.number;

        // Transfer the reward to the user
        etherSlotsToken.transfer(msg.sender, pendingReward);

        emit Claimed(msg.sender, pendingReward);
    }

    function getPendingReward(address staker) public view returns (uint256) {
        uint256 blocksSinceLastClaim = block.number.sub(stakes[staker].lastClaimBlock);
        uint256 pendingReward = stakes[staker].stakedAmount.mul(rewardRate).mul(blocksSinceLastClaim).div(1e18);
        return pendingReward;
    }

    function totalStaked() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < stakeholders.length; i++) {
            total = total.add(stakes[stakeholders[i]].stakedAmount);
        }
        return total;
    }
}

