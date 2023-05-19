# PocMon









## Methods

### _gemFee

```solidity
function _gemFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### _gemWalletAddress

```solidity
function _gemWalletAddress() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### _liquidityFee

```solidity
function _liquidityFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### _maxTxAmount

```solidity
function _maxTxAmount() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### _reflectionFee

```solidity
function _reflectionFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```



*Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner` through {transferFrom}. This is zero by default. This value changes when {approve} or {transferFrom} are called.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| spender | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### approve

```solidity
function approve(address spender, uint256 amount) external nonpayable returns (bool)
```



*Sets `amount` as the allowance of `spender` over the caller&#39;s tokens. Returns a boolean value indicating whether the operation succeeded. IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 Emits an {Approval} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```



*Returns the amount of tokens owned by `account`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### compensationToken

```solidity
function compensationToken() external view returns (contract IGEM)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IGEM | undefined |

### decimals

```solidity
function decimals() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### decreaseAllowance

```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| subtractedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### excludeFromFee

```solidity
function excludeFromFee(address account) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

### excludeFromReward

```solidity
function excludeFromReward(address account) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

### gemFee

```solidity
function gemFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### gemWallet

```solidity
function gemWallet() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### includeInFee

```solidity
function includeInFee(address account) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

### includeInReward

```solidity
function includeInReward(address account) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

### increaseAllowance

```solidity
function increaseAllowance(address spender, uint256 addedValue) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| addedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### isExcludedFromFee

```solidity
function isExcludedFromFee(address account) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### isExcludedFromReward

```solidity
function isExcludedFromReward(address account) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### liquidityFee

```solidity
function liquidityFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### name

```solidity
function name() external view returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### numTokensSellToAddToLiquidity

```solidity
function numTokensSellToAddToLiquidity() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### reflectionFee

```solidity
function reflectionFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### reflectionFromToken

```solidity
function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tAmount | uint256 | undefined |
| deductTransferFee | bool | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### setGemFeePercent

```solidity
function setGemFeePercent(uint256 gemFee_) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| gemFee_ | uint256 | undefined |

### setGemWallet

```solidity
function setGemWallet(address payable gemWalletAddress) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| gemWalletAddress | address payable | undefined |

### setLiquidityFeePercent

```solidity
function setLiquidityFeePercent(uint256 liquidityFee_) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| liquidityFee_ | uint256 | undefined |

### setMaxTxAmount

```solidity
function setMaxTxAmount(uint256 maxTxAmount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| maxTxAmount | uint256 | undefined |

### setNumTokensSellToAddToLiquidity

```solidity
function setNumTokensSellToAddToLiquidity(uint256 amountToUpdate) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| amountToUpdate | uint256 | undefined |

### setReflectionFeePercent

```solidity
function setReflectionFeePercent(uint256 reflectionFee_) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| reflectionFee_ | uint256 | undefined |

### setRouterAddress

```solidity
function setRouterAddress(address newRouter) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newRouter | address | undefined |

### setSwapAndLiquifyEnabled

```solidity
function setSwapAndLiquifyEnabled(bool _enabled) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _enabled | bool | undefined |

### swapAndLiquifyEnabled

```solidity
function swapAndLiquifyEnabled() external view returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### symbol

```solidity
function symbol() external view returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### tokenFromReflection

```solidity
function tokenFromReflection(uint256 rAmount) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| rAmount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*Returns the amount of tokens in existence.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transfer

```solidity
function transfer(address recipient, uint256 amount) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferFrom

```solidity
function transferFrom(address sender, address recipient, uint256 amount) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| recipient | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### uniswapV2Pair

```solidity
function uniswapV2Pair() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### uniswapV2Router

```solidity
function uniswapV2Router() external view returns (contract IUniswapV2Router02)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IUniswapV2Router02 | undefined |



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| spender `indexed` | address | undefined |
| value  | uint256 | undefined |

### GemFeeSent

```solidity
event GemFeeSent(address to, uint256 bnbSent)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| to  | address | undefined |
| bnbSent  | uint256 | undefined |

### MinTokensBeforeSwapUpdated

```solidity
event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| minTokensBeforeSwap  | uint256 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### SwapAndLiquify

```solidity
event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokensSwapped  | uint256 | undefined |
| ethReceived  | uint256 | undefined |
| tokensIntoLiqudity  | uint256 | undefined |

### SwapAndLiquifyEnabledUpdated

```solidity
event SwapAndLiquifyEnabledUpdated(bool enabled)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| enabled  | bool | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| value  | uint256 | undefined |



