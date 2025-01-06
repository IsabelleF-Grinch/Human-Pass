// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./IERC5484.sol";

/// @title ImplementationSBT
/// @notice Implementation of a Soulbound Token (SBT) compliant with the IERC5484 standard.
/// @dev The contract is upgradeable using the Initializable pattern and includes role-based access control.
contract ImplementationSBT is Initializable, AccessControlEnumerable, IERC5484, ERC721 {

    /// @notice Role for accounts that can mint SBTs.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role for accounts that can burn SBTs.
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @notice Role for the administrator of the contract.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Mapping of token IDs to their burn authorization.
    mapping(uint256 => BurnAuth) private _burnAuths;

    /// @notice Mapping of token IDs to their issuance timestamp.
    mapping(uint256 => uint256) private _issuedAt;

    /// @notice Mapping of addresses to their corresponding token ID.
    mapping(address => uint256) public addressToTokenId;

    /// @dev Constructor for setting the token name and symbol.
    constructor() ERC721("HumanPassSBT", "HP-SBT") {}

    /// @notice Modifier to restrict function access to admins or burners.
    modifier onlyAdminOrBurner() {
        require(
            hasRole(ADMIN_ROLE, msg.sender) || hasRole(BURNER_ROLE, msg.sender),
            "Access denied: must have ADMIN or BURNER role"
        );
        _;
    }

    /// @notice Initializes the contract with admin and user roles.
    /// @param _admin Address of the admin.
    /// @param _user Address of the user who receives minter and burner roles.
    function initialize(address _admin, address _user) external initializer {
        require(_admin != address(0), "Admin address cannot be zero");
        require(_user != address(0), "User address cannot be zero");

        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _user);
        _grantRole(BURNER_ROLE, _user);
    }

    /// @notice Transfers the admin role to a new address.
    /// @param newAdmin Address of the new admin.
    function transferAdminRole(address newAdmin) public onlyRole(ADMIN_ROLE) {
        address currentAdmin = getRoleMember(ADMIN_ROLE, 0);

        require(newAdmin != address(0), "New admin cannot be the zero address");
        require(!hasRole(ADMIN_ROLE, newAdmin), "Address is already an admin");
        require(currentAdmin == msg.sender, "Only the current admin can transfer the admin role");

        renounceRole(ADMIN_ROLE, currentAdmin);
        require(getRoleMemberCount(ADMIN_ROLE) == 0, "Admin renounce failed");
        _grantRole(ADMIN_ROLE, newAdmin);
    }

    /// @notice Prevents transfer of Soulbound Tokens (SBT).
    function transferFrom(address, address, uint256) public pure override {
        revert("SBT: transfer not allowed");
    }

    /// @notice Mints a new SBT.
    /// @param to Address of the minter (must be the same as `msg.sender`).
    /// @param tokenId ID of the token to be minted.
    /// @param burnAuth_ Burn authorization type for the token.
    function mint(
        address to,
        uint256 tokenId,
        BurnAuth burnAuth_
    ) external override onlyRole(MINTER_ROLE) {
        require(_ownerOf(tokenId) == address(0), "Token already exists");
        require(to == msg.sender, "Minter must mint for themselves");
        require(to != address(0), "Cannot mint to zero address");

        _mint(to, tokenId);
        _burnAuths[tokenId] = burnAuth_;
        _issuedAt[tokenId] = block.timestamp;
        addressToTokenId[to] = tokenId;

        emit Issued(msg.sender, to, tokenId, burnAuth_);
    }

    /// @notice Burns an SBT based on its burn authorization.
    /// @param tokenId ID of the token to be burned.
    function burn(uint256 tokenId) external override onlyAdminOrBurner {
        address owner = ownerOf(tokenId);
        BurnAuth auth = _burnAuths[tokenId];

        if (auth == BurnAuth.IssuerOnly) {
            require(hasRole(MINTER_ROLE, msg.sender), "Only issuer can burn");
        } else if (auth == BurnAuth.OwnerOnly) {
            require(msg.sender == owner, "Only owner can burn");
        } else if (auth == BurnAuth.Both) {
            require(
                hasRole(ADMIN_ROLE, msg.sender) || hasRole(MINTER_ROLE, msg.sender),
                "Only owner or issuer can burn"
            );
        } else if (auth == BurnAuth.Neither) {
            revert("Burning is not allowed for this token");
        }

        _burn(tokenId);
        delete _burnAuths[tokenId];
        delete _issuedAt[tokenId];

        emit Revoked(owner, tokenId);
    }

    /// @notice Returns the burn authorization type of a given token.
    /// @param tokenId ID of the token.
    /// @return BurnAuth Type of burn authorization.
    function burnAuth(uint256 tokenId) external view override returns (BurnAuth) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return _burnAuths[tokenId];
    }

    /// @notice Returns the token ID associated with an address.
    /// @param user Address of the user.
    /// @return uint256 ID of the token associated with the address.
    function getTokenIdByAddress(address user) public view returns (uint256) {
        uint256 tokenId = addressToTokenId[user];
        require(tokenId != 0, "No token found for this address");
        return tokenId;
    }

    /// @notice Indicates whether the contract implements a given interface.
    /// @param interfaceId ID of the interface to check.
    /// @return bool True if the interface is supported, false otherwise.
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControlEnumerable) returns (bool) {
        return
            interfaceId == type(IERC5484).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
