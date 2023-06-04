// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/utils/Utils.sol";
import {RewardsPool} from "../src/RewardsPool.sol";
import {EscrowToken} from "../src/EscrowToken.sol";

contract RewardsPoolScript is Utils {
    uint256 deployerPrivateKey;
    RewardsPool pool;
    EscrowToken veToken;
    address fbtToken;
    uint256 minLockPeriod = 7 days;
    uint256 maxLockPeriod = (365 days * 4);

    function run() public {
        if (block.chainid == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        fbtToken = getValue("protocolToken");
        vm.startBroadcast(deployerPrivateKey);
        veToken = new EscrowToken("Voting Escrow Feedback Token", "veFBT", address(0));
        pool = new RewardsPool(address(veToken), fbtToken, minLockPeriod, maxLockPeriod);

        veToken.updateRewardsPool(address(pool));
        updateDeployment(address(pool), "rewardsPool");
        updateDeployment(address(veToken), "veToken");
    }
}
