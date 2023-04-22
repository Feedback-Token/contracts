// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/utils/Utils.sol";
import {FBTSubscriptions} from "../src/Subscriptions.sol";

contract SubscriptionsScript is Utils {
    uint256 deployerPrivateKey;
    FBTSubscriptions fbtContract;
    uint256 protocolFee = 1 ether;

    function run() public {
        if (block.chainid == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);
        fbtContract = new FBTSubscriptions(getValue("protocolToken"), protocolFee, getValue("protocolAdmin"));
        updateDeployment(address(fbtContract), "fbtContract");
    }
}
