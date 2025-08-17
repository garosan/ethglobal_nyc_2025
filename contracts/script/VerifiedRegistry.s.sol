// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/VerifiedRegistry.sol";

contract VerifiedRegistryScript is Script {
    function run() external returns (address) {
        // Read the verifier address from the environment variables
        address verifierAddress = vm.envAddress("VERIFIER_ADDRESS");
        require(verifierAddress != address(0), "VERIFIER_ADDRESS env var not set");

        vm.startBroadcast();
        VerifiedRegistry registry = new VerifiedRegistry(verifierAddress);
        vm.stopBroadcast();
        
        return address(registry);
    }
}
