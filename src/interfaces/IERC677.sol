// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC677 {
    function transferAndCall(address _to, uint256 _value, bytes memory _data) external returns (bool);
}
