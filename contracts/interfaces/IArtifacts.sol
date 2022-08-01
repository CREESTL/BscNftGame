// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

interface IArtifacts is IERC1155Upgradeable {
    struct Artifact {
        string name;
        uint128 level;
    }

    function lootArtifact(address user, uint256 artifactType) external;
}
