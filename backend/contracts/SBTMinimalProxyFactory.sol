// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

/// @title SBTMinimalProxyFactory
/// @notice Factory contract for creating minimal proxy clones of an implementation contract.
/// @dev Uses OpenZeppelin's Clones library to create minimal proxy contracts (EIP-1167).
contract SBTMinimalProxyFactory {
    /// @notice Address of the implementation contract that will be cloned.
    address public implementation;

    /// @notice Address of the deployer of the factory contract.
    address public deployer;

    /// @notice Mapping to store the address of the clone for each user.
    mapping(address => address) public userClone;

    /// @notice Emitted when a new clone is created.
    /// @param clone The address of the newly created clone.
    event CloneCreated(address indexed clone);

    /// @notice Constructor to initialize the implementation address and set the deployer.
    /// @param _implementation The address of the contract to be cloned.
    constructor(address _implementation) {
        implementation = _implementation;
        deployer = msg.sender;
    }

    /// @notice Creates a new clone of the implementation contract.
    /// @dev Ensures the caller has not already created a clone. Calls the `initialize` function on the clone.
    /// @return newInstance The address of the newly created clone.
    function createNewClone() external returns (address newInstance) {
        require(userClone[msg.sender] == address(0), "You already have instantiated a clone");

        newInstance = Clones.clone(implementation);
        (bool success, ) = newInstance.call(
            abi.encodeWithSignature(
                "initialize(address,address)",
                deployer,
                msg.sender
            )
        );
        require(success, "Proxy initialization failed");

        userClone[msg.sender] = newInstance;

        emit CloneCreated(newInstance);
    }
}
