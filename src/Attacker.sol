// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.7 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract Attacker is Script {
    uint256 private deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    Vm.Wallet internal me = vm.createWallet(deployerPrivateKey);
    // address myAddress = me.addr;

    function getBlockNumRPC() public returns (uint256) {
        bytes memory ret = vm.rpc("eth_blockNumber", "[]");
        return bytesToUint(ret);
    }

    function waitNumBlocks(uint256 numberBlocks, uint256 sleepTime) public returns (uint256) {
        uint256 startNumber = getBlockNumRPC();
        while (true) {
            uint256 currNumber = getBlockNumRPC();
            if (currNumber >= startNumber + numberBlocks) {
                return currNumber;
            }
            console.log("Current block number: ", currNumber);
            console.log("Target block number: ", startNumber + numberBlocks);
            console.log("Waiting for the target block...");
            console.log("Sleeping for %d milliseconds...", sleepTime);
            vm.sleep(sleepTime);
        }
        return 0;
    }
}
