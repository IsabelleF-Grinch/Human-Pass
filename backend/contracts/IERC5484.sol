// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ERC-5484 Soulbound Token (SBT) Interface
 * @dev Interface for a non-transferable SBT with mint and burn authorizations, using EIP-712 signatures
 */
interface IERC5484 {
    enum BurnAuth {
        IssuerOnly,  // Only the issuer can revoke
        OwnerOnly,   // Only the owner can revoke
        Both,        // Both the issuer and the owner can revoke
        Neither      // No one can revoke (permanent token)
    }

    /// @notice Emitted when an SBT is issued
    /// @param from Address of the issuer
    /// @param to Address of the recipient
    /// @param tokenId Unique identifier of the SBT
    /// @param burnAuth Authorization level for revoking the SBT
    event Issued(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        BurnAuth burnAuth
    );

    /// @notice Emitted when an SBT is revoked
    /// @param by Address that initiated the revocation
    /// @param tokenId Unique identifier of the revoked SBT
    event Revoked(address indexed by, uint256 indexed tokenId);

    /**
     * @dev Function to issue an SBT 
     * @param to Address of the recipient of the SBT
     * @param tokenId Unique identifier of the SBT
     * @param burnAuth Authorization level for revoking the SBT
     */
    function mint(
        address to,
        uint256 tokenId,
        BurnAuth burnAuth
    ) external;

    /**
     * @dev Function to revoke (burn) an SBT
     * @param tokenId Unique identifier of the SBT to be revoked
     */
    function burn(uint256 tokenId) external;

    /**
     * @dev Returns the burn authorization level for a given SBT
     * @param tokenId Unique identifier of the SBT
     * @return burnAuth Authorization level for revoking the SBT
     */
    function burnAuth(uint256 tokenId) external view returns (BurnAuth);
}
