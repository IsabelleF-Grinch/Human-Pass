// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./IERC5484.sol";

contract ImplementationSBT is Initializable, AccessControl, IERC5484 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    mapping(uint256 => address) private _owners;
    mapping(uint256 => BurnAuth) private _burnAuths;

    function initialize(address _admin) external initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(
        address to,
        uint256 tokenId,
        BurnAuth burnAuth_
    ) external override onlyRole(MINTER_ROLE) {
        require(_owners[tokenId] == address(0), "Token already exists");
        require(to != address(0), "Cannot mint to zero address");

        _owners[tokenId] = to;
        _burnAuths[tokenId] = burnAuth_;

        emit Issued(msg.sender, to, tokenId, burnAuth_);
    }

    function burn(uint256 tokenId) external override {
        require(_owners[tokenId] != address(0), "Token does not exist");

        BurnAuth auth = _burnAuths[tokenId];
        address owner = _owners[tokenId];

        if (auth == BurnAuth.IssuerOnly) {
            require(hasRole(MINTER_ROLE, msg.sender), "Only issuer can burn");
        } else if (auth == BurnAuth.OwnerOnly) {
            require(msg.sender == owner, "Only owner can burn");
        } else if (auth == BurnAuth.Both) {
            require(
                msg.sender == owner || hasRole(MINTER_ROLE, msg.sender),
                "Only owner or issuer can burn"
            );
        } else if (auth == BurnAuth.Neither) {
            revert("Burning is not allowed for this token");
        }

        delete _owners[tokenId];
        delete _burnAuths[tokenId];

        emit Revoked(owner, tokenId);
    }

    function burnAuth(uint256 tokenId) external view override returns (BurnAuth) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _burnAuths[tokenId];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }
}