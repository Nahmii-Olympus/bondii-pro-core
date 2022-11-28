// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

interface ITreasury {
    function sendPayoutTokens(uint _amountPayoutToken) external;

    function sendStakingReward(address _staking_contract, uint _amount) external;

    function whitelistBondContract(address _new_bond) external;

    function dewhitelistBondContract(address _bondContract) external;

    function valueOfToken( address _principalTokenAddress, uint _amount ) external view returns ( uint value_ );

    function bondPayoutToken() external view returns (address);
}