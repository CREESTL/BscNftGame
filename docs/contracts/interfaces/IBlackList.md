# IBlackList



> Interface for the Blacklist contract





## Methods

### addToBlacklist

```solidity
function addToBlacklist(address user) external nonpayable
```

Adds a user to the blacklist



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The address of the user to add to the blacklist |

### check

```solidity
function check(address user) external nonpayable returns (bool)
```

Checks that user is blacklisted



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The address of the user to check |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | True if user is blacklisted. Otherwise - false |

### removeFromBlacklist

```solidity
function removeFromBlacklist(address user) external nonpayable
```

Removes a user from the blacklist



#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | The address of the user to remove from the blacklist |



## Events

### AddedToBlacklist

```solidity
event AddedToBlacklist(address user)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |

### RemovedFromBlacklist

```solidity
event RemovedFromBlacklist(address user)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user  | address | undefined |



