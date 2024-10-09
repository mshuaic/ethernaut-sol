// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
// import {Motorbike} from "../src/Motorbike.sol";

/**
 *
 * Level address: 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6
 * Ethernaut's motorbike has a brand new upgradeable engine design.
 *
 * Would you be able to selfdestruct its engine and make the motorbike unusable
 * ?
 *
 * Things that might help:
 *
 * EIP-1967
 * UUPS upgradeable pattern
 * Initializable contract
 *
 */
abstract contract Motorbike {
    address public upgrader;
    uint256 public horsePower;

    // engine functions
    function initialize() external virtual;
    function upgradeToAndCall(address, bytes memory) external payable virtual;
}

abstract contract Engine {
    address public upgrader;
    uint256 public horsePower;

    function initialize() external virtual;
    function upgradeToAndCall(address, bytes memory) external payable virtual;
}

contract MotorbikeScript is Attacker {
    Level private level = Level(0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);

        // currently not solvable using EOA, due to:
        // https://github.com/OpenZeppelin/ethernaut/issues/701
        // try again after https://eips.ethereum.org/EIPS/eip-7702

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
