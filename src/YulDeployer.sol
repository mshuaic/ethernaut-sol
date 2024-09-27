// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract YulDeployer is Script {
    ///@notice Compiles a Yul contract and returns the address that the contract
    /// was deployeod to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - The file name of the Yul contract.
    ///@return deployedAddress - The address that the contract was deployed to
    function deployYulContract(string memory fileName)
        public
        returns (address)
    {
        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --strict-assembly ',
            string.concat(fileName, " --bin | tail -1)")
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        bytes memory bytecode = abi.decode(vm.ffi(inputs), (bytes));

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        vm.broadcast();
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "YulDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    function compileYul(string memory fileName) public returns (bytes memory) {
        require(vm.exists(fileName), "File does not exist.");

        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --evm-version=paris --strict-assembly ',
            string.concat(fileName, " --bin | tail -1)")
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        return abi.decode(vm.ffi(inputs), (bytes));
    }

    function deployBytecode(bytes memory bytecode) public returns (address) {
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployedAddress != address(0), "Could not deploy bytecode.");
        return deployedAddress;
    }
}
