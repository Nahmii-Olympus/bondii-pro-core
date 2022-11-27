
struct AppStorageTreasury {
    address bondPayoutToken;
    address stakingPayoutToken;
    mapping(address => bool) bondContract; 
    mapping(address => bool) stakingContract; 
}