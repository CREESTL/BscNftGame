// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/// @title Interface for Gem token contract
interface IGem {
    /// @notice Indicates that address has been blocked from transferring and receiving tokens
    event Blocked(address addr);
    /// @notice Indicates that address has been unblocked from transferring and receiving tokens
    event Unblocked(address addr);

    /// @notice Changes compensator
    /// @param compensator The new compensator
    function setCompensator(address compensator) external;

    /// @notice Changes compensation rate
    /// @param compensationRate The new compensation rate
    function setCompensationRate(uint256 compensationRate) external;

    /// @notice Block address from transferring and receiving tokens
    /// @param addr The address to block
    /// @param isBlocked True to block address. False to unblock address
    function blockAddress(address addr, bool isBlocked) external;

    /// @notice Mints some amount of Gems to compensate fee in BNB tokens
    /// @param to The address to mint Gems to
    /// @param bnbAmount The amount of BNB to compensate
    function compensateBnb(address to, uint256 bnbAmount) external;

    /// @notice Returns the amount of decimals of the token
    /// @return The amount of decimals of the token
    function decimals() external pure returns (uint8);
}
