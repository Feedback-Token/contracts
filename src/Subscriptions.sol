// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Subscription {
    mapping(address => uint256) public balances;

    constructor() {}

    function funcdSubscription() public {
        balances[msg.sender] += msg.value;
    }
}
