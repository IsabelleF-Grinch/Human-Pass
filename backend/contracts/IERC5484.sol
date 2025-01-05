// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ERC-5484 Soulbound Token (SBT) Implementation
 * @dev Non-transférable tokens with mint consensus and burn without consensus
 */
interface IERC5484 {
    enum BurnAuth {
    IssuerOnly,
    OwnerOnly,
    Both,
    Neither
}

    event Issued(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId,
    BurnAuth burnAuth
);

    event Revoked(address indexed from, uint256 indexed tokenId);

function mint(
    address to,
    uint256 tokenId,
    BurnAuth burnAuth
) external;

function burn(uint256 tokenId) external;

function burnAuth(uint256 tokenId) external view returns(BurnAuth);
}
