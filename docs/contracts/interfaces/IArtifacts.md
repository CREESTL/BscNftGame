# IArtifacts



> Interface for the Artifacts contract





## Methods

### addNewArtifact

```solidity
function addNewArtifact(string newUri) external nonpayable
```

Adds a new artifact with the provided URI



#### Parameters

| Name | Type | Description |
|---|---|---|
| newUri | string | The URI of a new artifact |

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

### getArtifactsTypesAmount

```solidity
function getArtifactsTypesAmount() external view returns (uint256)
```

Returns the amount of types of artifacts




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of types of artifacts |

### getBaseUri

```solidity
function getBaseUri() external view returns (string)
```

Returns the base URI for IPFS




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | Base URI for IPFS |

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

### lootArtifact

```solidity
function lootArtifact(address user, uint256 artifactType) external nonpayable
```

Mints a single artifact if Mining contract requests



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The receiver of artifact |
| artifactType | uint256 | The type of artifact to mint |

### mint

```solidity
function mint(uint256 artifactType, address to, uint256 amount) external nonpayable
```

Mints `amount` of artifacts of `artifactType` to `to`



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType | uint256 | The type of artifact to mint |
| to | address | The receiver of artifacts |
| amount | uint256 | The amount of artifacts to mint |

### mintBatch

```solidity
function mintBatch(address to, uint256[] artifactTypes, uint256[] amounts) external nonpayable
```

Mints batches of artifacts



#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | The receiver of artifacts |
| artifactTypes | uint256[] | The types of artifacts to mint |
| amounts | uint256[] | The amount of artifacts of each type to mint |

### pause

```solidity
function pause() external nonpayable
```

Pauses contract if it&#39;s active. Activates it if it&#39;s paused




### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data) external nonpayable
```



*xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}. Emits a {TransferBatch} event. Requirements: - `ids` and `amounts` must have the same length. - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the acceptance magic value.*

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



*Transfers `amount` tokens of token type `id` from `from` to `to`. Emits a {TransferSingle} event. Requirements: - `to` cannot be the zero address. - If the caller is not `from`, it must have been approved to spend ``from``&#39;s tokens via {setApprovalForAll}. - `from` must have a balance of tokens of type `id` of at least `amount`. - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the acceptance magic value.*

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



*Grants or revokes permission to `operator` to transfer the caller&#39;s tokens, according to `approved`, Emits an {ApprovalForAll} event. Requirements: - `operator` cannot be the caller.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### setBaseUri

```solidity
function setBaseUri(string newBaseUri) external nonpayable
```

Changes the base URI for IPFS



#### Parameters

| Name | Type | Description |
|---|---|---|
| newBaseUri | string | The new base URI for IPFS |

### setToolsAddress

```solidity
function setToolsAddress(address toolsAddress) external nonpayable
```

Changes the address of Tools contract



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolsAddress | address | The new address of Tools contract |

### setUri

```solidity
function setUri(uint256 artifactType, string newUri) external nonpayable
```

Changes the URI for the specific artifact type



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType | uint256 | The type of the artifact |
| newUri | string | The new URI |

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
function uri(uint256 artifactType) external view returns (string)
```

Returns the URI for a specific artifact type



#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType | uint256 | The type of the artifact to get a URI for |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | The URI for a specific artifact type |



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

### UriChanged

```solidity
event UriChanged(uint256 artifactType, string newUri)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| artifactType  | uint256 | undefined |
| newUri  | string | undefined |



