// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Deployed at 0xAD08bB6115c40D7a5064aBF14c7435fC62887c47
contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}
