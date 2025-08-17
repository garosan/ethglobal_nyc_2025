// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/VerifiedRegistry.sol";

contract VerifiedRegistryTest is Test {
    // SUT
    VerifiedRegistry registry;

    // Signer used as the contract's verifier
    uint256 private verifierPk;
    address private verifierAddr;

    // Test data
    string constant PLATFORM = "twitter";
    string constant HANDLE   = "@alice";
    string constant POSTID   = "18446744073709551616";
    string constant URI      = "https://x.com/alice/status/123";
    string constant METADATA = "{\"type\":\"tweet\"}";
    bytes32 constant CONTENT_HASH = keccak256("hello world");

    function setUp() public {
        verifierPk = 0xA11CE;                 // arbitrary test private key
        verifierAddr = vm.addr(verifierPk);   // derive its address
        registry = new VerifiedRegistry(verifierAddr);
    }

    /* ========= Constructor / Ownable ========= */

    function test_OwnerAndVerifierInitialized() public {
        assertEq(registry.owner(), address(this));
        assertEq(registry.verifier(), verifierAddr);
    }

    /* ========= setVerifier ========= */

    function test_SetVerifier_OnlyOwner_EmitsEvent() public {
        address newVerifier = address(0xBEEF);

        vm.expectEmit(true, false, false, true, address(registry));
        emit VerifiedRegistry.VerifierUpdated(newVerifier);

        registry.setVerifier(newVerifier);
        assertEq(registry.verifier(), newVerifier);
    }

    function test_SetVerifier_Revert_ZeroAddress() public {
        vm.expectRevert(bytes("Verifier cannot be zero address"));
        registry.setVerifier(address(0));
    }

    function test_SetVerifier_Revert_NotOwner() public {
        address notOwner = address(0xC0FFEE);
        vm.prank(notOwner);
        // OZ v5 custom error: OwnableUnauthorizedAccount(address)
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", notOwner));
        registry.setVerifier(address(0x1234));
    }

    /* ========= register (unverified) ========= */

    function test_Register_StoresRecord_EmitsEvent() public {
        vm.warp(1_000_000);

        vm.expectEmit(true, true, false, true, address(registry));
        emit VerifiedRegistry.Registered(
            1,
            CONTENT_HASH,
            PLATFORM,
            URI,
            METADATA
        );

        uint256 id = registry.register(CONTENT_HASH, PLATFORM, URI, METADATA);
        assertEq(id, 1);

        (
            bytes32 cHash,
            string memory platform,
            string memory handle,
            string memory postId,
            string memory uri,
            uint256 ts,
            string memory metadata,
            bool verified
        ) = registry.records(id);

        assertEq(cHash, CONTENT_HASH);
        assertEq(platform, PLATFORM);
        assertEq(handle, "");
        assertEq(postId, "");
        assertEq(uri, URI);
        assertEq(ts, 1_000_000);
        assertEq(metadata, METADATA);
        assertEq(verified, false);
    }

    function test_Register_IncrementsIds() public {
        vm.warp(123);
        uint256 a = registry.register(CONTENT_HASH, PLATFORM, URI, METADATA);
        uint256 b = registry.register(keccak256("2"), "lens", "ipfs://foo", "bar");
        assertEq(a, 1);
        assertEq(b, 2);
    }

    /* ========= registerVerified ========= */

    function test_RegisterVerified_HappyPath() public {
        uint256 signedAt = 2_000_000;
        vm.warp(signedAt); // current block time

        bytes32 digest = _buildDigest(
            PLATFORM,
            HANDLE,
            POSTID,
            CONTENT_HASH,
            address(registry),
            block.chainid,
            signedAt
        );
        bytes memory sig = _sign(verifierPk, digest);

        vm.expectEmit(true, true, false, true, address(registry));
        emit VerifiedRegistry.Verified(
            1,
            CONTENT_HASH,
            PLATFORM,
            HANDLE,
            POSTID,
            URI,
            signedAt
        );

        uint256 id = registry.registerVerified(
            CONTENT_HASH,
            PLATFORM,
            HANDLE,
            POSTID,
            URI,
            signedAt,
            sig
        );
        assertEq(id, 1);

        (
            bytes32 cHash,
            string memory platform,
            string memory handle,
            string memory postId,
            string memory uri,
            uint256 ts,
            string memory metadata,
            bool verified
        ) = registry.records(id);

        assertEq(cHash, CONTENT_HASH);
        assertEq(platform, PLATFORM);
        assertEq(handle, HANDLE);
        assertEq(postId, POSTID);
        assertEq(uri, URI);
        assertEq(ts, signedAt);          // uses signedAt, not block.timestamp at call
        assertEq(metadata, "");
        assertTrue(verified);

        bytes32 submissionId = keccak256(abi.encodePacked(POSTID, CONTENT_HASH));
        assertTrue(registry.isSubmitted(submissionId));
    }

    function test_RegisterVerified_Revert_InvalidSignature() public {
        uint256 signedAt = 3_000_000;
        vm.warp(signedAt);

        // Sign with a different key (not the configured verifier)
        uint256 wrongPk = 0xB0B;
        address wrongAddr = vm.addr(wrongPk);
        assertTrue(wrongAddr != registry.verifier());

        bytes32 digest = _buildDigest(
            PLATFORM,
            HANDLE,
            POSTID,
            CONTENT_HASH,
            address(registry),
            block.chainid,
            signedAt
        );
        bytes memory sig = _sign(wrongPk, digest);

        vm.expectRevert(bytes("Invalid signature"));
        registry.registerVerified(
            CONTENT_HASH,
            PLATFORM,
            HANDLE,
            POSTID,
            URI,
            signedAt,
            sig
        );
    }

    function test_RegisterVerified_Revert_DuplicateSubmission() public {
        uint256 signedAt = 4_000_000;
        vm.warp(signedAt);

        bytes32 digest = _buildDigest(
            PLATFORM,
            HANDLE,
            POSTID,
            CONTENT_HASH,
            address(registry),
            block.chainid,
            signedAt
        );
        bytes memory sig = _sign(verifierPk, digest);

        registry.registerVerified(
            CONTENT_HASH, PLATFORM, HANDLE, POSTID, URI, signedAt, sig
        );

        // Reuse same (postId, contentHash) pair
        vm.expectRevert(bytes("Proof already submitted"));
        registry.registerVerified(
            CONTENT_HASH, PLATFORM, HANDLE, POSTID, URI, signedAt, sig
        );
    }

    function test_RegisterVerified_Revert_SignatureExpired() public {
        uint256 signedAt = 5_000_000;

        // Create a valid signature for signedAt
        bytes32 digest = _buildDigest(
            PLATFORM,
            HANDLE,
            POSTID,
            CONTENT_HASH,
            address(registry),
            block.chainid,
            signedAt
        );
        bytes memory sig = _sign(verifierPk, digest);

        // Advance time beyond signedAt + 10 minutes
        vm.warp(signedAt + 10 minutes + 1);

        vm.expectRevert(bytes("Signature expired"));
        registry.registerVerified(
            CONTENT_HASH, PLATFORM, HANDLE, POSTID, URI, signedAt, sig
        );
    }

    function test_RegisterVerified_Revert_BadSignatureLength() public {
        uint256 signedAt = 6_000_000;
        vm.warp(signedAt);

        // Any non-65-byte length should hit _split() require
        bytes memory badSig = hex"DEADBEEF";
        vm.expectRevert(bytes("Invalid signature length"));
        registry.registerVerified(
            CONTENT_HASH, PLATFORM, HANDLE, POSTID, URI, signedAt, badSig
        );
    }

    /* ========= Helpers ========= */

    function _buildDigest(
        string memory platform,
        string memory handle,
        string memory postId,
        bytes32 contentHash,
        address contractAddr,
        uint256 chainId,
        uint256 signedAt
    ) internal pure returns (bytes32) {
        bytes32 inner = keccak256(
            abi.encode(
                chainId,
                contractAddr,
                platform,
                handle,
                postId,
                contentHash,
                "PoM",
                signedAt
            )
        );
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", inner)
        );
    }

    function _sign(uint256 pk, bytes32 digest) internal returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v); // 65-byte {r}{s}{v}
    }
}
