# Tools



> This contracts represents tools that are used to mine resources and artifacts.





## Methods

### addTool

```solidity
function addTool(uint32 maxStrength, uint32 miningDuration, uint32 energyCost, uint32 strengthCost, uint256 resourcesAmount, uint256[] artifactsAmounts, string newURI) external nonpayable returns (uint256)
```

See {ITools-addTool}



#### Parameters

| Name | Type | Description |
|---|---|---|
| maxStrength | uint32 | undefined |
| miningDuration | uint32 | undefined |
| energyCost | uint32 | undefined |
| strengthCost | uint32 | undefined |
| resourcesAmount | uint256 | undefined |
| artifactsAmounts | uint256[] | undefined |
| newURI | string | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(address account, uint256 id) external view returns (uint256)
```



*See {IERC1155-balanceOf}. Requirements: - `account` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| id | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### balanceOfBatch

```solidity
function balanceOfBatch(address[] accounts, uint256[] ids) external view returns (uint256[])
```



*See {IERC1155-balanceOfBatch}. Requirements: - `accounts` and `ids` must have the same length.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| accounts | address[] | undefined |
| ids | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256[] | undefined |

### corrupt

```solidity
function corrupt(address user, uint256 toolId, uint256 strengthCost) external nonpayable
```

See {ITools-corrupt}



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | undefined |
| toolId | uint256 | undefined |
| strengthCost | uint256 | undefined |

### craft

```solidity
function craft(uint256 toolType) external nonpayable
```

See {ITools-craft}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |

### getArtifactsAddress

```solidity
function getArtifactsAddress() external view returns (address)
```

See {ITools-getArtifactsAddress}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getArtifactsTypesAmount

```solidity
function getArtifactsTypesAmount() external view returns (uint256)
```

See {ITools-getArtifactsTypesAmount}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getMiningAddress

```solidity
function getMiningAddress() external view returns (address)
```

See {ITools-getMiningAddress}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getRecipe

```solidity
function getRecipe(uint256 toolType) external view returns (uint256 resourcesAmount, uint256[] artifactsAmounts)
```

See {ITools-getRecipe}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| resourcesAmount | uint256 | undefined |
| artifactsAmounts | uint256[] | undefined |

### getResourceAddress

```solidity
function getResourceAddress(uint256 resourceId) external view returns (address)
```

See {ITools-getResourceAddress}



#### Parameters

| Name | Type | Description |
|---|---|---|
| resourceId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getResourcesTypesAmount

```solidity
function getResourcesTypesAmount() external view returns (uint256)
```

See {ITools-getResourcesTypesAmount}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getStrength

```solidity
function getStrength(uint256 toolId) external view returns (uint256)
```

See {ITools-getStrength}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getToolProperties

```solidity
function getToolProperties(address user, uint256 toolId) external view returns (uint256 toolType, uint256 strength, uint256 strengthCost, uint256 miningDuration, uint256 energyCost)
```

See {ITools-getToolProperties}



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | undefined |
| toolId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |
| strength | uint256 | undefined |
| strengthCost | uint256 | undefined |
| miningDuration | uint256 | undefined |
| energyCost | uint256 | undefined |

### getToolTypeProperties

```solidity
function getToolTypeProperties(uint256 toolType) external view returns (uint256 maxStrength, uint256 strengthCost, uint256 miningDuration, uint256 energyCost)
```

See {ITools-getToolTypeProperties}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| maxStrength | uint256 | undefined |
| strengthCost | uint256 | undefined |
| miningDuration | uint256 | undefined |
| energyCost | uint256 | undefined |

### getToolsTypesAmount

```solidity
function getToolsTypesAmount() external view returns (uint256)
```

See {ITools-getToolsTypesAmount}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### increaseArtifactsTypesAmount

```solidity
function increaseArtifactsTypesAmount() external nonpayable
```

See {ITools-increaseArtifactsTypesAmount}




### initialize

```solidity
function initialize(address blacklistAddress, address berryAddress, address treeAddress, address goldAddress, string baseURI) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| blacklistAddress | address | undefined |
| berryAddress | address | undefined |
| treeAddress | address | undefined |
| goldAddress | address | undefined |
| baseURI | string | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address account, address operator) external view returns (bool)
```



*See {IERC1155-isApprovedForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| operator | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### mint

```solidity
function mint(address to, uint128 toolType, uint256 amount) external nonpayable
```

See {ITools-mint}



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| toolType | uint128 | undefined |
| amount | uint256 | undefined |

### mintBatch

```solidity
function mintBatch(address to, uint256[] toolTypes, uint256[] amounts) external nonpayable
```

See {ITools-mintBatch}



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| toolTypes | uint256[] | undefined |
| amounts | uint256[] | undefined |

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



*The next 2 functions are required for ERC1155 standard*

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

See {ITools-pause}




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


### repairTool

```solidity
function repairTool(uint256 toolId) external nonpayable
```

See {ITools-repairTool}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | undefined |

### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address from, address to, uint256[] toolIds, uint256[] amounts, bytes data) external nonpayable
```

See {ITools-safeBatchTransferFrom}



#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| toolIds | uint256[] | undefined |
| amounts | uint256[] | undefined |
| data | bytes | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 toolId, uint256 amount, bytes data) external nonpayable
```

See {ITools-safeTransferFrom}



#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| toolId | uint256 | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*See {IERC1155-setApprovalForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### setArtifactsAddress

```solidity
function setArtifactsAddress(address artifactsAddress) external nonpayable
```

See {ITools-setArtifactsAddress}



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactsAddress | address | undefined |

### setBaseURI

```solidity
function setBaseURI(string baseURI) external nonpayable
```

See {ITools-setBaseURI}



#### Parameters

| Name | Type | Description |
|---|---|---|
| baseURI | string | undefined |

### setMiningAddress

```solidity
function setMiningAddress(address miningAddress) external nonpayable
```

See {ITools-setMiningAddress}



#### Parameters

| Name | Type | Description |
|---|---|---|
| miningAddress | address | undefined |

### setRecipe

```solidity
function setRecipe(uint256 toolType, uint256 resourcesAmount, uint256[] artifactsAmounts) external nonpayable
```

See {ITools-setRecipe}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |
| resourcesAmount | uint256 | undefined |
| artifactsAmounts | uint256[] | undefined |

### setToolProperties

```solidity
function setToolProperties(uint256 toolType, uint32 maxStrength, uint32 miningDuration, uint32 energyCost, uint32 strengthCost) external nonpayable
```

See {ITools-setToolProperties}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |
| maxStrength | uint32 | undefined |
| miningDuration | uint32 | undefined |
| energyCost | uint32 | undefined |
| strengthCost | uint32 | undefined |

### setURI

```solidity
function setURI(uint256 toolType, string newURI) external nonpayable
```

See {ITools-setURI}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |
| newURI | string | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*This function is required for ERC1155 standard*

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

### uri

```solidity
function uri(uint256 toolType) external view returns (string)
```

See {ITools-uri}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |



## Events

### AddTool

```solidity
event AddTool(uint256 toolType, string newURI)
```

Indicates that a new tool was added



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType  | uint256 | undefined |
| newURI  | string | undefined |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed account, address indexed operator, bool approved)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### BaseURI

```solidity
event BaseURI(string baseURI)
```

Indicates that a new base URI was set



#### Parameters

| Name | Type | Description |
|---|---|---|
| baseURI  | string | undefined |

### Craft

```solidity
event Craft(address user, uint256 toolType, uint256 toolId)
```

Indicates that a tool was crafted



#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |
| toolType  | uint256 | undefined |
| toolId  | uint256 | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### MintId

```solidity
event MintId(address to, uint256 toolType, uint256 toolId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| to  | address | undefined |
| toolType  | uint256 | undefined |
| toolId  | uint256 | undefined |

### MintType

```solidity
event MintType(address to, uint256 toolType, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| to  | address | undefined |
| toolType  | uint256 | undefined |
| amount  | uint256 | undefined |

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

### RecipeCreatedOrUpdated

```solidity
event RecipeCreatedOrUpdated(uint256 toolType, uint256 resourcesAmount, uint256[] artifactsAmounts)
```

Indicates that tool recipe was created or updated



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType  | uint256 | undefined |
| resourcesAmount  | uint256 | undefined |
| artifactsAmounts  | uint256[] | undefined |

### ToolPropertiesSet

```solidity
event ToolPropertiesSet(uint256 toolType)
```

Indicates that tool type&#39;s properties have been changed



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType  | uint256 | undefined |

### ToolRepaired

```solidity
event ToolRepaired(uint256 toolId)
```

Indicates that a tool has been fully repaired



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId  | uint256 | undefined |

### Transfer

```solidity
event Transfer(address from, address to, uint256 toolType, uint256 toolId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from  | address | undefined |
| to  | address | undefined |
| toolType  | uint256 | undefined |
| toolId  | uint256 | undefined |

### TransferBatch

```solidity
event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| ids  | uint256[] | undefined |
| values  | uint256[] | undefined |

### TransferSingle

```solidity
event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| id  | uint256 | undefined |
| value  | uint256 | undefined |

### URI

```solidity
event URI(string value, uint256 indexed id)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| value  | string | undefined |
| id `indexed` | uint256 | undefined |

### Unpaused

```solidity
event Unpaused(address account)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account  | address | undefined |



