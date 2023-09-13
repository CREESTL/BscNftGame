// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

/// @title Interface for Mining contract
interface IMining {
    /// @dev Represents a mining session of a user
    ///      One user can have multiple session simultaniously
    struct MiningSession {
        uint32 toolId; // The ID of the tool used for mining. Unique key of session
        bool started; // True if session is started
        bool ended; // True if session has ended
        uint32 endTime; // The time when session has ended
        uint32 energyCost; // The cost of mining process in Berry tokens
        uint16 strengthCost; // The cost of mining process in tool strength
        uint32 nonce; // Unique integer
    }

    /// @dev Used to prevent 'Stack too deep' errors
    struct Args {
        uint256 toolId;
        address user;
        uint256 nonce;
        bytes signature;
        uint256[] resources;
        uint256[] artifacts;
    }

    /// @notice Indicates that new mining session has started
    event MiningStarted(address user, MiningSession session);
    /// @notice Indicates that mining session has ended
    event MiningEnded(address user, MiningSession session);
    /// @notice Indicates that user has claimed his rewards
    event RewardsClaimed(
        address user,
        uint256[] resources,
        uint256[] artifacts
    );

    /// @notice Pauses contract if it's active. Activates it if it's paused
    function pause() external;

    /// @notice Start a new mining session with a tool
    /// @param toolId The ID of the tool to mine with
    /// @param user The user who started mining
    /// @param rewards Encoded rewards for mining
    /// @param signature Backend signature
    /// @param nonce Unique integer
    function startMining(
        uint256 toolId,
        address user,
        bytes calldata rewards,
        bytes calldata signature,
        uint256 nonce
    ) external;

    /// @notice Ends mining session started with the tool
    /// @param toolId The ID of the tool used in the session
    function endMining(uint256 toolId) external;
}
