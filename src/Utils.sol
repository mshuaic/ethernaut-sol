// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.7 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

abstract contract Utils is Script {
    function bytes32ToAddress(bytes32 input) internal pure returns (address) {
        return address(uint160(uint256(input)));
    }

    function getBlockNumRPC() public returns (uint256) {
        bytes memory ret = vm.rpc("eth_blockNumber", "[]");
        return bytesToUint(ret);
    }

    function waitNumBlocks(
        uint256 numberBlocks,
        uint256 sleepTime
    )
        public
        returns (uint256)
    {
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

    function checkIfEventExists(
        Vm.Log[] memory entries,
        bytes memory eventSignature
    )
        public
        pure
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].topics.length == 4) {
                if (entries[i].topics[0] == keccak256(eventSignature)) {
                    return (true, i);
                }
            }
        }
        return (false, type(uint256).max);
    }
}
