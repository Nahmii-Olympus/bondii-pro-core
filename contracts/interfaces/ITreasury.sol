// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

interface ITreasury {
    function sendPayoutTokens(address _payout_token_address, uint _amountPayoutToken) external;

    function sendStakingReward(address _payout_token_address, uint _amount) external;

    function whitelistBondContract(address _new_bond) external;

    function dewhitelistBondContract(address _bondContract) external;

    function whitelistStakingContract(address _new_staking) external;

    function dewhitelistStakingContract(address _stakingContract) external;
}