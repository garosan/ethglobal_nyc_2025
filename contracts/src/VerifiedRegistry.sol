// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VerifiedRegistry
 * @dev Anchors social media content proofs (unverified or verified) on-chain.
 * Inspired by the idea that memories shouldn't be lost when platforms disappear.
 */
contract VerifiedRegistry is Ownable {
    struct Record {
        bytes32 contentHash;
        string platform;
        string handle;
        string postId;
        string uri;
        uint256 timestamp;
        string metadata;
        bool verified;
    }

    address public verifier;
    mapping(uint256 => Record) public records;
    mapping(bytes32 => bool) public isSubmitted;
    uint256 private _recordIdCounter;

    event Registered(
        uint256 indexed recordId,
        bytes32 indexed contentHash,
        string platform,
        string uri,
        string metadata
    );

    event Verified(
        uint256 indexed recordId,
        bytes32 indexed contentHash,
        string platform,
        string handle,
        string postId,
        string uri,
        uint256 timestamp
    );

    event VerifierUpdated(address indexed newVerifier);

    constructor(address initialVerifier) Ownable(msg.sender) {
        verifier = initialVerifier;
    }

    /// @notice Updates the trusted backend verifier
    function setVerifier(address _newVerifier) external onlyOwner {
        require(_newVerifier != address(0), "Verifier cannot be zero address");
        verifier = _newVerifier;
        emit VerifierUpdated(_newVerifier);
    }

    /// @notice Stores an unverified memory proof (no signature required)
    function register(
        bytes32 contentHash,
        string calldata platform,
        string calldata uri,
        string calldata metadata
    ) external returns (uint256) {
        uint256 recordId = ++_recordIdCounter;
        records[recordId] = Record({
            contentHash: contentHash,
            platform: platform,
            handle: "",
            postId: "",
            uri: uri,
            timestamp: block.timestamp,
            metadata: metadata,
            verified: false
        });

        emit Registered(recordId, contentHash, platform, uri, metadata);
        return recordId;
    }

    /// @notice Stores a verified proof (with signature from backend)
    function registerVerified(
        bytes32 contentHash,
        string calldata platform,
        string calldata handle,
        string calldata postId,
        string calldata uri,
        uint256 signedAt,
        bytes calldata signature
    ) external returns (uint256) {
        require(block.timestamp <= signedAt + 10 minutes, "Signature expired");

        bytes32 submissionId = keccak256(abi.encodePacked(postId, contentHash));
        require(!isSubmitted[submissionId], "Proof already submitted");

        // Create digest in EIP-191 format
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encode(
                block.chainid,
                address(this),
                platform,
                handle,
                postId,
                contentHash,
                "PoM",
                signedAt
            ))
        ));

        address recoveredSigner = _recoverSigner(digest, signature);
        require(recoveredSigner == verifier, "Invalid signature");

        isSubmitted[submissionId] = true;
        uint256 recordId = ++_recordIdCounter;

        records[recordId] = Record({
            contentHash: contentHash,
            platform: platform,
            handle: handle,
            postId: postId,
            uri: uri,
            timestamp: signedAt,
            metadata: "",
            verified: true
        });

        emit Verified(recordId, contentHash, platform, handle, postId, uri, signedAt);
        return recordId;
    }

    /// @dev Recovers address from signed digest
    function _recoverSigner(bytes32 digest, bytes memory signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(signature);
        return ecrecover(digest, v, r, s);
    }

    /// @dev Splits a 65-byte signature into r, s, v
    function _split(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) v += 27;
    }
}
