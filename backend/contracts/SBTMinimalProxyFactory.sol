// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

contract SBTMinimalProxyFactory {
    address public implementation;
    address[] public clonesList;

    event CloneCreated(address indexed clone);

    constructor(address _implementation){
        implementation = _implementation;
    }

    function createNewClone() external returns (address newInstance) {
        newInstance = Clones.clone(implementation);
        (bool success, ) = newInstance.call(
            abi.encodeWithSignature("initialize(address)", msg.sender)
        );
        require(success, "Proxy initialization failed");

        clonesList.push(newInstance);
        emit CloneCreated(newInstance);
    }

    function getClones() external view returns (address[] memory) {
        return clonesList;
    }
}
