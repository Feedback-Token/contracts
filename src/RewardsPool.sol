// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRewardsPool} from "./interfaces/IRewardsPool.sol";
import {IEscrowToken} from "./interfaces/IEscrowToken.sol";

contract RewardsPool is IRewardsPool, Ownable {
    using SafeERC20 for IERC20;

    uint256 private constant BASIS_POINTS_TOTAL = 10000;
    uint256 public totalRewards;
    IEscrowToken internal veToken;
    address public rewardsToken;
    uint256 minLockPeriod;
    uint256 maxLockPeriod;

    mapping(address => uint256) internal lastTotalRewards;
    mapping(address => LockInfo) public locks;

    struct LockInfo {
        uint256 amount;
        uint256 lockTimestamp;
        uint256 lockDuration;
    }

    constructor(address _veToken, address _rewardsToken, uint256 _minLockPeriod, uint256 _maxLockPeriod) {
        veToken = IEscrowToken(_veToken);
        rewardsToken = _rewardsToken;
        minLockPeriod = _minLockPeriod;
        maxLockPeriod = _maxLockPeriod;
    }

    function _lockTokens(address _user, uint256 _amount, uint256 _timeLocked) internal {
        require(_timeLocked >= minLockPeriod && _timeLocked <= maxLockPeriod, "Invalid lock period");

        if (locks[_user].amount == 0) {
            locks[_user] = LockInfo(_amount, block.timestamp, _timeLocked);
        } else {
            require(
                _timeLocked >= locks[_user].lockDuration,
                "New lock duration must be greater than or equal to existing lock duration"
            );
            locks[_user].amount += _amount;
            locks[_user].lockTimestamp = block.timestamp;
            locks[_user].lockDuration = _timeLocked;
        }
        uint256 veTokenAmount = (_amount * _timeLocked) / maxLockPeriod;
        veToken.mint(_user, veTokenAmount);
    }

    function unlockTokens(uint256 _amount) external {
        require(veToken.balanceOf(msg.sender) >= _amount, "Insufficient veFBT balance");
        veToken.burn(msg.sender, _amount);
        IERC20(rewardsToken).safeTransfer(msg.sender, _amount);
    }

    function claimRewards() external {
        uint256 _userBalance = IERC20(address(veToken)).balanceOf(msg.sender);

        require(_userBalance > 0, "No veFBT tokens to claim rewards");

        uint256 newRewards = totalRewards - lastTotalRewards[msg.sender];

        // Calculate the user's share of the rewards
        uint256 reward = (_userBalance * newRewards) / IERC20(address(veToken)).totalSupply();

        lastTotalRewards[msg.sender] = totalRewards;

        IERC20(rewardsToken).safeTransfer(msg.sender, reward);
    }

    function updateMinLockPeriod(uint256 _minLockPeriod) external onlyOwner {
        minLockPeriod = _minLockPeriod;
    }

    function updateMaxLockPeriod(uint256 _maxLockPeriod) external onlyOwner {
        maxLockPeriod = _maxLockPeriod;
    }

    function onTokenTransfer(address sender, uint256 value, bytes calldata data) external {
        require(msg.sender == rewardsToken, "Sender must be FBT address");
        if (data.length == 0) {
            _updateRewards(value);
        } else {
            uint256 _timeLocked = abi.decode(data, (uint256));
            _lockTokens(sender, value, _timeLocked);
        }
    }

    function _updateRewards(uint256 _rewards) internal {
        totalRewards += _rewards;
    }
}
