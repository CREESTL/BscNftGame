// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IBlackList.sol";
import "./interfaces/IArtifacts.sol";
import "./interfaces/ITools.sol";

/// @title Artifact tokens can be aquired during mining
///        Artifacts are used to craft tools
contract Artifacts is
    Initializable,
    OwnableUpgradeable,
    ERC1155Upgradeable,
    IArtifacts,
    PausableUpgradeable
{
    /// @dev The address of the Blacklist contract
    IBlackList private _blacklist;
    /// @dev The address of the Tools contract
    ITools private _tools;

    /// @dev Base URI for IPFS
    string private _baseURI;

    /// @dev Number of types of artifacts
    /// @dev Starts with 0
    uint256 private _artifactTypes;

    /// @dev Mapping from artifact type to it's URI
    mapping(uint256 => string) private _typesToUris;

    /// @dev Checks that user is not in blacklist
    /// @param user The user to check
    modifier ifNotBlacklisted(address user) {
        require(!_blacklist.check(user), "Artifacts: user in blacklist");
        _;
    }

    function initialize(
        address _toolsContractAddress,
        string memory _baseUrl,
        address _blackListContractAddress
    ) external initializer {
        _tools = ITools(_toolsContractAddress);
        _baseURI = _baseUrl;
        _blacklist = IBlackList(_blackListContractAddress);

        __ERC1155_init("");
        __Ownable_init();
        __Pausable_init();
    }

    /// @notice See {IArtifacts-getArtifactsTypesAmount}
    function getArtifactsTypesAmount() external view returns (uint256) {
        return _artifactTypes;
    }

    /// @notice See {IArtifacts-getBaseUri}
    function getBaseUri() external view returns (string memory) {
        return _baseURI;
    }

    /// @notice See {IArtifacts-mint}
    function mint(
        uint256 artifactType,
        address to,
        uint256 amount
    ) external onlyOwner whenNotPaused ifNotBlacklisted(to) {
        require(
            artifactType <= _artifactTypes,
            "Artifacts: This artifact doesn't exist"
        );
        _mint(to, artifactType, amount, "");
    }

    /// @notice See {IArtifacts-mintBatch}
    function mintBatch(
        address to,
        uint256[] memory artifactTypes,
        uint256[] memory amounts
    ) external onlyOwner whenNotPaused ifNotBlacklisted(to) {
        for (uint256 counter = 0; counter < artifactTypes.length; counter++) {
            require(
                artifactTypes[counter] <= _artifactTypes,
                "Artifacts: this artifact type doesn't exists"
            );
        }

        _mintBatch(to, artifactTypes, amounts, "");
    }

    /// @notice See {IArtifacts-lootArtifact}
    function lootArtifact(
        address user,
        uint256 artifactType
    ) external ifNotBlacklisted(user) {
        require(
            _msgSender() == _tools.getMiningAddress(),
            "Artifacts: only mining contract can call this function"
        );
        _mint(user, artifactType, 1, "");
    }

    /// @notice See {IArtifacts-pause}
    function pause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @notice See {IArtifacts-addNewArtifact}
    function addNewArtifact(string memory newUri) external onlyOwner {
        _addNewArtifact(newUri);
    }

    /// @notice See {IArtifacts-setToolsAddress}
    function setToolsAddress(address toolsAddress) external onlyOwner {
        require(toolsAddress != address(0), "Artifacts: zero address");
        _tools = ITools(toolsAddress);
    }

    /// @notice See {IArtifacts-setBaseUri}
    function setBaseUri(string calldata newBaseUri) external onlyOwner {
        _setBaseUri(newBaseUri);
    }

    /// @notice See {IArtifacts-setUri}
    function setUri(
        uint256 artifactType,
        string calldata newUri
    ) external onlyOwner {
        _setUri(artifactType, newUri);
    }

    /// @notice See {IArtifacts-uri}
    function uri(
        uint256 artifactType
    )
        public
        view
        override(ERC1155Upgradeable, IArtifacts)
        returns (string memory)
    {
        require(
            artifactType <= _artifactTypes,
            "Artifacts: This artifact doesn't exist"
        );
        return _typesToUris[artifactType];
    }

    /// @dev Private implementation of `addNewArtifact`
    function _addNewArtifact(string memory newUri) private {
        _artifactTypes += 1;
        _tools.increaseArtifactsTypesAmount();
        // New artifact gets URI formed from base URI and uri from parameters
        // Example: ipfs://pinata.cloud/QmYqiEcxH58aTuQha2qxHp6c3zfv5NpNWxAhGQtGpBubwe
        _typesToUris[_artifactTypes] = string(
            abi.encodePacked(_baseURI, newUri)
        );
        emit AddNewArtifact(_artifactTypes, newUri);
    }

    /// @dev Private implementation of `setBaseUri`
    function _setBaseUri(string calldata newBaseUri) private {
        _baseURI = newBaseUri;
        emit BaseUriChanged(newBaseUri);
    }

    /// @dev Private implementation of `setUri`
    function _setUri(uint256 artifactType, string calldata newUri) private {
        require(
            artifactType <= _artifactTypes,
            "Artifacts: This artifact doesn't exist"
        );
        _typesToUris[artifactType] = newUri;
        emit UriChanged(artifactType, newUri);
    }
}
