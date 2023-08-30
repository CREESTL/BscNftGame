# BlackList



> Blacklist contract. Blacklisted addresses cannot use main functions        of other contracts





## Methods

### addToBlacklist

```solidity
function addToBlacklist(address user) external nonpayable
```

See {IBlacklist-addToBlacklist}



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | undefined |

### check

```solidity
function check(address user) external view returns (bool)
```

See {IBlacklist-check}



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### removeFromBlacklist

```solidity
function removeFromBlacklist(address user) external nonpayable
```

See {IBlacklist-removeFromBlacklist}



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |



## Events

### AddedToBlacklist

```solidity
event AddedToBlacklist(address user)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### RemovedFromBlacklist

```solidity
event RemovedFromBlacklist(address user)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |



