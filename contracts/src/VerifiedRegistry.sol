// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VerifiedRegistry
 * @dev A contract to anchor proofs of social media content on-chain,
 * with a mechanism for a trusted verifier to attest to content authenticity.
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
        string handle,
        string postId,
        string uri,
        uint256 timestamp
    );
    
    event VerifierUpdated(address indexed newVerifier);

    constructor(address initialVerifier) Ownable(msg.sender) {
        verifier = initialVerifier;
    }

    /**
     * @dev Updates the trusted verifier address. Only callable by the owner.
     * @param _newVerifier The address of the new verifier.
     */
    function setVerifier(address _newVerifier) external onlyOwner {
        require(_newVerifier != address(0), "VerifiedRegistry: New verifier is the zero address");
        verifier = _newVerifier;
        emit VerifierUpdated(_newVerifier);
    }

    /**
     * @dev Registers an unverified piece of content.
     * @param contentHash The Keccak-256 hash of the content.
     * @param platform The social media platform (e.g., "instagram").
     * @param uri A URI pointing to the content.
     * @param metadata Optional JSON metadata.
     * @return recordId The ID of the newly created record.
     */
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

    /**
     * @dev Registers content verified by a trusted off-chain source.
     * @param contentHash The Keccak-256 hash of the content.
     * @param handle The user's handle on the platform.
     * @param postId The unique identifier for the post.
     * @param uri A URI pointing to the content.
     * @param timestamp The Unix timestamp of when the proof was generated.
     * @param signature The verifier's signature.
     * @return recordId The ID of the newly created verified record.
     */
    function registerVerified(
        bytes32 contentHash,
        string calldata handle,
        string calldata postId,
        string calldata uri,
        uint256 timestamp,
        bytes calldata signature
    ) external returns (uint256) {
        bytes32 submissionId = keccak256(abi.encodePacked(postId, contentHash));
        require(!isSubmitted[submissionId], "VerifiedRegistry: Proof already submitted");

        bytes32 digest = _getVerificationDigest(contentHash, handle, postId, timestamp);
        address recoveredSigner = _recoverSigner(digest, signature);

        require(recoveredSigner == verifier, "VerifiedRegistry: Invalid signature");

        isSubmitted[submissionId] = true;
        uint256 recordId = ++_recordIdCounter;

        records[recordId] = Record({
            contentHash: contentHash,
            platform: "twitter",
            handle: handle,
            postId: postId,
            uri: uri,
            timestamp: timestamp,
            metadata: "",
            verified: true
        });

        emit Verified(recordId, contentHash, handle, postId, uri, timestamp);
        return recordId;
    }
    
    /**
     * @dev Constructs the EIP-191 digest for signature verification.
     */
    function _getVerificationDigest(
        bytes32 contentHash,
        string calldata handle,
        string calldata postId,
        uint256 timestamp
    ) internal view returns (bytes32) {
        bytes32 messageHash = keccak256(
            abi.encode(
                block.chainid,
                address(this),
                handle,
                "twitter",
                postId,
                contentHash,
                "PoM",
                timestamp
            )
        );
        // EIP-191 Version 'E' ('\x45')
        return keccak256(abi.encodePacked("\x19\x01",_getDomainSeparator(), messageHash));
    }

    /**
     * @dev Returns the EIP-712 domain separator.
     */
    function _getDomainSeparator() internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version)"),
                keccak256(bytes("ProofOfMoments")),
                keccak256(bytes("1"))
            )
        );
    }


    /**
     * @dev Recovers the signer's address from a digest and signature.
     */
    function _recoverSigner(bytes32 digest, bytes memory signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(signature);
        return ecrecover(digest, v, r, s);
    }

    /**
     * @dev Splits a signature into its r, s, and v components.
     */
    function _split(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(signature.length == 65, "VerifiedRegistry: Invalid signature length");
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}
