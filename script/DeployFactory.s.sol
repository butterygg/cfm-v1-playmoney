// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import "forge-std/src/Script.sol";

import "src/PlayCollateralTokenFactory.sol";

contract DeployFactory is Script {
    function run() external {
        address conditionalTokens = vm.envAddress("CONDITIONAL_TOKENS");

        vm.startBroadcast();
        PlayCollateralTokenFactory factory = new PlayCollateralTokenFactory(conditionalTokens);
        vm.stopBroadcast();

        console.log("PlayCollateralTokenFactory deployed at:", address(factory));
    }
}
