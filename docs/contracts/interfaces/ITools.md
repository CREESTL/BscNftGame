# ITools



> Interface for Tools contract





## Methods

### addTool

```solidity
function addTool(uint32 maxStrength, uint32 miningDuration, uint256 energyCost, uint32 strengthCost, uint256 resourcesAmount, uint256[] artifactsAmounts, string newURI) external nonpayable returns (uint256)
```

Adds a new tool.



#### Parameters

| Name | Type | Description |
|---|---|---|
| maxStrength | uint32 | The maximum strength of the tool |
| miningDuration | uint32 | The duration of mining session with the tool |
| energyCost | uint256 | The cost in Berry tokens to start mining session with the tool |
| strengthCost | uint32 | The cost in tool strength to start mining session with it |
| resourcesAmount | uint256 | Amount of Tree tokens requires to craft a tool |
| artifactsAmounts | uint256[] | Amounts of each type of artifacts to craft a tool |
| newURI | string | The URI of the tool |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The type of the new tool |

### balanceOf

```solidity
function balanceOf(address account, uint256 id) external view returns (uint256)
```



*Returns the amount of tokens of token type `id` owned by `account`. Requirements: - `account` cannot be the zero address.*

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



*xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}. Requirements: - `accounts` and `ids` must have the same length.*

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

Decreases tool&#39;s strength when mining



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The user who is mining |
| toolId | uint256 | The ID of the tool used for mining |
| strengthCost | uint256 | The amount of tool&#39;s strength subtracted from current strength |

### craft

```solidity
function craft(uint256 toolType) external nonpayable
```

Crafts a new tools after it was added



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | The type of the tool |

### getArtifactsAddress

```solidity
function getArtifactsAddress() external view returns (address)
```

Returns the address of Artifacts contract




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | The address of Artifacts contract |

### getArtifactsTypesAmount

```solidity
function getArtifactsTypesAmount() external view returns (uint256)
```

Returns the amount of types of artifacts




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of types of artifacts |

### getMiningAddress

```solidity
function getMiningAddress() external view returns (address)
```

Returns the address of Mining contract




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | The address of Mining contract |

### getRecipe

```solidity
function getRecipe(uint256 toolType) external view returns (uint256 resourcesAmount, uint256[] artifactsAmounts)
```

Returns the recipe for the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | The type of the tool |

#### Returns

| Name | Type | Description |
|---|---|---|
| resourcesAmount | uint256 | Amount of Tree resources to craft the tool |
| artifactsAmounts | uint256[] | Amounts of artifacts of different types to craft the tool |

### getResourceAddress

```solidity
function getResourceAddress(uint256 resourceId) external view returns (address)
```

Returns the address of resource contract of a specific resource type



#### Parameters

| Name | Type | Description |
|---|---|---|
| resourceId | uint256 | The type of resource |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | The address of resource contract of a specific resource type |

### getResourcesTypesAmount

```solidity
function getResourcesTypesAmount() external view returns (uint256)
```

Returns the amount of types of resources




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of types of resources |

### getStrength

```solidity
function getStrength(address user, uint256 toolId) external view returns (uint256)
```

Returns current strength of the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The address of the owner of the tool |
| toolId | uint256 | The ID of the tool |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | Current strength of the tool |

### getToolProperties

```solidity
function getToolProperties(address user, uint256 toolId) external view returns (uint256 toolType, uint256 strength, uint256 strengthCost, uint256 miningDuration, uint256 energyCost)
```

Returns properties of the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | User owning a tool |
| toolId | uint256 | The ID of the tool |

#### Returns

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | Type of the tool |
| strength | uint256 | Current strength of the tool |
| strengthCost | uint256 | Cost in strength to start mining with the tool |
| miningDuration | uint256 | Duration of a mining session with the tool |
| energyCost | uint256 | Cost in Berry tokens to start mining session with the tool |

### getToolTypeProperties

```solidity
function getToolTypeProperties(uint256 toolType) external view returns (uint256 maxStrength, uint256 strengthCost, uint256 miningDuration, uint256 energyCost)
```

Returns properties of type of the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | Type of the tool to get the properties of |

#### Returns

| Name | Type | Description |
|---|---|---|
| maxStrength | uint256 | Max strength of the tool type |
| strengthCost | uint256 | Cost in strength to start mining with the tool |
| miningDuration | uint256 | Duration of a mining session with the tool |
| energyCost | uint256 | Cost in Berry tokens to start mining session with the tool |

### getToolsTypesAmount

```solidity
function getToolsTypesAmount() external view returns (uint256)
```

Returns the amount of types of tools




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of types of tools |

### increaseArtifactsTypesAmount

```solidity
function increaseArtifactsTypesAmount() external nonpayable
```

Increases a number of types of artifacts by one




### isApprovedForAll

```solidity
function isApprovedForAll(address account, address operator) external view returns (bool)
```



*Returns true if `operator` is approved to transfer ``account``&#39;s tokens. See {setApprovalForAll}.*

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

Mints `amount` tools of `toolType` to `to`



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | The receiver of tools |
| toolType | uint128 | The type of the tool |
| amount | uint256 | The amount of tools to mint |

### mintBatch

```solidity
function mintBatch(address to, uint256[] toolTypes, uint256[] amounts) external nonpayable
```

Mints batches of tools of different types to `to`



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | The receiver of tools |
| toolTypes | uint256[] | Types of tools |
| amounts | uint256[] | Amounts of tools |

### ownsTool

```solidity
function ownsTool(address user, uint256 toolId) external view returns (bool)
```

Checks if user owns a tool with a given ID



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The address of the user |
| toolId | uint256 | The ID of the tool |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | True if user owns a tool with a given ID. Otherwise - false |

### pause

```solidity
function pause() external nonpayable
```

Pauses the contract if it&#39;s active. Activates it if it&#39;s paused




### repairTool

```solidity
function repairTool(uint256 toolId) external nonpayable
```

Completely repairs the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | The ID of the tool to repair |

### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address from, address to, uint256[] toolIds, uint256[] amounts, bytes data) external nonpayable
```

Transfers one tool of each `toolIds` from `from` to `to`



#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Sender of tokens |
| to | address | Receiver of tokens |
| toolIds | uint256[] | IDs of tools to transfer |
| amounts | uint256[] | Each amount always equals to 1 |
| data | bytes | Extra data (optional) |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 toolId, uint256 amount, bytes data) external nonpayable
```

Transfers a single tool with `toolId` from `from` to `to`



#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Sender of tokens |
| to | address | Receiver of tokens |
| toolId | uint256 | The ID of the tool to transfer |
| amount | uint256 | Always equals to 1 |
| data | bytes | Extra data (optional) |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*Grants or revokes permission to `operator` to transfer the caller&#39;s tokens, according to `approved`, Emits an {ApprovalForAll} event. Requirements: - `operator` cannot be the caller.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### setArtifactsAddress

```solidity
function setArtifactsAddress(address artifactsAddress) external nonpayable
```

Changes address of Artifacts contract



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactsAddress | address | The new address of Artifacts contract |

### setBaseURI

```solidity
function setBaseURI(string baseURI) external nonpayable
```

Changes the base URI for tools



#### Parameters

| Name | Type | Description |
|---|---|---|
| baseURI | string | The new base URI |

### setMiningAddress

```solidity
function setMiningAddress(address miningAddress) external nonpayable
```

Changes address of Mining contract



#### Parameters

| Name | Type | Description |
|---|---|---|
| miningAddress | address | The new address of Mining contract |

### setRecipe

```solidity
function setRecipe(uint256 toolType, uint256 resourcesAmount, uint256[] artifactsAmounts) external nonpayable
```

Changes the recipe of the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | The type of the tool |
| resourcesAmount | uint256 | The new amount of Tree to craft the tool |
| artifactsAmounts | uint256[] | undefined |

### setToolProperties

```solidity
function setToolProperties(uint256 toolType, uint32 maxStrength, uint32 miningDuration, uint256 energyCost, uint32 strengthCost) external nonpayable
```

Changes properties of the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | The type of the tool |
| maxStrength | uint32 | The maximum strength of the tool |
| miningDuration | uint32 | The duration of mining session with the tool |
| energyCost | uint256 | The cost in Berry tokens to start mining session with the tool |
| strengthCost | uint32 | The cost in tool strength to start mining session with it |

### setURI

```solidity
function setURI(uint256 toolType, string newURI) external nonpayable
```

Changes the URI of the tool type



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | The type of the tool |
| newURI | string | The new URI |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section] to learn more about how these ids are created. This function call must use less than 30 000 gas.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### uri

```solidity
function uri(uint256 toolType) external view returns (string)
```

Returns the URI of the tool type



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType | uint256 | The type of the tool |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | The URI of the tool type |



## Events

### AddTool

```solidity
event AddTool(uint256 toolType, string newURI)
```

Indicates that a new tool was added



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType  | uint256 | Type of the tool |
| newURI  | string | URI of the tool |

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
| baseURI  | string | A new base URI |

### Craft

```solidity
event Craft(address user, uint256 toolType, uint256 toolId)
```

Indicates that a tool was crafted



#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | User who crafted a tool |
| toolType  | uint256 | Type of the tool |
| toolId  | uint256 | Unique ID of the tool |

### MintId

```solidity
event MintId(address to, uint256 toolType, uint256 toolId)
```



*Indicates that one tool of `toolType` with `toolId` was minted to `to`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to  | address | Receiver of tool |
| toolType  | uint256 | Type of the tool |
| toolId  | uint256 | The ID of the tool minted |

### MintType

```solidity
event MintType(address to, uint256 toolType, uint256 amount)
```



*Indicates that `amount` of tools of `toolType` was minted to `to`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to  | address | Receiver of tool |
| toolType  | uint256 | Type of the tool |
| amount  | uint256 | The amount of tools minted |

### RecipeCreatedOrUpdated

```solidity
event RecipeCreatedOrUpdated(uint256 toolType, uint256 resourcesAmount, uint256[] artifactsAmounts)
```

Indicates that tool recipe was created or updated



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType  | uint256 | Type of the tool |
| resourcesAmount  | uint256 | The amount of Tree tokens to craft a tool |
| artifactsAmounts  | uint256[] | The amount of artifacts to craft a tool |

### ToolPropertiesSet

```solidity
event ToolPropertiesSet(uint256 toolType)
```

Indicates that tool type&#39;s properties have been changed



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolType  | uint256 | The type of the tools to change the properties of |

### ToolRepaired

```solidity
event ToolRepaired(uint256 toolId)
```

Indicates that a tool has been fully repaired



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId  | uint256 | The ID of the repaired tool |

### Transfer

```solidity
event Transfer(address from, address to, uint256 toolType, uint256 toolId)
```



*Indicates that one tool of type `toolType` with `toolId` was transferred      from `from` to `to`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from  | address | The sender of tokens |
| to  | address | The receiver of tokens |
| toolType  | uint256 | Type of the tool |
| toolId  | uint256 | The ID of the tool transferred |

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



