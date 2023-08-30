# IMining



> Interface for Mining contract





## Methods

### endMining

```solidity
function endMining(uint256 toolId) external nonpayable
```

Ends mining session started with the tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | The ID of the tool used in the session |

### pause

```solidity
function pause() external nonpayable
```

Pauses contract if it&#39;s active. Activates it if it&#39;s paused




### startMining

```solidity
function startMining(uint256 toolId, address user, bytes rewards, bytes signature, uint256 nonce) external nonpayable
```

Start a new mining session with a tool



#### Parameters

| Name | Type | Description |
|---|---|---|
| toolId | uint256 | The ID of the tool to mine with |
| user | address | The user who started mining |
| rewards | bytes | Encoded rewards for mining |
| signature | bytes | Backend signature |
| nonce | uint256 | Unique integer |



## Events

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



