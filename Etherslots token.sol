// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract EtherSlotsToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18;
    uint256 public constant MAX_TAX_PERCENT = 20;
    uint256 public constant MAX_WALLET_BALANCE = MAX_SUPPLY * 2 / 100;

    uint256 public buyTaxPercent;
    uint256 public sellTaxPercent;
    bool public tradingEnabled;

    mapping(address => bool) public exemptFromMaxWallet;

    modifier whenTradingEnabled() {
        require(tradingEnabled, "Trading is not enabled yet");
        _;
    }

    IUniswapV2Router02 public uniswapV2Router;

    constructor(
        address _marketingAddress,
        address _developmentAddress,
        address _lpAddress,
        address _stakingPoolAddress,
        address _uniswapRouter
    ) ERC20("Etherslots Token", "EST") {
        require(
            _marketingAddress != address(0) &&
            _developmentAddress != address(0) &&
            _lpAddress != address(0) &&
            _stakingPoolAddress != address(0),
            "Invalid tax address"
        );

        marketingAddress = _marketingAddress;
        developmentAddress = _developmentAddress;
        lpAddress = _lpAddress;
        stakingPoolAddress = _stakingPoolAddress;
        uniswapV2Router = IUniswapV2Router02(_uniswapRouter);

        _mint(msg.sender, MAX_SUPPLY);
        setBuyTaxPercent(8); // 2% marketing, 2% development, 2% LP, 2% staking
        setSellTaxPercent(8); // 2% marketing, 2% development, 2% LP, 2% staking

    }

    function setBuyTaxPercent(uint256 newBuyTaxPercent) public onlyOwner {
        require(newBuyTaxPercent <= MAX_TAX_PERCENT, "Tax cannot exceed 20%");
        buyTaxPercent = newBuyTaxPercent;
    }

    function setSellTaxPercent(uint256 newSellTaxPercent) public onlyOwner {
        require(newSellTaxPercent <= MAX_TAX_PERCENT, "Tax cannot exceed 20%");
        sellTaxPercent = newSellTaxPercent;
    }

    function setExemptFromMaxWallet(address account, bool exempt) public onlyOwner {
        exemptFromMaxWallet[account] = exempt;
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        uint256 tokenMin,
        uint256 ethMin,
        address to,
        uint256 deadline
     ) external onlyOwner {
    require(address(this).balance >= ethAmount, "Not enough ETH in contract");

    // Approve the router to spend tokens
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // Add liquidity
    uniswapV2Router.addLiquidityETH{value: ethAmount}(
        address(this),
        tokenAmount,
        tokenMin,
        ethMin,
        to,
        deadline
    );
}
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override whenTradingEnabled {
        // Check for max wallet balance, unless sender or recipient is exempt
        if (!exemptFromMaxWallet[sender] && !exemptFromMaxWallet[recipient]) {
            uint256 recipientBalance = balanceOf(recipient);
            require(recipientBalance + amount <= MAX_WALLET_BALANCE, "Exceeds max wallet balance");
        }

        // Implement any additional logic for buy and sell operations, if necessary
        // ...
    uint256 stakingTax = amount.mul(BUY_STAKING_POOL_TAX).div(100);
    super._transfer(sender, stakingPoolAddress, stakingTax);
    uint256 netAmount = amount.sub(stakingTax);
    super._transfer(sender, recipient, netAmount);
}
