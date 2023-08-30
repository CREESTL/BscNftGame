# IGem



> Interface for Gem token contract





## Methods

### blockAddress

```solidity
function blockAddress(address addr, bool isBlocked) external nonpayable
```

Block address from transferring and receiving tokens



#### Parameters

| Name | Type | Description |
|---|---|---|
| addr | address | The address to block |
| isBlocked | bool | True to block address. False to unblock address |

### compensateBnb

```solidity
function compensateBnb(address to, uint256 bnbAmount) external nonpayable
```

Mints some amount of Gems to compensate fee in BNB tokens



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | The address to mint Gems to |
| bnbAmount | uint256 | The amount of BNB to compensate |

### decimals

```solidity
function decimals() external pure returns (uint8)
```

Returns the amount of decimals of the token




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | The amount of decimals of the token |

### setCompensationRate

```solidity
function setCompensationRate(uint256 compensationRate) external nonpayable
```

Changes compensation rate



#### Parameters

| Name | Type | Description |
|---|---|---|
| compensationRate | uint256 | The new compensation rate |

### setCompensator

```solidity
function setCompensator(address compensator) external nonpayable
```

Changes compensator



#### Parameters

| Name | Type | Description |
|---|---|---|
| compensator | address | The new compensator |



## Events

### Blocked

```solidity
event Blocked(address addr)
```

Indicates that address has been blocked from transferring and receiving tokens



#### Parameters

| Name | Type | Description |
|---|---|---|
| addr  | address | undefined |

### Unblocked

```solidity
event Unblocked(address addr)
```

Indicates that address has been unblocked from transferring and receiving tokens



#### Parameters

| Name | Type | Description |
|---|---|---|
| addr  | address | undefined |



