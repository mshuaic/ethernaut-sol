// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Level} from "ethernaut/levels/base/Level.sol";
import {Vm, console, Attacker} from "../src/Attacker.sol";
import {
    DoubleEntryPoint,
    CryptoVault,
    IDetectionBot,
    Forta
} from "../src/DoubleEntryPoint.sol";

/**
 *
 * Level address: 0x34bD06F195756635a10A7018568E033bC15F3FB5
 * This level features a CryptoVault with special functionality, the sweepToken
 * function. This is a common function used to retrieve tokens stuck in a
 * contract. The CryptoVault operates with an underlying token that can't be
 * swept, as it is an important core logic component of the CryptoVault. Any
 * other tokens can be swept.
 *
 * The underlying token is an instance of the DET token implemented in the
 * DoubleEntryPoint contract definition and the CryptoVault holds 100 units of
 * it. Additionally the CryptoVault also holds 100 of LegacyToken LGT.
 *
 * In this level you should figure out where the bug is in CryptoVault and
 * protect it from being drained out of tokens.
 *
 * The contract features a Forta contract where any user can register its own
 * detection bot contract. Forta is a decentralized, community-based monitoring
 * network to detect threats and anomalies on DeFi, NFT, governance, bridges and
 * other Web3 systems as quickly as possible. Your job is to implement a
 * detection bot and register it in the Forta contract. The bot's implementation
 * will need to raise correct alerts to prevent potential attacks or bug
 * exploits.
 *
 * Things that might help:
 *
 * How does a double entry point work for a token contract?
 *
 */
contract PawnBot is IDetectionBot {
    Forta public forta;
    CryptoVault public cryptoVault;

    constructor(Forta _forta, CryptoVault _cryptoVault) {
        forta = _forta;
        cryptoVault = _cryptoVault;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        bytes4 sig = bytes4(msgData[:4]);

        if (
            sig
                != bytes4(keccak256("delegateTransfer(address,uint256,address)"))
        ) return;

        (,, address origSender) =
            abi.decode(msgData[4:], (address, uint256, address));

        if (origSender == address(cryptoVault)) {
            forta.raiseAlert(user);
        }
    }
}

contract DoubleEntryPointScript is Attacker {
    Level private level = Level(0x34bD06F195756635a10A7018568E033bC15F3FB5);

    function run() external {
        vm.startBroadcast(me.privateKey);
        address instance = getNewLevelInstance(level);
        DoubleEntryPoint doubleEntryPoint = DoubleEntryPoint(instance);
        CryptoVault cryptoVault = CryptoVault(doubleEntryPoint.cryptoVault());
        Forta forta = Forta(doubleEntryPoint.forta());

        PawnBot pawnBot = new PawnBot(forta, cryptoVault);
        forta.setDetectionBot(address(pawnBot));

        // expect to fail
        // cryptoVault.sweepToken(legacyToken);

        require(submitInstance(), "Level submission failed");
        vm.stopBroadcast();
    }
}
