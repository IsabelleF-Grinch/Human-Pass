// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

contract SBTMinimalProxyFactory {
    address public implementation;
    address public deployer;

    mapping(address => address) public userClone; 

    event CloneCreated(address indexed clone);

    constructor(address _implementation){
        implementation = _implementation;
        deployer = msg.sender;
    }

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
