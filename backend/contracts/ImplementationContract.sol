// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ImplementationContract is Initializable, AccessControl{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function initialize(address _admin) external initializer {
        _grantRole(ADMIN_ROLE, _admin); 
    }
}