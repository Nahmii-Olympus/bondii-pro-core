// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "../libraries/SafeMath.sol";
import "../libraries/SafeERC20.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ITreasury.sol";
import "./Ownable.sol";



/// @author @developeruche
/// @author @casweeney
/// @author @olahfemi
/// @author @aagbotemi
/// @author @Adebara123
/// @notice this contract would be used to handle the bonding mechanism, it would be deplyed by the bondii pro factory
contract BondiiProBond is Ownable {
    /**
     * ===================================================
     * ----------------- LIBRARIES -----------------------
     * ===================================================
     */
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    
    /* 
     * ===================================================
     * -------------------- EVENTS -----------------------      
     * ===================================================
     */
    event BondCreated( uint deposit, uint payout, uint expires );
    event BondRedeemed( address recipient, uint payout, uint remaining );
    event BondPriceChanged( uint internalPrice, uint debtRatio );
    event ControlVariableAdjustment( uint initialBCV, uint newBCV, uint adjustment, bool addition );


    /* 
     * ===================================================
     * ------------------- STRUCTS -----------------------      
     * ===================================================
     */

    struct Terms {
        uint256 controlVariable; // scaling variable for price [this is used to control the price of bond to lp_token]
        uint256 vestingTerm; // in blocks
        uint256 minimumPrice; // vs principal value
        uint256 maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint256 maxDebt; // payout token decimal debt ratio, max % total supply created as debt
    }

    // Info for bond holder
    struct Bond {
        uint256 payout; // payout token remaining to be paid
        uint256 vesting; // Blocks left to vest
        uint256 lastBlock; // Last interaction
        uint256 truePricePaid; // Price paid (principal tokens per payout token) in ten-millionths - 4000000 = 0.4
        address principalToken; // this is the pricipal token bonded with
    }

    // Info for incremental adjustments to control variable 
    struct Adjust {
        bool add; // addition or subtraction
        uint256 rate; // increment
        uint256 target; // BCV when adjustment finished
        uint256 buffer; // minimum length (in blocks) between adjustments
        uint256 lastBlock; // block when last adjustment made
    }

    enum PARAMETER { VESTING, PAYOUT, DEBT }


    /* 
     * ===================================================
     * -------------------- STATE VARIABLES --------------      
     * ===================================================
     */

    IERC20 immutable payoutToken; // token paid for principal
    ITreasury immutable customTreasury; // pays for and receives principal
    mapping(address => uint256) totalPrincipalBonded; // stores the total numbers of this lp token that is bonded
    mapping(address => uint256) totalPayoutGiven; // stores the total numbers of this lp token that is bonded
    mapping(address => uint256) totalDebt;
    mapping(address => uint256) lastDecay;
    mapping(address => Terms) terms;
    mapping(address => Adjust) adjustment; // this would be used to change setting of the bond using the pricipal_token(lp) as the key
    mapping( address => Bond ) public bondInfo; // this is and information of the bond a user has made
    mapping(address => bool) bondActive; // this variable would be used to toogle bonding process and 

    


    /// @param _customTreasury: this is the bank where payout token and principal tokens are stored
    /// @param _initialOwner: this is the address of the protocol that has the bond contract
    constructor(
        address _customTreasury, 
        address _initialOwner
    ) {
        require( _customTreasury != address(0) );
        customTreasury = ITreasury( _customTreasury );
        payoutToken = IERC20( ITreasury(_customTreasury).payoutToken());
        require( _initialOwner != address(0) );
        policy = _initialOwner;
    }



    /**
     *  @notice this function is used to add new lp token as pricipal token and to initializes bond parameters
     *  @param _controlVariable uint
     *  @param _vestingTerm uint
     *  @param _minimumPrice uint
     *  @param _maxPayout uint
     *  @param _maxDebt uint
     *  @param _initialDebt uint
     *  @param _newPrincipalToken address
     */
    function initializeBond( 
        uint256 _controlVariable, 
        uint256 _vestingTerm,
        uint256 _minimumPrice,
        uint256 _maxPayout,
        uint256 _maxDebt,
        uint256 _initialDebt,
        address _newPrincipalToken
    ) external onlyPolicy() {
        require( currentDebt(_newPrincipalToken) == 0, "Debt must be 0 for initialization" );
        terms[_newPrincipalToken] = Terms ({
            controlVariable: _controlVariable,
            vestingTerm: _vestingTerm,
            minimumPrice: _minimumPrice,
            maxPayout: _maxPayout,
            maxDebt: _maxDebt
        });
        totalDebt[_newPrincipalToken] = _initialDebt;
        lastDecay[_newPrincipalToken] = block.number;
        bondActive[_newPrincipalToken] = true;
    }


    /**
     *  @notice calculate debt factoring in decay
     *  @return uint
     */
    function currentDebt(address _principalToken) public view returns ( uint ) {
        return totalDebt[_principalToken].sub( debtDecay(_principalToken) );
    }

    /**
     *  @notice amount to decay total debt by
     *  @return decay_ uint
     */
    function debtDecay(address _pricipalToken) public view returns ( uint decay_ ) {
        uint256 blocksSinceLast = block.number.sub( lastDecay[_pricipalToken] );
        decay_ = totalDebt[_pricipalToken].mul( blocksSinceLast ).div( terms[_pricipalToken].vestingTerm );
        if ( decay_ > totalDebt[_pricipalToken] ) {
            decay_ = totalDebt[_pricipalToken];
        }
    }
    
    /**
     *  @notice set parameters for new bonds
     *  @param _parameter PARAMETER
     *  @param _input uint
     */
    function setBondTerms ( PARAMETER _parameter, uint _input, address principalAddress ) external onlyPolicy() {
        if ( _parameter == PARAMETER.VESTING ) { // 0
            require( _input >= 10000, "Vesting must be longer than 36 hours" );
            terms[principalAddress].vestingTerm = _input;
        } else if ( _parameter == PARAMETER.PAYOUT ) { // 1
            require( _input <= 1000, "Payout cannot be above 1 percent" );
            terms[principalAddress].maxPayout = _input;
        } else if ( _parameter == PARAMETER.DEBT ) { // 2
            terms[principalAddress].maxDebt = _input;
        }
    }


    /**
     *  @notice set control variable adjustment
     *  @param _addition bool
     *  @param _increment uint
     *  @param _target uint
     *  @param _buffer uint
     */
    function setAdjustment ( 
        bool _addition,
        uint256 _increment, 
        uint256 _target,
        uint256 _buffer,
        address _principalToken
    ) external onlyPolicy() {
        require( _increment <= terms[_principalToken].controlVariable.mul( 30 ).div( 1000 ), "Increment too large" );

        adjustment[_principalToken] = Adjust({
            add: _addition,
            rate: _increment,
            target: _target,
            buffer: _buffer,
            lastBlock: block.number
        });
    }

    /// @notice this function would be used to toggle the bond state alllowing bonding and disallowing bonding 
    /// @param _principalToken: this is the address of the pricipal token you would like to edit the bonding state
    /// @param _status: this is a bool either true or false 
    function bondToggle(address _principalToken, bool _status) external onlyPolicy {
        bondActive[_principalToken] = _status;
    }

    /**
     *  @notice reduce total debt
     */
    function decayDebt(address _principalToken) internal {
        totalDebt[_principalToken] = totalDebt[_principalToken].sub( debtDecay() );
        lastDecay[_principalToken] = block.number;
    }



    /**
     *  @notice deposit bond
     *  @param _amount uint
     *  @param _depositor address
     *  @return uint
     */
    function deposit(uint256 _amount, address _depositor, address _principalToken) external returns (uint) {
        require( _depositor != address(0), "Invalid address" );
        require(bondActive[_principalToken], "Bond not active");

        decayDebt(_principalToken);



        uint value = customTreasury.valueOfToken( address(principalToken), _amount );

        uint payout;
        uint fee;

        if(feeInPayout) {
            (payout, fee) = payoutFor( value ); // payout and fee is computed
        } else {
            (payout, fee) = payoutFor( _amount ); // payout and fee is computed
            _amount = _amount.sub(fee);
        }

        require( payout >= 10 ** payoutToken.decimals() / 100, "Bond too small" ); // must be > 0.01 payout token ( underflow protection )
        require( payout <= maxPayout(), "Bond too large"); // size protection because there is no slippage
        
        // total debt is increased
        totalDebt = totalDebt.add( value );

        require( totalDebt <= terms.maxDebt, "Max capacity reached" );
                
        // depositor info is stored
        bondInfo[ _depositor ] = Bond({ 
            payout: bondInfo[ _depositor ].payout.add( payout ),
            vesting: terms.vestingTerm,
            lastBlock: block.number,
            truePricePaid: trueBondPrice()
        });

        totalPrincipalBonded = totalPrincipalBonded.add(_amount); // total bonded increased
        totalPayoutGiven = totalPayoutGiven.add(payout); // total payout increased
        payoutSinceLastSubsidy = payoutSinceLastSubsidy.add( payout ); // subsidy counter increased

        if(feeInPayout) {
            customTreasury.sendPayoutTokens( payout.add(fee) );
            if(fee != 0) { // if fee, send to Olympus treasury
                payoutToken.safeTransfer(olympusTreasury, fee);
            }
        } else {
            customTreasury.sendPayoutTokens( payout );
            if(fee != 0) { // if fee, send to Olympus treasury
                principalToken.safeTransferFrom( msg.sender, olympusTreasury, fee );
            }
        }

        principalToken.safeTransferFrom( msg.sender, address(customTreasury), _amount ); // transfer principal bonded to custom treasury

        // indexed events are emitted
        emit BondCreated( _amount, payout, block.number.add( terms.vestingTerm ) );
        emit BondPriceChanged( _bondPrice(), debtRatio() );

        adjust(); // control variable is adjusted
        return payout; 
    }
    
}