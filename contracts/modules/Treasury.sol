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
        require(_bondPayoutToken != address(0));
        bondPayoutToken = _bondPayoutToken;
        require(_stakingPayoutToken != address(0));
        stakingPayoutToken = _stakingPayoutToken;
    }

    // state variable for Treasury present in the app storage

    /**
     *  @notice bond contract recieves payout tokens
     *  @param _amountPayoutToken uint
     */
    function sendPayoutTokens(uint _amountPayoutToken) external {
        require(bondContract[msg.sender], "address is not a bond contract");
        IERC20(bondPayoutToken).safeTransfer(msg.sender, _amountPayoutToken);
        emit BondPayoutToken(msg.sender, _amountPayoutToken);
    }

    /**
     *  @notice bond contract recieves payout tokens
     *  @param _staking_contract address
     *  @param _amount uint
     */
    function sendStakingReward(address _staking_contract, uint256 _amount) external onlyPolicy {
        IERC20(stakingPayoutToken).safeTransfer(_staking_contract, _amount);
        emit StakingReward(_staking_contract, _amount);
    }

    /**
        @notice whitelist bond contract
        @param _new_bond address
     */
    function whitelistBondContract(address _new_bond) external onlyPolicy {
        bondContract[_new_bond] = true;
        emit BondContractWhitelisted(_new_bond);
    }

    /**
        @notice dewhitelist bond contract
        @param _bondContract address
     */
    function dewhitelistBondContract(address _bondContract) external onlyPolicy {
        bondContract[_bondContract] = false;
        emit BondContractDewhitelisted(_bondContract);
    }

    /**
     *   @notice returns payout token valuation of priciple
     *   @param _principalTokenAddress address
     *   @param _amount uint
     *   @return value_ uint
     */
    function valueOfToken(address _principalTokenAddress, uint _amount) public view returns (uint value_) {
        // convert amount to match payout token decimals
        value_ = _amount.mul(10 ** IERC20(bondPayoutToken).decimals()).div(10 ** IERC20(_principalTokenAddress).decimals());
    }
}



