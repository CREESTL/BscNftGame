// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IBlackList.sol";

/// @title Blacklist contract. Blacklisted addresses cannot use main functions
///        of other contracts
contract BlackList is IBlackList, Ownable {
    /// @dev Mapping of users in the blacklist. If key value is True - user is blacklisted.
    ///      Otherwise, user is not blacklisted
    mapping(address => bool) private _blacklisted;

    /// @notice See {IBlacklist-check}
    function check(address user) external view returns (bool) {
        return _blacklisted[user];
    }

    /// @notice See {IBlacklist-addToBlacklist}
    function addToBlacklist(address user) external onlyOwner {
        require(_blacklisted[user] == false, "User already in blacklist");
        _blacklisted[user] = true;
        emit AddedToBlacklist(user);
    }

    /// @notice See {IBlacklist-removeFromBlacklist}
    function removeFromBlacklist(address user) external onlyOwner {
        require(_blacklisted[user] == true, "User is not in blacklist");
        _blacklisted[user] = false;
        emit RemovedFromBlacklist(user);
    }
}
