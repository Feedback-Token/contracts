// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Subscription {
    mapping(address => uint256) internal balances;
    address public linkTokenAddress;

    constructor(address _link) {
        linkTokenAddress = _link;
    }

    function fundSubscription(address sender, uint256 value) internal {
        balances[sender] += value;
    }

    function getSubscription(address sender) public view returns (uint256) {
        return balances[sender];
    }

    function onTokenTransfer(address sender, uint256 value, bytes calldata) external {
        require(msg.sender == address(linkTokenAddress), "Sender must be LINK address");

        fundSubscription(sender, value);
    }
}
