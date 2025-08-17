// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/VerifiedRegistry.sol";

contract VerifiedRegistryTest is Test {
    VerifiedRegistry registry;

    address owner = address(0xABCD);
    address verifier = address(0xBEEF);
    address attacker = address(0xDEAD);

    string platform = "twitter";
    string handle = "@vitalik";
    string postId = "1234567890";
    string uri = "https://twitter.com/vitalik/status/1234567890";
    string metadata = "Backed up with love.";
    string magicWord = "PoM";

    function setUp() public {
        vm.prank(owner);
        registry = new VerifiedRegistry(verifier);
    }

    function testRegisterUnverified() public {
        bytes32 hash = keccak256(abi.encodePacked("hello world"));

        uint256 id = registry.register(hash, platform, uri, metadata);
        (bytes32 savedHash,,,,,,bool verified) = registry.records(id);

        assertEq(savedHash, hash);
        assertFalse(verified);
    }

    function testRegisterVerifiedWorks() public {
        bytes32 contentHash = keccak256(abi.encodePacked("real post"));
        uint256 signedAt = block.timestamp;

        // build digest
        bytes32 structHash = keccak256(abi.encode(
            block.chainid,
            address(registry),
            platform,
            handle,
            postId,
            contentHash,
            magicWord,
            signedAt
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(verifier)), digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        uint256 id = registry.registerVerified(
            contentHash, platform, handle, postId, uri, signedAt, sig
        );

        VerifiedRegistry.Record memory record = registry.records(id);
        assertEq(record.contentHash, contentHash);
        assertTrue(record.verified);
        assertEq(record.handle, handle);
    }

    function testRegisterFailsWithWrongSignature() public {
        bytes32 contentHash = keccak256(abi.encodePacked("real post"));
        uint256 signedAt = block.timestamp;

        bytes32 structHash = keccak256(abi.encode(
            block.chainid,
            address(registry),
            platform,
            handle,
            postId,
            contentHash,
            magicWord,
            signedAt
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(attacker)), digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.expectRevert("Invalid signature");
        registry.registerVerified(
            contentHash, platform, handle, postId, uri, signedAt, sig
        );
    }

    function testFailsOnDuplicateSubmission() public {
        bytes32 contentHash = keccak256(abi.encodePacked("duplicate test"));
        uint256 signedAt = block.timestamp;

        bytes32 structHash = keccak256(abi.encode(
            block.chainid,
            address(registry),
            platform,
            handle,
            postId,
            contentHash,
            magicWord,
            signedAt
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(verifier)), digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        // First submission
        registry.registerVerified(contentHash, platform, handle, postId, uri, signedAt, sig);

        // Try again
        vm.expectRevert("Proof already submitted");
        registry.registerVerified(contentHash, platform, handle, postId, uri, signedAt, sig);
    }

    function testFailsWithExpiredSignature() public {
        bytes32 contentHash = keccak256(abi.encodePacked("late post"));
        uint256 signedAt = block.timestamp - 11 minutes;

        bytes32 structHash = keccak256(abi.encode(
            block.chainid,
            address(registry),
            platform,
            handle,
            postId,
            contentHash,
            magicWord,
            signedAt
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(verifier)), digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.expectRevert("Signature expired");
        registry.registerVerified(contentHash, platform, handle, postId, uri, signedAt, sig);
    }
}
