// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/utils/Utils.sol";
import {FeedBackToken} from "../src/ERC677.sol";

contract TokenScript is Utils {
    uint256 deployerPrivateKey;
    FeedBackToken token;

    function run() public {
        if (block.chainid == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);
        token = new FeedBackToken("FeedBack Token", "FBT", 100_000_000 ether, getValue("protocolAdmin"));
        updateDeployment(address(token), "protocolToken");
    }
}
