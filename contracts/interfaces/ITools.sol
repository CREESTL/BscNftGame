// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

/// @title Interface for Tools contract
interface ITools is IERC1155Upgradeable {
    /// @dev Types of resources
    enum Resources {
        Berry, // a.k.a. FOOD
        Tree, // a.k.a. TECH
        Gold // a.k.a. AURA
    }

    /// @dev Recipe to craft a tool
    struct Recipe {
        // Amount of Tree to spend
        uint256 resourcesAmount;
        // Mapping (artifacts id => amonut)
        mapping(uint256 => uint256) artifacts;
    }

    /// @dev Struct of a tool
    struct Tool {
        uint32 strengthCost; // Cost of using this tool for mining. Strength decreases each time
        uint32 maxStrength; // Max strength of a tool
        uint32 miningDuration; // The duraion of mining session with this tool
        uint32 energyCost; // Cost in Berry tokens to start mining session with this tool
    }

    /// @dev Represents a tool owned by a user
    struct OwnedTool {
        uint128 toolType; // Type of the tool
        uint128 strength; // Current strength of the tool
    }

    /// @notice Indicates that a new tool was added
    /// @param toolType Type of the tool
    /// @param newURI URI of the tool
    event AddTool(uint256 toolType, string newURI);

    /// @notice Indicates that a tool was crafted
    /// @param user User who crafted a tool
    /// @param toolType Type of the tool
    /// @param toolId Unique ID of the tool
    event Craft(address user, uint256 toolType, uint256 toolId);

    /// @notice Indicates that tool recipe was created or updated
    /// @param toolType Type of the tool
    /// @param resourcesAmount The amount of Tree tokens to craft a tool
    /// @param artifactsAmounts The amount of artifacts to craft a tool
    event RecipeCreatedOrUpdated(
        uint256 toolType,
        uint256 resourcesAmount,
        uint256[] artifactsAmounts
    );

    /// @notice Indicates that a new base URI was set
    /// @param baseURI A new base URI
    event BaseURI(string baseURI);

    /// @notice Indicates that a tool has been fully repaired
    /// @param toolId The ID of the repaired tool
    event ToolRepaired(uint256 toolId);

    /// @notice Indicates that tool type's properties have been changed
    /// @param toolType The type of the tools to change the properties of
    event ToolPropertiesSet(uint256 toolType);

    /// @dev Indicates that `amount` of tools of `toolType` was minted to `to`
    /// @param to Receiver of tool
    /// @param toolType Type of the tool
    /// @param amount The amount of tools minted
    event MintType(address to, uint256 toolType, uint256 amount);

    /// @dev Indicates that one tool of `toolType` with `toolId` was minted to `to`
    /// @param to Receiver of tool
    /// @param toolType Type of the tool
    /// @param toolId The ID of the tool minted
    event MintId(address to, uint256 toolType, uint256 toolId);

    /// @dev Indicates that one tool of type `toolType` with `toolId` was transferred
    ///      from `from` to `to`
    /// @param from The sender of tokens
    /// @param to The receiver of tokens
    /// @param toolType Type of the tool
    /// @param toolId The ID of the tool transferred
    event Transfer(address from, address to, uint256 toolType, uint256 toolId);

    /// @notice Returns properties of the tool
    /// @param user User owning a tool
    /// @param toolId The ID of the tool
    /// @return toolType Type of the tool
    /// @return strength Current strength of the tool
    /// @return strengthCost Cost in strength to start mining with the tool
    /// @return miningDuration Duration of a mining session with the tool
    /// @return energyCost Cost in Berry tokens to start mining session with the tool
    function getToolProperties(
        address user,
        uint256 toolId
    )
        external
        view
        returns (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        );

    /// @notice Returns properties of type of the tool
    /// @param toolType Type of the tool to get the properties of
    /// @return maxStrength Max strength of the tool type
    /// @return strengthCost Cost in strength to start mining with the tool
    /// @return miningDuration Duration of a mining session with the tool
    /// @return energyCost Cost in Berry tokens to start mining session with the tool
    function getToolTypeProperties(
        uint256 toolType
    )
        external
        view
        returns (
            uint256 maxStrength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        );

    /// @notice Returns the address of resource contract of a specific resource type
    /// @param resourceId The type of resource
    /// @return The address of resource contract of a specific resource type
    function getResourceAddress(
        uint256 resourceId
    ) external view returns (address);

    /// @notice Returns the address of Artifacts contract
    /// @return The address of Artifacts contract
    function getArtifactsAddress() external view returns (address);

    /// @notice Returns current strength of the tool
    /// @param toolId The ID of the tool
    /// @return Current strength of the tool
    function getStrength(uint256 toolId) external view returns (uint256);

    /// @notice Returns the address of Mining contract
    /// @return The address of Mining contract
    function getMiningAddress() external view returns (address);

    /// @notice Returns the amount of types of resources
    /// @return The amount of types of resources
    function getResourcesTypesAmount() external view returns (uint256);

    /// @notice Returns the amount of types of artifacts
    /// @return The amount of types of artifacts
    function getArtifactsTypesAmount() external view returns (uint256);

    /// @notice Returns the amount of types of tools
    /// @return The amount of types of tools
    function getToolsTypesAmount() external view returns (uint256);

    /// @notice Adds a new tool.
    /// @param maxStrength The maximum strength of the tool
    /// @param miningDuration The duration of mining session with the tool
    /// @param energyCost The cost in Berry tokens to start mining session with the tool
    /// @param strengthCost The cost in tool strength to start mining session with it
    /// @param resourcesAmount Amount of Tree tokens requires to craft a tool
    /// @param artifactsAmounts Amounts of each type of artifacts to craft a tool
    /// @param newURI The URI of the tool
    /// @return The type of the new tool
    function addTool(
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost,
        uint256 resourcesAmount,
        uint256[] calldata artifactsAmounts,
        string calldata newURI
    ) external returns (uint256);

    /// @notice Changes properties of the tool
    /// @param toolType The type of the tool
    /// @param maxStrength The maximum strength of the tool
    /// @param miningDuration The duration of mining session with the tool
    /// @param energyCost The cost in Berry tokens to start mining session with the tool
    /// @param strengthCost The cost in tool strength to start mining session with it
    function setToolProperties(
        uint256 toolType,
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost
    ) external;

    /// @notice Crafts a new tools after it was added
    /// @param toolType The type of the tool
    function craft(uint256 toolType) external;

    /// @notice Increases a number of types of artifacts by one
    function increaseArtifactsTypesAmount() external;

    /// @notice Decreases tool's strength when mining
    /// @param user The user who is mining
    /// @param toolId The ID of the tool used for mining
    /// @param strengthCost The amount of tool's strength subtracted from current strength
    function corrupt(
        address user,
        uint256 toolId,
        uint256 strengthCost
    ) external;

    /// @notice Changes address of Artifacts contract
    /// @param artifactsAddress The new address of Artifacts contract
    function setArtifactsAddress(address artifactsAddress) external;

    /// @notice Changes address of Mining contract
    /// @param miningAddress The new address of Mining contract
    function setMiningAddress(address miningAddress) external;

    /// @notice Pauses the contract if it's active. Activates it if it's paused
    function pause() external;

    /// @notice Mints `amount` tools of `toolType` to `to`
    /// @param to The receiver of tools
    /// @param toolType The type of the tool
    /// @param amount The amount of tools to mint
    function mint(address to, uint128 toolType, uint256 amount) external;

    /// @notice Mints batches of tools of different types to `to`
    /// @param to The receiver of tools
    /// @param toolTypes Types of tools
    /// @param amounts Amounts of tools
    function mintBatch(
        address to,
        uint256[] calldata toolTypes,
        uint256[] calldata amounts
    ) external;

    /// @notice Returns the recipe for the tool
    /// @param toolType The type of the tool
    /// @return resourcesAmount Amount of Tree resources to craft the tool
    /// @return artifactsAmounts Amounts of artifacts of different types to craft the tool
    function getRecipe(
        uint256 toolType
    )
        external
        view
        returns (uint256 resourcesAmount, uint256[] memory artifactsAmounts);

    /// @notice Returns the URI of the tool type
    /// @param toolType The type of the tool
    /// @return The URI of the tool type
    function uri(uint256 toolType) external view returns (string memory);

    /// @notice Changes the URI of the tool type
    /// @param toolType The type of the tool
    /// @param newURI The new URI
    function setURI(uint256 toolType, string calldata newURI) external;

    /// @notice Changes the base URI for tools
    /// @param baseURI The new base URI
    function setBaseURI(string calldata baseURI) external;

    /// @notice Changes the recipe of the tool
    /// @param toolType The type of the tool
    /// @param resourcesAmount The new amount of Tree to craft the tool
    function setRecipe(
        uint256 toolType,
        uint256 resourcesAmount,
        uint256[] calldata artifactsAmounts
    ) external;

    /// @notice Completely repairs the tool
    /// @param toolId The ID of the tool to repair
    function repairTool(uint256 toolId) external;

    /// @notice Transfers a single tool with `toolId` from `from` to `to`
    /// @param from Sender of tokens
    /// @param to Receiver of tokens
    /// @param toolId The ID of the tool to transfer
    /// @param amount Always equals to 1
    /// @param data Extra data (optional)
    function safeTransferFrom(
        address from,
        address to,
        uint256 toolId,
        uint256 amount,
        bytes memory data
    ) external;

    /// @notice Transfers one tool of each `toolIds` from `from` to `to`
    /// @param from Sender of tokens
    /// @param to Receiver of tokens
    /// @param toolIds IDs of tools to transfer
    /// @param amounts Each amount always equals to 1
    /// @param data Extra data (optional)
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory toolIds,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}
