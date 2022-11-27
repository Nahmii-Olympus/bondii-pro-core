// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/SafeMath.sol";
import "../libraries/SafeERC20.sol";
import "../interfaces/IERC20.sol";
import "./Ownable.sol";

contract Treasury is Ownable {

    /**
     * ===================================================
     * ----------------- LIBRARIES -----------------------
     * ===================================================
     */
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    /**
     * ===================================================
     * ----------------- STATE VARIABLE ------------------
     * ===================================================
     */
    address public immutable bondPayoutToken;
    address public immutable stakingPayoutToken;
    mapping(address => bool) public bondContract; 
    mapping(address => bool) public stakingContract;

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


    /// @param _bondPayoutToken: This is the token that would be used to pay the user who purchases the bond
    /// @param _stakingPayoutToken: This is the token that would be used to pay the user who stakes
    constructor(address _bondPayoutToken, address _stakingPayoutToken) {
        require( _bondPayoutToken != address(0) );
        bondPayoutToken = _bondPayoutToken;
        require( _stakingPayoutToken != address(0) );
        stakingPayoutToken = _stakingPayoutToken;   
    }



        // state variable for Treasury present in the app storage

    /**
     *  @notice bond contract recieves payout tokens
     *  @param _payout_token_address address
     *  @param _amountPayoutToken uint
     */
    function sendPayoutTokens(address _payout_token_address, uint _amountPayoutToken) external {
        require(bondContract[_payout_token_address], "address is not a bond contract");
        IERC20(bondPayoutToken).safeTransfer(msg.sender, _amountPayoutToken);
        emit BondPayoutToken(_payout_token_address, _amountPayoutToken);
    }

    /**
     *  @notice bond contract recieves payout tokens
     *  @param _payout_token_address address
     *  @param _amount uint
     */
    function sendStakingReward(address _payout_token_address, uint _amount) external {
        require(stakingContract[_payout_token_address], "address is not a staking contract");
        IERC20(stakingPayoutToken).safeTransfer(msg.sender, _amount);
        emit StakingReward(_payout_token_address, _amount);
    }


    /**
        @notice whitelist bond contract
        @param _new_bond address
     */
    function whitelistBondContract(address _new_bond) external onlyPolicy() {
        bondContract[_new_bond] = true;
        emit BondContractWhitelisted(_new_bond);
    }

    /**
        @notice dewhitelist bond contract
        @param _bondContract address
     */
    function dewhitelistBondContract(address _bondContract) external onlyPolicy() {
        bondContract[_bondContract] = false;
        emit BondContractDewhitelisted(_bondContract);
    }

    /**
        @notice whitelist staking contract
        @param _new_staking address
     */
    function whitelistStakingContract(address _new_staking) external onlyPolicy() {
        stakingContract[_new_staking] = true;
        emit StakingContractWhitelisted(_new_staking);
    }

    /**
        @notice dewhitelist staking contract
        @param _stakingContract address
     */
    function dewhitelistStakingContract(address _stakingContract) external onlyPolicy() {
        stakingContract[_stakingContract] = false;
        emit StakingContractDewhitelisted(_stakingContract);
    }
}