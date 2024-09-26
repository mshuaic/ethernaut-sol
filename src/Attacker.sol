// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Ethernaut} from "ethernaut/Ethernaut.sol";
import {Level} from "ethernaut/levels/base/Level.sol";
import {Utils} from "./Utils.sol";

abstract contract Attacker is Script, Utils {
    uint256 private deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    Vm.Wallet internal me = vm.createWallet(deployerPrivateKey);

    address payable private ETHERNAUT_ADDR =
        payable(vm.envAddress("ETHERNAUT_ADDR"));

    Ethernaut public ethernaut = Ethernaut(ETHERNAUT_ADDR);

    address private instance;

    // TODO: remove this function
    function getNewLevelInstance(Level _level)
        public
        payable
        returns (address)
    {
        vm.recordLogs();
        ethernaut.createLevelInstance{value: msg.value}(_level);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        (bool eventExists, uint256 index) = checkIfEventExists(
            entries, "LevelInstanceCreatedLog(address,address,address)"
        );
        require(eventExists, "Event not found");
        instance = bytes32ToAddress(entries[index].topics[2]);
        return instance;
    }

    function getNewLevelInstance(
        Level _level,
        uint256 value
    )
        public
        returns (address)
    {
        vm.recordLogs();
        ethernaut.createLevelInstance{value: value}(_level);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        (bool eventExists, uint256 index) = checkIfEventExists(
            entries, "LevelInstanceCreatedLog(address,address,address)"
        );
        require(eventExists, "Event not found");
        instance = bytes32ToAddress(entries[index].topics[2]);
        return instance;
    }

    function submitInstance() public returns (bool) {
        vm.recordLogs();
        ethernaut.submitLevelInstance(payable(instance));
        Vm.Log[] memory entries = vm.getRecordedLogs();

        (bool eventExists,) = checkIfEventExists(
            entries, "LevelCompletedLog(address,address,address)"
        );
        return eventExists;
    }
}
