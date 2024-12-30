// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ImplementationContract.sol";

contract MinimalProxyFactory {

   using Clones for address;

    address public implementation;

    event ProxyCreated(address proxy);

    constructor(address _implementation) {
        require(_implementation != address(0), "Implementation cannot be zero address");
        implementation = _implementation;
    }

    function createProxy(address admin) external returns (address) {
        address proxyDeployed = implementation.clone();
        ImplementationContract(proxyDeployed).initialize(admin); 
        emit ProxyCreated(proxyDeployed);
        return proxyDeployed;
    }
}
