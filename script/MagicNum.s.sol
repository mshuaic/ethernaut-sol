// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {MagicNum} from "../src/MagicNum.sol";

/**
 *
 * Level address: 0x2132C7bc11De7A90B87375f282d36100a29f97a9
 * To solve this level, you only need to provide the Ethernaut with a Solver, a
 * contract that responds to whatIsTheMeaningOfLife() with the right 32 byte
 * number.
 *
 * Easy right? Well... there's a catch.
 *
 * The solver's code needs to be really tiny. Really reaaaaaallly tiny. Like
 * freakin' really really itty-bitty tiny: 10 bytes at most.
 *
 * Hint: Perhaps its time to leave the comfort of the Solidity compiler
 * momentarily, and build this one by hand O_o. That's right: Raw EVM bytecode.
 *
 * Good luck!
 *
 */
contract MagicNumScript is Attacker {
    Level private level = Level(0x2132C7bc11De7A90B87375f282d36100a29f97a9);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        MagicNum magicNum = MagicNum(instance);

        bytes memory bytecode = compileYul("src/yul/MagicNum/Solver.yul");

        address solver = deployBytecode(bytecode);
        magicNum.setSolver(solver);

        (bool success,) = address(solver).call(
            abi.encodeWithSignature("whatIsTheMeaningOfLife()")
        );
        require(success, "Solver failed");

        uint256 size;
        assembly {
            size := extcodesize(solver)
        }
        require(size <= 10, "Solver is too big");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
