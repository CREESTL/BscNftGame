//SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/UniswapInterfaces.sol";
import "./interfaces/IGem.sol";
import "./interfaces/IResources.sol";

/// @title Tree token
/// @dev This token implements the reflection mechanism (RFI).
///      For more details see: https://reflect-contract-doc.netlify.app/
contract Tree is Ownable, IResources {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcludedFromRewards;
    address[] private _excluded;

    address public _gemWalletAddress;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public _reflectionFee = 1;
    uint256 private _previousReflectionFee;
    uint256 public _gemFee = 6;
    uint256 private _previousGemFee;
    uint256 public _liquidityFee = 3;
    uint256 private _previousLiquidityFee;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public _maxTxAmount;
    uint256 public numTokensSellToAddToLiquidity;

    IGem public compensationToken;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        string memory name_,
        address router,
        address compensationToken_,
        address devAddress,
        address owner_
    ) Ownable() {
        _name = name_;
        _symbol = "TREE";
        _decimals = 9;
        _tTotal = 300_000_000 * 10 ** 9;
        _rTotal = (MAX - (MAX % _tTotal));
        _maxTxAmount = 10 * 10 ** 6 * 10 ** 9;
        numTokensSellToAddToLiquidity = 1_500_000 * 10 ** 9;
        _gemWalletAddress = devAddress;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        compensationToken = IGem(compensationToken_);

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner_] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_gemWalletAddress] = true;

        transferOwnership(owner_);
        _rOwned[owner()] = _rTotal;

        emit Transfer(address(0), owner(), _tTotal);
    }

    receive() external payable {}

    function isExcludedFromReward(
        address account
    ) external view returns (bool) {
        return _isExcludedFromRewards[account];
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function reflectionFee() external view returns (uint256) {
        return _reflectionFee;
    }

    function gemFee() external view returns (uint256) {
        return _gemFee;
    }

    function liquidityFee() external view returns (uint256) {
        return _liquidityFee;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function gemWallet() external view returns (address) {
        return _gemWalletAddress;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "Tree: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
    }

    function setNumTokensSellToAddToLiquidity(
        uint256 amountToUpdate
    ) external onlyOwner {
        numTokensSellToAddToLiquidity = amountToUpdate;
    }

    function setGemWallet(address payable gemWalletAddress) external onlyOwner {
        _gemWalletAddress = gemWalletAddress;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "Tree: decreased allowance below zero"
            )
        );
        return true;
    }

    function excludeFromReward(address account) external onlyOwner {
        require(
            !_isExcludedFromRewards[account],
            "Tree: account is already excluded"
        );
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(
            _isExcludedFromRewards[account],
            "Tree: account is already included"
        );
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setReflectionFeePercent(
        uint256 reflectionFee_
    ) external onlyOwner {
        require(
            reflectionFee_ + _liquidityFee + _gemFee < 15,
            "Tree: you have reached fee limit"
        );
        _reflectionFee = reflectionFee_;
    }

    function setGemFeePercent(uint256 gemFee_) external onlyOwner {
        require(
            _reflectionFee + _liquidityFee + gemFee_ < 15,
            "Tree: you have reached fee limit"
        );
        _gemFee = gemFee_;
    }

    function setLiquidityFeePercent(uint256 liquidityFee_) external onlyOwner {
        require(
            _reflectionFee + liquidityFee_ + _gemFee < 15,
            "Tree: you have reached fee limit"
        );
        _liquidityFee = liquidityFee_;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        require(
            maxTxAmount >= 1_500_000 * 10 ** 9,
            "Tree: maxTxAmount should be greater than 1500000e9"
        );
        _maxTxAmount = maxTxAmount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) public view returns (uint256) {
        require(tAmount <= _tTotal, "Tree: amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(
        uint256 rAmount
    ) public view returns (uint256) {
        require(
            rAmount <= _rTotal,
            "Tree: amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromRewards[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function _getBnbEquivalent(uint256 amount) internal view returns (uint256) {
        if (!uniswapV2Pair.isContract()) {
            return 0;
        }
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        uint256 reserve0;
        uint256 reserve1;
        try pair.getReserves() returns (
            uint112 reserve0_,
            uint112 reserve1_,
            uint32
        ) {
            reserve0 = reserve0_;
            reserve1 = reserve1_;
        } catch {
            return 0;
        }

        if (reserve0 == 0) {
            return 0;
        }
        return (amount * reserve1) / reserve0;
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tReflectionFee,
        uint256 tGemFee,
        uint256 tLiquidity,
        uint256 currentRate
    ) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rReflectionFee = tReflectionFee.mul(currentRate);
        uint256 rGemFee = tGemFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rReflectionFee).sub(rGemFee).sub(
            rLiquidity
        );
        return (rAmount, rTransferAmount, rReflectionFee);
    }

    function _getValues(
        uint256 tAmount
    )
        private
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        (
            uint256 tTransferAmount,
            uint256 tReflectionFee,
            uint256 tGemFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rReflectionFee
        ) = _getRValues(
                tAmount,
                tReflectionFee,
                tGemFee,
                tLiquidity,
                _getRate()
            );
        return (
            rAmount,
            rTransferAmount,
            rReflectionFee,
            tTransferAmount,
            tReflectionFee,
            tLiquidity + tGemFee
        );
    }

    function _getTValues(
        uint256 tAmount
    ) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tReflectionFee = calculateReflectionFee(tAmount);
        uint256 tGemFee = calculateGemFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tReflectionFee).sub(tGemFee).sub(
            tLiquidity
        );
        return (tTransferAmount, tReflectionFee, tGemFee, tLiquidity);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateReflectionFee(
        uint256 _amount
    ) private view returns (uint256) {
        return _amount.mul(_reflectionFee).div(10 ** 2);
    }

    function calculateGemFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_gemFee).div(10 ** 2);
    }

    function calculateLiquidityFee(
        uint256 _amount
    ) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10 ** 2);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcludedFromRewards[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function removeAllFee() private {
        _previousReflectionFee = _reflectionFee;
        _previousGemFee = _gemFee;
        _previousLiquidityFee = _liquidityFee;

        _reflectionFee = 0;
        _gemFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _reflectionFee = _previousReflectionFee;
        _gemFee = _previousGemFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Tree: approve from the zero address");
        require(spender != address(0), "Tree: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Tree: transfer from the zero address");
        require(to != address(0), "Tree: transfer to the zero address");
        require(
            amount > 0,
            "Tree: transfer amount must be greater than zero"
        );
        require(
            amount <= balanceOf(from),
            "Tree: transfer amount exceeds balance"
        );
        if (from != owner() && to != owner()) {
            require(
                amount <= _maxTxAmount,
                "Tree: transfer amount exceeds the maxTxAmount."
            );
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        try
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of BNB
                path,
                address(this),
                block.timestamp
            )
        {} catch {}
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 toGemWallet = contractTokenBalance.mul(_gemFee).div(
            _gemFee.add(_liquidityFee)
        );
        uint256 toLiquidity = contractTokenBalance.sub(toGemWallet);

        uint256 half = toLiquidity.div(2);
        uint256 otherHalf = toLiquidity.sub(half);

        uint256 swapToBNB = half.add(toGemWallet);
        uint256 initialBalance = address(this).balance;
        swapTokensForBnb(swapToBNB);
        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 gemFeeAmount = newBalance.mul(toGemWallet).div(
            toGemWallet + half
        );
        uint256 bnbForLiquidity = newBalance.sub(gemFeeAmount);
        if (gemFeeAmount > 0) {
            payable(_gemWalletAddress).transfer(gemFeeAmount);
            emit GemFeeSent(_gemWalletAddress, gemFeeAmount);
        }
        addLiquidity(otherHalf, bnbForLiquidity);
        emit SwapAndLiquify(half, bnbForLiquidity, otherHalf);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        try
            uniswapV2Router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                address(this), // LP tokens are locked
                block.timestamp
            )
        {} catch {}
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (
            _isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]
        ) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (
            !_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]
        ) {
            _transferToExcluded(sender, recipient, amount);
        } else if (
            _isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]
        ) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _compensateFee(
        address sender,
        address recipient,
        uint256 totalFee
    ) private {
        if (totalFee > 0 && sender == uniswapV2Pair) {
            uint256 bnbEquivalent = _getBnbEquivalent(totalFee);
            compensationToken.compensateBnb(recipient, bnbEquivalent);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _compensateFee(sender, recipient, tFee + tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _compensateFee(sender, recipient, tFee + tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _compensateFee(sender, recipient, tFee + tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _compensateFee(sender, recipient, tFee + tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}
