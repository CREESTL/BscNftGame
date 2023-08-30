// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/// @title Interface for the Blacklist contract
interface IBlackList {
    event AddedToBlacklist(address user);
    event RemovedFromBlacklist(address user);

    /// @notice Checks that user is blacklisted
    /// @param user The address of the user to check
    /// @return True if user is blacklisted. Otherwise - false
    function check(address user) external returns (bool);

    /// @notice Adds a user to the blacklist
    /// @param user The address of the user to add to the blacklist
    function addToBlacklist(address user) external;

    /// @notice Removes a user from the blacklist
    /// @param user The address of the user to remove from the blacklist
    function removeFromBlacklist(address user) external;
}
