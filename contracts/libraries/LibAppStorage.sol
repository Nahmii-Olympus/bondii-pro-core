// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct OnBoardAddress {
    address treasury;
    address staking;
    address bond;
}

struct OnBoarding {
    address bondiiProFactoryStorage;
    address bondiiProSubsidyRouter;
    address stakingFactory;
    address bondiiTreasury;
    address bondiiDA0;

    mapping (address => OnBoardAddress) protocolOnBoard;
}