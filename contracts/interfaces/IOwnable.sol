// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the Ownable contract.
 */
interface IOwnable {
    function transferManagment(address _newOwner) external;
}