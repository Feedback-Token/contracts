// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EscrowToken is ERC20, Ownable {
    address public rewardsPool;

    constructor(string memory name, string memory symbol, address _rewardsPool) ERC20(name, symbol) {
        rewardsPool = _rewardsPool;
    }

    modifier onlyProtocol() {
        require(msg.sender == rewardsPool, "Only RewardsPool can call this function");
        _;
    }

    function mint(address account, uint256 amount) external onlyProtocol {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyProtocol {
        _burn(account, amount);
    }

    function updateRewardsPool(address _rewardsPool) external onlyOwner {
        rewardsPool = _rewardsPool;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        revert("EscrowToken: transfers are disabled");
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        revert("EscrowToken: transfers are disabled");
    }
}
