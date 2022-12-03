// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "../libraries/SafeMath.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/FixedPoint.sol";
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
    using FixedPoint for *;

    
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
    mapping( address => Bond[] ) public bondInfo; // this is and information of the bond a user has made
    mapping(address => bool) bondActive; // this variable would be used to toogle bonding process and 

    


    /// @param _customTreasury: this is the bank where payout token and principal tokens are stored
    /// @param _initialOwner: this is the address of the protocol that has the bond contract
    constructor(
        address _customTreasury, 
        address _initialOwner
    ) {
        require( _customTreasury != address(0) );
        customTreasury = ITreasury( _customTreasury );
        payoutToken = IERC20( ITreasury(_customTreasury).bondPayoutToken());
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
        totalDebt[_principalToken] = totalDebt[_principalToken].sub( debtDecay(_principalToken) );
        lastDecay[_principalToken] = block.number;
    }

    /**
     *  @notice calculate current ratio of debt to payout token supply
     *  @notice protocols using Olympus Pro should be careful when quickly adding large %s to total supply
     *  @return debtRatio_ uint
     */
    function debtRatio(address _principalToken) public view returns ( uint debtRatio_ ) {   
        debtRatio_ = FixedPoint.fraction( 
            currentDebt(_principalToken).mul( 10 ** payoutToken.decimals() ), 
            payoutToken.totalSupply()
        ).decode112with18().div( 1e18 );
    }

    /**
     *  @notice calculate user's interest due for new bond, accounting for Olympus Fee. 
     If fee is in payout then takes in the already calcualted value. If fee is in principal token 
     than takes in the amount of principal being deposited and then calculautes the fee based on
     the amount of principal and not in terms of the payout token
     *  @param _value uint
     *  @return _payout uint
     *  @return _fee uint
     */
    function payoutFor( uint _value, address _principalToken ) public view returns ( uint256 _payout, uint256 _fee) {
        _payout = FixedPoint.fraction( _value, bondPrice(_principalToken) ).decode112with18().div( 1e11 );
    }


    /**
     *  @notice calculate current bond premium
     *  @return price_ uint
     */
    function bondPrice(address _principalToken) public view returns ( uint price_ ) {        
        price_ = terms[_principalToken].controlVariable.mul( debtRatio(_principalToken) ).div( 10 ** (uint256(payoutToken.decimals()).sub(5)) );
        if ( price_ < terms[_principalToken].minimumPrice ) {
            price_ = terms[_principalToken].minimumPrice;
        }
    }

    /**
     *  @notice determine maximum bond size
     *  @return uint
     */
    function maxPayout(address _principalToken) public view returns ( uint ) {
        return payoutToken.totalSupply().mul( terms[_principalToken].maxPayout ).div( 100000 );
    }

    /**
     *  @notice calculate current bond price and remove floor if above
     *  @return price_ uint
     */
    function _bondPrice(address _principalToken) internal returns ( uint price_ ) {
        price_ = terms[_principalToken].controlVariable.mul( debtRatio(_principalToken) ).div( 10 ** (uint256(payoutToken.decimals()).sub(5)) );
        if ( price_ < terms[_principalToken].minimumPrice ) {
            price_ = terms[_principalToken].minimumPrice;        
        } else if ( terms[_principalToken].minimumPrice != 0 ) {
            terms[_principalToken].minimumPrice = 0;
        }
    }

    /**
     *  @notice makes incremental adjustment to control variable
     */
    function adjust(address _principalToken) internal {
        uint256 blockCanAdjust = adjustment[_principalToken].lastBlock.add( adjustment[_principalToken].buffer );
        if( adjustment[_principalToken].rate != 0 && block.number >= blockCanAdjust ) {
            uint256 initial = terms[_principalToken].controlVariable;
            if ( adjustment[_principalToken].add ) {
                terms[_principalToken].controlVariable = terms[_principalToken].controlVariable.add( adjustment[_principalToken].rate );
                if ( terms[_principalToken].controlVariable >= adjustment[_principalToken].target ) {
                    adjustment[_principalToken].rate = 0;
                }
            } else {
                terms[_principalToken].controlVariable = terms[_principalToken].controlVariable.sub( adjustment[_principalToken].rate );
                if ( terms[_principalToken].controlVariable <= adjustment[_principalToken].target ) {
                    adjustment[_principalToken].rate = 0;
                }
            }
            adjustment[_principalToken].lastBlock = block.number;
            emit ControlVariableAdjustment( initial, terms[_principalToken].controlVariable, adjustment[_principalToken].rate, adjustment[_principalToken].add );
        }
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

        uint value = customTreasury.valueOfToken( address(_principalToken), _amount );

        uint payout;
        uint fee;

        (payout, fee) = payoutFor( value, _principalToken); // payout and fee is computed

        require( payout >= 10 ** payoutToken.decimals() / 100, "Bond too small" ); // must be > 0.01 payout token ( underflow protection )
        require( payout <= maxPayout(_principalToken), "Bond too large"); // size protection because there is no slippage
        
        // total debt is increased
        totalDebt[_principalToken] = totalDebt[_principalToken].add( value );

        require( totalDebt[_principalToken] <= terms[_principalToken].maxDebt, "Max capacity reached" );
                
        // depositor info is stored
        Bond memory d = Bond({ 
            // payout: bondInfo[ _depositor ][ bondInfo[ _depositor ].length].payout.add(  ),
            payout: payout,
            vesting: terms[_principalToken].vestingTerm,
            lastBlock: block.number,
            truePricePaid: bondPrice(_principalToken),
            principalToken: _principalToken
        });
        bondInfo[ _depositor ].push(d);

        totalPrincipalBonded[_principalToken] = totalPrincipalBonded[_principalToken].add(_amount); // total bonded increased
        totalPayoutGiven[_principalToken] = totalPayoutGiven[_principalToken].add(payout); // total payout increased


        customTreasury.sendPayoutTokens( payout );

        IERC20(_principalToken).safeTransferFrom( msg.sender, address(customTreasury), _amount ); // transfer principal bonded to custom treasury

        // indexed events are emitted
        emit BondCreated( _amount, payout, block.number.add( terms[_principalToken].vestingTerm ) );
        emit BondPriceChanged( _bondPrice(_principalToken), debtRatio(_principalToken) );

        adjust(_principalToken); // control variable is adjusted
        return payout; 
    }
    

    /**
     *  @notice calculate how far into vesting a depositor is
     *  @param _depositor address
     *  @return percentVested_ uint
     */
    function percentVestedFor( address _depositor, uint256 _index ) public view returns ( uint percentVested_ ) {
        Bond memory bond = bondInfo[ _depositor ][_index];
        uint256 blocksSinceLast = block.number.sub( bond.lastBlock );
        uint256 vesting = bond.vesting;

        if ( vesting > 0 ) {
            percentVested_ = blocksSinceLast.mul( 10000 ).div( vesting );
        } else {
            percentVested_ = 0;
        }
    }


    /// @notice this is a function that would be used to fetch all the bond a users has 
    /// @param _depositor: this is the depositior address 
    function fetchUserBonds(address _depositor) external view returns(Bond[] memory) {
        return bondInfo[_depositor];
    }



    /** 
     *  @notice redeem bond for user
     *  @return uint
     */ 
    function redeem(address _depositor, address _principalToken, uint256 _index) external returns (uint) {
        Bond memory info = bondInfo[ _depositor ][_index];
        uint percentVested = percentVestedFor( _depositor, _index ); // (blocks since last interaction / vesting term remaining)

        if ( percentVested >= 10000 ) { // if fully vested
            delete bondInfo[ _depositor ][_index]; // delete user info
            emit BondRedeemed( _depositor, info.payout, 0 ); // emit bond data
            payoutToken.safeTransfer( _depositor, info.payout );
            return info.payout;
        } else { // if unfinished
            // calculate payout vested
            uint payout = info.payout.mul( percentVested ).div( 10000 );

            // store updated deposit info
            bondInfo[ _depositor ][_index] = Bond({
                payout: info.payout.sub( payout ),
                vesting: info.vesting.sub( block.number.sub( info.lastBlock ) ),
                lastBlock: block.number,
                truePricePaid: info.truePricePaid,
                principalToken: info.principalToken
            });

            emit BondRedeemed( _depositor, payout, bondInfo[ _depositor ][_index].payout );
            payoutToken.safeTransfer( _depositor, payout );
            return payout;
        }
    }


    /**
     *  @notice calculate amount of payout token available for claim by depositor
     *  @param _depositor address
     *  @return pendingPayout_ uint
     */
    function pendingPayoutFor( address _depositor, uint256 _index ) external view returns ( uint pendingPayout_ ) {
        uint percentVested = percentVestedFor( _depositor, _index);
        uint payout = bondInfo[ _depositor ][_index].payout;

        if ( percentVested >= 10000 ) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul( percentVested ).div( 10000 );
        }
    }


}