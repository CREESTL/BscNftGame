// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

/// @title Interface for the Artifacts contract
interface IArtifacts is IERC1155Upgradeable {
    event AddNewArtifact(uint256 artifactType, string newUri);
    event BaseUriChanged(string newBaseUri);
    event UriChanged(uint256 artifactType, string newUri);

    /// @notice Returns the amount of types of artifacts
    /// @return The amount of types of artifacts
    function getArtifactsTypesAmount() external view returns (uint256);

    /// @notice Returns the base URI for IPFS
    /// @return Base URI for IPFS
    function getBaseUri() external view returns (string memory);

    /// @notice Mints `amount` of artifacts of `artifactType` to `to`
    /// @param artifactType The type of artifact to mint
    /// @param to The receiver of artifacts
    /// @param amount The amount of artifacts to mint
    function mint(uint256 artifactType, address to, uint256 amount) external;

    /// @notice Mints batches of artifacts
    /// @param to The receiver of artifacts
    /// @param artifactTypes The types of artifacts to mint
    /// @param amounts The amount of artifacts of each type to mint
    function mintBatch(
        address to,
        uint256[] memory artifactTypes,
        uint256[] memory amounts
    ) external;

    /// @notice Mints a single artifact if Mining contract requests
    /// @param user The receiver of artifact
    /// @param artifactType The type of artifact to mint
    function lootArtifact(address user, uint256 artifactType) external;

    /// @notice Pauses contract if it's active. Activates it if it's paused
    function pause() external;

    /// @notice Adds a new artifact with the provided URI
    /// @param newUri The URI of a new artifact
    function addNewArtifact(string memory newUri) external;

    /// @notice Changes the address of Tools contract
    /// @param toolsAddress The new address of Tools contract
    function setToolsAddress(address toolsAddress) external;

    /// @notice Changes the base URI for IPFS
    /// @param newBaseUri The new base URI for IPFS
    function setBaseUri(string calldata newBaseUri) external;

    /// @notice Changes the URI for the specific artifact type
    /// @param artifactType The type of the artifact
    /// @param newUri The new URI
    function setUri(uint256 artifactType, string calldata newUri) external;

    /// @notice Returns the URI for a specific artifact type
    /// @param artifactType The type of the artifact to get a URI for
    /// @return The URI for a specific artifact type
    function uri(uint256 artifactType) external view returns (string memory);
}
