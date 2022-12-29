
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) { return msg.sender; }
  function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

contract Ownable is Context {
  address public _owner;
  address public _creator;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    _transferOwnership(_msgSender());
    _creator = _msgSender();
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IFactory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);
	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint256) external view returns (address pair);
	function allPairsLength() external view returns (uint256);
	function createPair(address tokenA, address tokenB) external returns (address pair);
	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
}

interface IRouter {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB, uint256 liquidity );
	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);
	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);
	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);
	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);
	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);
	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);
	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);
	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);
	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
	function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
	function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b; require(c >= a, "SafeMath: addition overflow"); return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) { return sub(a, b, "SafeMath: subtraction overflow"); }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage); uint256 c = a - b; return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) { return 0; }
    uint256 c = a * b; require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) { return div(a, b, "SafeMath: division by zero"); }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage); uint256 c = a / b; return c;
  }
}

pragma solidity 0.8.6;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract TaxCollector is Ownable, ReentrancyGuard{
  bool inSwap;
  modifier swapping() { inSwap = true; _; inSwap = false; }
  uint256 public balance;
  uint256 public maxPercent = 10000;

  uint256 public lockpoolPercentage = 3000; 
  address public lockpoolWallet = 0x3e82a535C31d45f08A1124203FdEbc839d3AE431; //change wallet

  uint256 public liquidityPercentage = 3000; 
  address public liquidityWallet = 0x3e82a535C31d45f08A1124203FdEbc839d3AE431; //change wallet

  uint256 public marketingPercentage = 2000; 
  address public marketingWallet = 0x3e82a535C31d45f08A1124203FdEbc839d3AE431; //change wallet

  uint256 public rndPercentage = 2000; 
  address public rndWallet = 0x3e82a535C31d45f08A1124203FdEbc839d3AE431; //change wallet

  function setLockPool (uint256 percent_, address wallet_) public onlyOwner { lockpoolPercentage = percent_; lockpoolWallet = wallet_; }

  function setLiquidity (uint256 percent_, address wallet_) public onlyOwner { liquidityPercentage = percent_; liquidityWallet = wallet_; }

  function setMarketing (uint256 percent_, address wallet_) public onlyOwner { marketingPercentage = percent_; marketingWallet = wallet_; }

  function setRND (uint256 percent_, address wallet_) public onlyOwner { rndPercentage = percent_; rndWallet = wallet_; }

  receive() external payable { balance += msg.value; }
  function getBalance() public view returns (uint) { return balance; }

  function distribute() public onlyOwner nonReentrant swapping {
    require(lockpoolPercentage + liquidityPercentage + marketingPercentage + rndPercentage == maxPercent, "The sum of percentage isn't 100.");
    require(
      lockpoolWallet != address(0) && 
      liquidityWallet != address (0) &&
      marketingWallet != address (0) &&
      rndWallet != address(0)

      ,
      "Cannot send to zero wallet."
    );
    uint256 amount = getBalance();
  (bool sent_1, ) = payable(lockpoolWallet).call{value: (amount * lockpoolPercentage / maxPercent), gas: 30000}(""); require(sent_1, "Transfer wallet_1 error."); balance = address(this).balance;
  (bool sent_2, ) = payable(liquidityWallet).call{value: (amount * liquidityPercentage / maxPercent), gas: 30000}(""); require(sent_2, "Transfer wallet_2 error."); balance = address(this).balance;
  (bool sent_3, ) = payable(marketingWallet).call{value: (amount * marketingPercentage / maxPercent), gas: 30000}(""); require(sent_3, "Transfer wallet_3 error."); balance = address(this).balance;
  (bool sent_4, ) = payable(rndWallet).call{value: (amount * rndPercentage / maxPercent), gas: 30000}(""); require(sent_4, "Transfer wallet_4 error."); balance = address(this).balance;
  
  }

  function kill() public onlyOwner { selfdestruct(payable(owner())); }
}

interface ITaxCollector {
  function setLockPool (uint256 percent_, address wallet_) external;
  function setLiquidity (uint256 percent_, address wallet_) external;
  function setMarketing (uint256 percent_, address wallet_) external;
  function setRND (uint256 percent_, address wallet_) external;
  function getBalance() external view returns(uint256 balance_);
  function distribute() external;
  function kill () external;
  function transferOwnership(address newOwner) external; 
}

contract Mashida is 
  Context
  , Ownable
  , IERC20
  , IERC20Metadata
  , ReentrancyGuard
{
  using SafeMath for uint256;
  string constant private _name = "Mashida";
  string constant private _symbol = "MSHD";
  uint8 constant private _decimals = 9;
  uint256 private _totalSupply;
  uint256 public _tax = 0;
  uint256 public _buytax = 0;
  uint256 public _selltax = 0;
  uint256 public _taxDivider = 100;
  uint256 public _leaves = 100000000000;
  address public _taxCollector = 0x3e82a535C31d45f08A1124203FdEbc839d3AE431; //tax collector
  address public _ownAddress;

  function setTax(uint256 input_) public onlyOwner 
  { require(input_ <= 10, "fee should be less than 10%");
      _tax = input_; 
      }

        function setbuyTax(uint256 input_) public onlyOwner 
  { require(input_ <= 5, "fee should be less than 5%");
      _buytax = input_; 
      }

        function setsellTax(uint256 input_) public onlyOwner 
  { require(input_ <= 10, "fee should be less than 10%");
      _selltax = input_; 
      }
  function setTaxDivider(uint256 input_) public onlyOwner { _taxDivider = input_; }
  function setTaxCollector(address input_) public onlyOwner { 
    require(input_ != address(0), "Zero Address."); 
    _taxCollector = input_; 
    iTaxCollector = ITaxCollector(input_);
  }

  address constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address constant ZERO = address(0);
  //mainnet
  //address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //pancakerouter
  //address FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; //pancakefactory
  //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 

  //testnet
  address constant ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //pancakerouter testnet
  address constant FACTORY = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc; //pancakefactory testnet
  address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;  //wbnb testnet
  //split TGE Token 
  address constant PRESALE = 0xA00580a81DC06b8BE0AeBc8E4a59bEa239FA07Ad; //change to real address
  address constant LIQUIDITY_PROVISION = 0x70aD465E081deB27294a82F4E83391De33A50876; //change to real address
  address constant ECOSYSTEM = 0x630C892889F12e99CFF9a3626859FC3f616577d1; //change to real address
  address constant TEAM = 0x6e51E6836cB4284242DdfA6068B654ed19718207; //change to real address
  address constant MARKETING = 0x7b7B98fB1B972688cA51b3E6EBe5C751839864c0; //change to real address
  address constant PRODUCT_DEVELOPMENT = 0x393679848c147dAd2179E63275d27056ae2f6647; //change to real address
  address public _pair;
  IRouter public _router;
  bool public inSwap;
  modifier swapping() { inSwap = true; _; inSwap = false; }
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) public _excludedBuyFee;
  mapping(address => bool) public _excludedSellFee;
  mapping(address => bool) public _excludedTransferFee;
  function changeExcludeBuyFee (address input_) public onlyOwner { _excludedBuyFee[input_] = !_excludedBuyFee[input_]; }
  function changeExcludeSellFee (address input_) public onlyOwner { _excludedSellFee[input_] = !_excludedSellFee[input_]; }
  function changeExcludeTransferFee (address input_) public onlyOwner { _excludedTransferFee[input_] = !_excludedTransferFee[input_]; }

  ITaxCollector private iTaxCollector;

  constructor() {
    emit OwnershipTransferred(address(0), _msgSender());
    _router = IRouter(ROUTER);
    _pair = IFactory(_router.factory()).createPair(WBNB, address(this));
    _excludedSellFee[owner()] = true;
    _excludedSellFee[address(this)] = true;
    _excludedSellFee[DEAD] = true;
    _excludedBuyFee[owner()] = true;
    _excludedBuyFee[address(this)] = true;
    _excludedBuyFee[DEAD] = true;
    _excludedTransferFee[owner()] = true;
    _excludedTransferFee[address(this)] = true;
    _excludedTransferFee[DEAD] = true;
    _allowances[address(this)][address(_router)] = ~uint256(0);
    //split TGE 
    _mint(PRESALE, 50000000 * 10 ** uint256(_decimals)); //5%
    _mint(LIQUIDITY_PROVISION, 300000000 * 10 ** uint256(_decimals)); //30%
    _mint(ECOSYSTEM, 200000000 * 10 ** uint256(_decimals)); //20%
    _mint(TEAM, 100000000 * 10 ** uint256(_decimals)); //10%
    _mint(MARKETING, 150000000 * 10 ** uint256(_decimals)); //15%
    _mint(PRODUCT_DEVELOPMENT, 150000000 * 10 ** uint256(_decimals)); //15%
  }

  receive() external payable {  }

  function name() public view virtual override returns (string memory) { return _name; }
  function symbol() public view virtual override returns (string memory) { return _symbol; }
  function decimals() public view virtual override returns (uint8) { return _decimals; }
  function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
  function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
  function currentBalance() public view returns(uint256) { return balanceOf(address(this)); }
  function contractBalance() public view returns(uint256) { return address(this).balance; }
  function taxBalance() public view onlyOwner returns(uint256) { return iTaxCollector.getBalance(); }
  function distributeTax() public nonReentrant onlyOwner { iTaxCollector.distribute(); }
  function setLockPoolTax(uint256 percent_, address wallet_) public onlyOwner { iTaxCollector.setLockPool(percent_, wallet_); }
  function setLiquidityTax(uint256 percent_, address wallet_) public onlyOwner { iTaxCollector.setLiquidity(percent_, wallet_); }
  function setMarketingTax(uint256 percent_, address wallet_) public onlyOwner { iTaxCollector.setMarketing(percent_, wallet_); }
  function setRNDTax(uint256 percent_, address wallet_) public onlyOwner { iTaxCollector.setRND(percent_, wallet_); }
  function setTaxTransferOwner(address newOwner_) public onlyOwner { iTaxCollector.transferOwnership(newOwner_); }
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transferTax(_msgSender(), recipient, amount);
    return true;
  }
  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    if(_allowances[sender][_msgSender()] != ~uint256(0)){
      _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount, "Insufficient allowance.");
    }

    _transferTax(sender, recipient, amount);

    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "MSI: decreased allowance below zero");
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
    
    
  ) internal virtual returns(bool) {
    require(sender != address(0), "MSI: transfer from the zero address");
    require(recipient != address(0), "MSI: transfer to the zero address");
    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "MSI: transfer amount exceeds balance");

    if (!_excludedTransferFee[sender]){
         unchecked {
       _balances[sender] = senderBalance - amount + takeLeaves(amount);
     }
        }

        else {
        unchecked {
       _balances[sender] = senderBalance - amount;
        }
      }

    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function _transferTax(address sender, address recipient, uint256 amount) internal returns (bool) {
         
    uint256 amountLeaves = amount * _tax / 1000000000;
    
    if(inSwap) return 
    _transfer(sender, recipient, amount);
    
    if(!_excludedTransferFee[sender]) 
    _transfer(sender, _msgSender(), amountLeaves);

    uint256 amountReceived = amount;
    uint256 taxTransfer = amount * _tax / 100;
    uint256 amountTax = amount * (100 - _tax) / 100; 

    if (sender == _pair) { 
      // buy
      _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
      if (!_excludedBuyFee[recipient]) {
        amountReceived = takebuyFee(amount);
      }
    } else if (recipient == _pair) { 
      // sell
      _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
      if (!_excludedSellFee[sender]) {
        amountReceived = takesellFee(amount);
        distributeFee();
      }
    } else { 
        if(!_excludedTransferFee[sender]) {
    _transfer(sender, recipient, amountTax);
    _transfer(sender, _taxCollector, taxTransfer);
        }
        else 
        _transfer(sender, recipient, amount);
    
       return true;
    }
    _balances[recipient] = _balances[recipient].add(amountReceived);
    emit Transfer(sender, recipient, amount);
    return true;
  }


 function takeLeaves (uint256 amount_) private returns(uint256){
    uint256 fee = _tax.mul(amount_).div(_leaves);
    _balances[address(this)] = _balances[address(this)].add(fee);
    return amount_.sub(amount_.sub(fee));
  }
  function takeFee (uint256 amount_) private returns(uint256){
    uint256 fee = _tax.mul(amount_).div(_taxDivider);
    _balances[address(this)] = _balances[address(this)].add(fee);
    return amount_.sub(fee);
  }
  function sendFee (uint256 amount_) private returns(uint256){
    uint256 fee = _tax.mul(amount_).div(_taxDivider);
    _balances[address(this)] = _balances[address(this)].add(fee);
    return amount_ = fee;
  }
    function takebuyFee (uint256 amount_) private returns(uint256){
    uint256 fee = _buytax.mul(amount_).div(_taxDivider);
    _balances[address(this)] = _balances[address(this)].add(fee);
    return amount_.sub(fee);
  }

  function takesellFee (uint256 amount_) private returns(uint256){
    uint256 fee = _selltax.mul(amount_).div(_taxDivider);
    _balances[address(this)] = _balances[address(this)].add(fee);
    return amount_.sub(fee);
  }




  function distributeFee () private nonReentrant swapping {
    uint256 swapAmount = _balances[address(this)];

    if (_balances[address(this)] > 0) {
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = address(WBNB);
      
      uint256 currentBNBBalance = address(this).balance;
      try _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        swapAmount,
        0,
        path,
        address(this),
        block.timestamp
      ) {
        uint256 amountBNB = address(this).balance.sub(currentBNBBalance);
        (bool sent, ) = payable(_taxCollector).call{value: amountBNB, gas: 30000}(""); require(sent, "Transfer error.");
      } catch Error(string memory e) { emit DistributeFailed(e); }
    }
  }
  event DistributeFailed(string message);


  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "MSI: mint to the zero address");

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }


  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "MSI: approve from the zero address");
    require(spender != address(0), "MSI: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}
