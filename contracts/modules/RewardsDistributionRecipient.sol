// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Pausable} from "./Pausable.sol";



contract RewardsDistributionRecipient is Pausable {
    address public rewardsDistribution;

    constructor(address _initial_owner) Pausable(_initial_owner) {
    }
 
    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}