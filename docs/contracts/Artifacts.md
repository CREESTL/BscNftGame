# Artifacts



> Artifact tokens can be aquired during mining        Artifacts are used to craft tools





## Methods

### addNewArtifact

```solidity
function addNewArtifact(string newUri) external nonpayable
```

See {IArtifacts-addNewArtifact}



#### Parameters

| Name | Type | Description |
|---|---|---|
| newUri | string | undefined |

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

### getArtifactsTypesAmount

```solidity
function getArtifactsTypesAmount() external view returns (uint256)
```

See {IArtifacts-getArtifactsTypesAmount}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getBaseUri

```solidity
function getBaseUri() external view returns (string)
```

See {IArtifacts-getBaseUri}




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### initialize

```solidity
function initialize(address _toolsContractAddress, string _baseUrl, address _blackListContractAddress) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _toolsContractAddress | address | undefined |
| _baseUrl | string | undefined |
| _blackListContractAddress | address | undefined |

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

### lootArtifact

```solidity
function lootArtifact(address user, uint256 artifactType) external nonpayable
```

See {IArtifacts-lootArtifact}



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | undefined |
| artifactType | uint256 | undefined |

### mint

```solidity
function mint(uint256 artifactType, address to, uint256 amount) external nonpayable
```

See {IArtifacts-mint}



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType | uint256 | undefined |
| to | address | undefined |
| amount | uint256 | undefined |

### mintBatch

```solidity
function mintBatch(address to, uint256[] artifactTypes, uint256[] amounts) external nonpayable
```

See {IArtifacts-mintBatch}



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| artifactTypes | uint256[] | undefined |
| amounts | uint256[] | undefined |

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

See {IArtifacts-pause}




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


### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data) external nonpayable
```



*See {IERC1155-safeBatchTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| ids | uint256[] | undefined |
| amounts | uint256[] | undefined |
| data | bytes | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data) external nonpayable
```



*See {IERC1155-safeTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| id | uint256 | undefined |
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

### setBaseUri

```solidity
function setBaseUri(string newBaseUri) external nonpayable
```

See {IArtifacts-setBaseUri}



#### Parameters

| Name | Type | Description |
|---|---|---|
| newBaseUri | string | undefined |

### setToolsAddress

```solidity
function setToolsAddress(address toolsAddress) external nonpayable
```

See {IArtifacts-setToolsAddress}



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolsAddress | address | undefined |

### setUri

```solidity
function setUri(uint256 artifactType, string newUri) external nonpayable
```

See {IArtifacts-setUri}



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType | uint256 | undefined |
| newUri | string | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

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
function uri(uint256 artifactType) external view returns (string)
```

See {IArtifacts-uri}



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |



## Events

### AddNewArtifact

```solidity
event AddNewArtifact(uint256 artifactType, string newUri)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType  | uint256 | undefined |
| newUri  | string | undefined |

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

### BaseUriChanged

```solidity
event BaseUriChanged(string newBaseUri)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newBaseUri  | string | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

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

### UriChanged

```solidity
event UriChanged(uint256 artifactType, string newUri)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType  | uint256 | undefined |
| newUri  | string | undefined |



