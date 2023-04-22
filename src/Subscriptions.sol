// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FBTSubscriptions is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => uint256) internal balances;
    address public protocolToken;
    address public protocolAdmin;

    uint256 public protocolFee;

    constructor(address _protocolToken, uint256 _protocolFee, address _protocolAdmin) {
        protocolToken = _protocolToken;
        protocolFee = _protocolFee;
        protocolAdmin = _protocolAdmin;
    }

    modifier onlyProtocol() {
        require(msg.sender == protocolAdmin, "Only admin can call this function");
        _;
    }

    function fundSubscription(address sender, uint256 value) internal {
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

    function onTokenTransfer(address sender, uint256 value, bytes calldata) external {
        require(msg.sender == address(protocolToken), "Sender must be FBT address");

        fundSubscription(sender, value);
    }

    function withdraw(address _to) external onlyOwner {
        uint256 balance = balances[address(this)];
        require(balance > 0, "Insufficient balance");
        balances[address(this)] -= balance;
        IERC20(protocolToken).safeTransfer(_to, balance);
    }
}
