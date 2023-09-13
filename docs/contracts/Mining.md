# Mining



> Contract for resources mining





## Methods

### endMining

```solidity
function endMining(uint256 toolId) external nonpayable
```

See {IMining-endMining}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | undefined |

### initialize

```solidity
function initialize(address blacklistAddress, address toolsAddress) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| blacklistAddress | address | undefined |
| toolsAddress | address | undefined |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) external pure returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256[] | undefined |
| _3 | uint256[] | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### onERC1155Received

```solidity
function onERC1155Received(address, address, uint256, uint256, bytes) external pure returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256 | undefined |
| _3 | uint256 | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### pause

```solidity
function pause() external nonpayable
```

See {IMining-pause}




### paused

```solidity
function paused() external view returns (bool)
```



*Returns true if the contract is paused, and false otherwise.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.*


### startMining

```solidity
function startMining(uint256 toolId, address user, bytes rewards, bytes signature, uint256 nonce) external nonpayable
```

See {IMining-pause}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | undefined |
| user | address | undefined |
| rewards | bytes | undefined |
| signature | bytes | undefined |
| nonce | uint256 | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external pure returns (bool)
```



*The following 3 functions are required to ERC1155 standard*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

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



## Events

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### MiningEnded

```solidity
event MiningEnded(address user, IMining.MiningSession session)
```

Indicates that mining session has ended



#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |
| session  | IMining.MiningSession | undefined |

### MiningStarted

```solidity
event MiningStarted(address user, IMining.MiningSession session)
```

Indicates that new mining session has started



#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |
| session  | IMining.MiningSession | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### Paused

```solidity
event Paused(address account)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account  | address | undefined |

### RewardsClaimed

```solidity
event RewardsClaimed(address user, uint256[] resources, uint256[] artifacts)
```

Indicates that user has claimed his rewards



#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |
| resources  | uint256[] | undefined |
| artifacts  | uint256[] | undefined |

### Unpaused

```solidity
event Unpaused(address account)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account  | address | undefined |



