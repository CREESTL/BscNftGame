// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface ITools is IERC1155Upgradeable {
    struct Tool {
        uint256 miningResource;
        uint256 strengthCost;
        uint256 maxStrength;
        // lock time while mining
        uint256 miningDuration;
        uint256 energyCost; 
        uint256 rewardRate;
    }

    struct OwnedTool {
        uint256 toolType;
        uint256 strength;
    }
}