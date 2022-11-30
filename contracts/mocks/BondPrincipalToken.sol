// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondPrincipalToken is ERC20, Ownable {
    uint public constant maxTotalSupply = 100000000 * 10 ** 18;

    constructor(string memory _tokenName, string memory _tokenSymbol) ERC20(_tokenName, _tokenSymbol) {
        _mint(msg.sender, 10000000e18);
    }

    function mint(uint _amount) public {
        _mint(msg.sender, _amount);
    }
}
