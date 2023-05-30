// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AutomationCompatibleInterface} from
    "@chainlink/src/v0.8/interfaces/automation/AutomationCompatibleInterface.sol";
import {IRewardsPool} from "./interfaces/IRewardsPool.sol";
import {IERC677} from "./interfaces/IERC677.sol";

contract FBTSubscriptions is AutomationCompatibleInterface, Ownable {
    using SafeERC20 for IERC20;

    mapping(address => uint256) internal balances;
    address public protocolToken;
    address public protocolAdmin;
    IRewardsPool public rewardsPool;
    uint256 public protocolFee;

    uint256 internal interval;
    uint256 internal lastDistribution;

    constructor(address _protocolToken, uint256 _protocolFee, address _protocolAdmin, address _rewardsPool) {
        protocolToken = _protocolToken;
        protocolFee = _protocolFee;
        protocolAdmin = _protocolAdmin;
        rewardsPool = IRewardsPool(_rewardsPool);
    }

    modifier onlyProtocol() {
        require(msg.sender == protocolAdmin, "Only admin can call this function");
        _;
    }

    function _fundSubscription(address sender, uint256 value) internal {
        balances[sender] += value;
    }

    function useSubscription(address sender) external onlyProtocol {
        require(balances[sender] >= protocolFee, "Insufficient subscription balance");
        balances[sender] -= protocolFee;
        balances[address(this)] += protocolFee;
    }

    function getSubscription(address sender) public view returns (uint256) {
        return balances[sender];
    }

    function updateProtocolFee(uint256 _protocolFee) external onlyOwner {
        protocolFee = _protocolFee;
    }

    function updateProtocolAdmin(address _protocolAdmin) external onlyOwner {
        protocolAdmin = _protocolAdmin;
    }

    function updateProtocolToken(address _protocolToken) external onlyOwner {
        protocolToken = _protocolToken;
    }

    function updateRewardsPool(address _rewardsPool) external onlyProtocol {
        rewardsPool = IRewardsPool(_rewardsPool);
    }

    function updateInterval(uint256 _interval) external onlyProtocol {
        interval = _interval;
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        if (lastDistribution + interval < block.timestamp) {
            return (true, "");
        }
    }

    function performUpkeep(bytes calldata) external override {
        if (lastDistribution + interval < block.timestamp) {
            IERC677(protocolToken).transferAndCall(address(rewardsPool), balances[address(this)], "");
            lastDistribution = block.timestamp;
        }
    }

    function onTokenTransfer(address sender, uint256 value, bytes calldata) external {
        require(msg.sender == address(protocolToken), "Sender must be FBT address");

        _fundSubscription(sender, value);
    }

    function withdraw(address _to) external onlyOwner {
        uint256 balance = balances[address(this)];
        require(balance > 0, "Insufficient balance");
        balances[address(this)] -= balance;
        IERC20(protocolToken).safeTransfer(_to, balance);
    }
}
