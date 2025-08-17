// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/VerifiedRegistry.sol";

contract VerifiedRegistryScript is Script {
    function run() external returns (address) {
        // Hardcoded verifier for demo purposes
        address verifier = 0xCC282EfE3101Ed36Fa5cE1bAa2e68a06B778f22d;

        vm.startBroadcast();
        VerifiedRegistry registry = new VerifiedRegistry(verifier);
        vm.stopBroadcast();

        return address(registry);
    }
}
