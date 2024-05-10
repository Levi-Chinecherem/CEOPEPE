// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title CEOPepeToken
 * @dev A token contract with burning capability, ownership, blacklisting, and trading rules.
 */
contract CEOPepeToken is ERC20, ERC20Burnable, Ownable {
    // Variables to manage trading rules
    bool public limited;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapV2Pair;
    // Mapping to maintain blacklisted addresses
    mapping(address => bool) public blacklists;

    constructor() Ownable(msg.sender) ERC20("CeoPepe", "CEOPEPE") {
        _mint(msg.sender, 100 * 10 ** 6 * 10 ** uint(decimals()));
    }

    /**
     * @dev Blacklists or unblacklists an address.
     * @param _address The address to blacklist or unblacklist.
     * @param _isBlacklisting Boolean indicating whether to blacklist or unblacklist.
     */
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }

    /**
     * @dev Sets the trading rules.
     * @param _limited Boolean indicating whether trading is limited.
     * @param _uniswapV2Pair Address of the Uniswap V2 pair contract.
     * @param _maxHoldingAmount Maximum holding amount per transaction.
     * @param _minHoldingAmount Minimum holding amount per transaction.
     */
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }

    /**
     * @dev Hook that is called before any transfer of tokens.
     * Checks whether the transfer is allowed based on trading rules and blacklisting.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(!blacklists[to] && !blacklists[from], "Blacklisted");

        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "Trading is not started");
            return;
        }

        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
        }
    }

}
