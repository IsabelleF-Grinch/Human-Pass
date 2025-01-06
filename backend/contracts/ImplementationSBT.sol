// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./IERC5484.sol";

contract ImplementationSBT is Initializable, AccessControlEnumerable, IERC5484, ERC721 {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(uint256 => BurnAuth) private _burnAuths; 
    mapping(uint256 => uint256) private _issuedAt; 
    mapping(address => uint256) public addressToTokenId;

    //uint256 public constant VALIDITY_PERIOD = 90 days;

    constructor() ERC721("HumanPassSBT", "HP-SBT") {}

    modifier onlyAdminOrBurner() {
        require(
            hasRole(ADMIN_ROLE, msg.sender) || hasRole(BURNER_ROLE, msg.sender),
            "Access denied: must have both ADMIN or BURNER role"
        );
        _;
    }

    function initialize(address _admin, address _user) external initializer {
        require(_admin != address(0), "Admin address cannot be zero");
        require(_user != address(0), "User address cannot be zero");
    
        _grantRole(ADMIN_ROLE, _admin);
 
        _grantRole(MINTER_ROLE, _user);
        _grantRole(BURNER_ROLE, _user);
    }
    
    function transferAdminRole(address newAdmin) public onlyRole(ADMIN_ROLE) {
        address currentAdmin = getRoleMember(ADMIN_ROLE, 0);

        require(newAdmin != address(0), "New admin cannot be the zero address");
        require(!hasRole(ADMIN_ROLE, newAdmin), "Address is already an admin");
        require(currentAdmin == msg.sender, "Only the current admin can transfer the admin role");

        renounceRole(ADMIN_ROLE, currentAdmin);
    
        require(getRoleMemberCount(ADMIN_ROLE) == 0, "Admin renounce failed");
        grantRole(ADMIN_ROLE, newAdmin);
    }

    // function _assignRole(bytes32 role, address account) internal onlyRole(ADMIN_ROLE) {
    //     if (role == ADMIN_ROLE) {
    //         require(
    //             getRoleMemberCount(ADMIN_ROLE) == 0,
    //             "An admin already exists"
    //         );
    //     }
    //     _grantRole(role, account); 
    // }

    function transferFrom(address, address, uint256) public pure override{
        revert("SBT: transfer not allowed");
    }

    function mint(
        address to, //must be equal the minter address
        uint256 tokenId,
        BurnAuth burnAuth_
    ) external override onlyRole(MINTER_ROLE) {
        require(_ownerOf(tokenId) == address(0), "Token already exists");
        require(to == msg.sender, "Minter must mint for themselves");
        require(to != address(0), "Cannot mint to zero address");

        _mint(to, tokenId);
        _burnAuths[tokenId] = burnAuth_;
        _issuedAt[tokenId] = block.timestamp; //to check security
        addressToTokenId[to] = tokenId;

        emit Issued(msg.sender, to, tokenId, burnAuth_);
    }

    function burn(uint256 tokenId) external override onlyAdminOrBurner{
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

    //TODO Automate revocation for tokens expired
    // function revokeExpiredTokens(uint256 tokenId) external {
    //     require(_ownerOf(tokenId) != address(0), "Token does not exist");
    //     require(block.timestamp >= _issuedAt[tokenId] + VALIDITY_PERIOD, "Token still valid");

    //     _burn(tokenId);
    //     delete _burnAuths[tokenId];
    //     delete _issuedAt[tokenId];

    //     emit Revoked(msg.sender, tokenId);
    // }

    function burnAuth(uint256 tokenId) external view override returns (BurnAuth) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return _burnAuths[tokenId];
    }

    function getTokenIdByAddress(address user) public view returns (uint256) {
        uint256 tokenId = addressToTokenId[user];
        require(tokenId != 0, "No token found for this address");

        return tokenId;
    }

   function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControlEnumerable) returns (bool) {
        return 
            interfaceId == type(IERC5484).interfaceId || 
            super.supportsInterface(interfaceId);
    }

}