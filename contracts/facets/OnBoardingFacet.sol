// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BondiiProBond} from "../modules/Bond.sol";
import {StakingRewards} from "../modules/staking.sol";
import {Treasury} from "../modules/Treasury.sol";
import {OnBoarding, OnBoardAddress} from "../libraries/LibAppStorage.sol";

/// @notice this contract would be used to onboard new protocol in the application
contract OnBoardingFacet {
    OnBoarding internal ob;

    event TreasuryDeployed(address treasury_addr, address _bondPayoutToken, address _stakingPayoutToken, uint256 time);
    event StakingDeployed(address staking_addr, address owner, address _rewardsDistribution, address _rewardsToken, uint time);
    event BondDeployed(address bond_addr, address treasury_addr, uint256 time);

    /// @notice this function would be used to change the address of the a protocol
    /// @dev this function would be guided with access control and this function would have the power to change protocol address in other depending contract
    /// @param _addr: this the new address of the protocol
    function change_protocol_address(address _addr) external {
        onlyDAO;
        ob.bondiiTreasury = _addr;
    }

    /// @dev this function will be access control to change protocol address in other depending contract
    function onlyDAO() internal view {
        require(ob.bondiiDA0 == msg.sender, "caller is not the DAO");
    }

    /// @notice this function would be used to create bond, treasury and staking of the a protocol
    /// @dev this function would be guided with access control and this function would have the power to change protocol address in other depending contract
    /// @param _bondPayoutToken: this the address of the bond payout token
    /// @param _stakingPayoutToken: this the address of the staking payout token
    /// @param _rewardsDistribution: this the address of the rewards distribution
    /// @param _rewardsToken: this the address of the rewards token
    /// @param _rewardsDuration: this the time frame of the rewards
    /// @param _protocolAddress: this the address of the protocol
    function createBondTreasuryStaking(
        address _bondPayoutToken,
        address _stakingPayoutToken, // i used this in treasury and staking
        address _rewardsDistribution,
        address _rewardsToken,
        uint256 _rewardsDuration,
        address _protocolAddress
    ) external {
        Treasury _treasury = new Treasury(_bondPayoutToken, _stakingPayoutToken);
        StakingRewards _staking = new StakingRewards(msg.sender, _rewardsDistribution, _rewardsToken, _stakingPayoutToken, _rewardsDuration);
        BondiiProBond _bond = new BondiiProBond(address(_treasury), msg.sender);

        OnBoardAddress memory ob_addr = ob.protocolOnBoard[_protocolAddress];
        ob_addr.treasury = address(_treasury);
        ob_addr.staking = address(_staking);
        ob_addr.bond = address(_bond);

        emit TreasuryDeployed(address(_treasury), _bondPayoutToken, _stakingPayoutToken, block.timestamp);
        emit StakingDeployed(address(_staking), msg.sender, address(_rewardsDistribution), address(_rewardsToken), block.timestamp);
        emit BondDeployed(address(_bond), address(_treasury), block.timestamp);
    }
}
