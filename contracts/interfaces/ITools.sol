// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface ITools is IERC1155Upgradeable {
    struct Tool {
        uint32 strengthCost;
        uint32 maxStrength;
        uint32 miningDuration;
        uint32 energyCost;
        uint32 energyId;
    }

    struct OwnedTool {
        uint128 toolType;
        uint128 strength;
    }

    function getToolProperties(address user, uint256 toolId)
        external
        view
        returns (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        );

    function getResourceAddress(uint256 resourceId)
        external
        view
        returns (address);

    function getArtifactsAddress() external view returns (address);

    function getMiningAddress() external view returns (address);

    function increaseArtifactAmount() external;

    function corrupt(
        address user,
        uint256 toolId,
        uint256 strengthCost
    ) external;

    function getArtifactsTypesAmount() external view returns (uint256);

    function getResourceAmount() external view returns (uint256);
}
