// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/SafeMath.sol";
import "../libraries/SafeERC20.sol";
import "../interfaces/IERC20.sol";
// import "./types/Ownable.sol";

import { AppStorageTreasury } from "../libraries/LibAppStorage.sol";

contract Treasury {
    AppStorageTreasury internal s;

    /**
     * ===================================================
     * ----------------- LIBRARIES -----------------------
     * ===================================================
     */
    
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    /**
     * ===================================================
     * ----------------- EVENTS --------------------------
     * ===================================================
     */
    event BondContractWhitelisted(address bondContract);
    event StakingContractWhitelisted(address stakingContract);
    event BondContractDewhitelisted(address bondContract);
    event StakingContractDewhitelisted(address stakingContract);
    event BondPayoutToken(address, uint);
    event StakingReward(address, uint);

    /**
     *  @notice bond contract recieves payout tokens
     *  @param _payout_token_address address
     *  @param _amountPayoutToken uint
     */
    function sendPayoutTokens(address _payout_token_address, uint _amountPayoutToken) external {
        require(s.bondContract[_payout_token_address], "address is not a bond contract");
        IERC20(s.bondPayoutToken).safeTransfer(msg.sender, _amountPayoutToken);
        emit BondPayoutToken(_payout_token_address, _amountPayoutToken);
    }

    /**
     *  @notice bond contract recieves payout tokens
     *  @param _payout_token_address address
     *  @param _amount uint
     */
    function sendStakingReward(address _payout_token_address, uint _amount) external {
        require(s.stakingContract[_payout_token_address], "address is not a staking contract");
        IERC20(s.stakingPayoutToken).safeTransfer(msg.sender, _amount);
        emit StakingReward(_payout_token_address, _amount);
    }


    /**
        @notice whitelist bond contract
        @param _new_bond address
     */
    function whitelistBondContract(address _new_bond) external {
        s.bondContract[_new_bond] = true;
        emit BondContractWhitelisted(_new_bond);
    }

    /**
        @notice dewhitelist bond contract
        @param _bondContract address
     */
    function dewhitelistBondContract(address _bondContract) external {
        s.bondContract[_bondContract] = false;
        emit BondContractDewhitelisted(_bondContract);
    }

    /**
        @notice whitelist staking contract
        @param _new_staking address
     */
    function whitelistStakingContract(address _new_staking) external {
        s.stakingContract[_new_staking] = true;
        emit StakingContractWhitelisted(_new_staking);
    }

    /**
        @notice dewhitelist staking contract
        @param _stakingContract address
     */
    function dewhitelistStakingContract(address _stakingContract) external {
        s.stakingContract[_stakingContract] = false;
        emit StakingContractDewhitelisted(_stakingContract);
    }
}