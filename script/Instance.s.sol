// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Instance} from "../src/Instance.sol";

/**
 *
 * Level address: 0x7E0f53981657345B31C59aC44e9c21631Ce710c7
 *
 */
contract InstanceScript is Attacker {
    Level private level = Level(0x7E0f53981657345B31C59aC44e9c21631Ce710c7);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Instance _instance = Instance(instance);
        _instance.authenticate(_instance.password());

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
