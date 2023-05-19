// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IBlackList.sol";
import "./interfaces/IArtifacts.sol";
import "./interfaces/ITools.sol";

contract Artifacts is
    Initializable,
    OwnableUpgradeable,
    ERC1155Upgradeable,
    IArtifacts,
    PausableUpgradeable
{
    IBlackList private _blacklist;
    ITools private _tools;

    string private _baseURI;
    uint256 private _artifactTypes;

    mapping(uint256 => string) _typesToUris;

    event AddNewArtifact(uint256);
    event BaseUriChanged(string);
    event UriChanged(uint256, string);

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "Artifacts: user in blacklist");
        _;
    }

    function initialize(
        address _toolsContractAddress,
        string memory _baseUrl,
        address _blackListContractAddress
    ) public initializer {
        _tools = ITools(_toolsContractAddress);
        _baseURI = _baseUrl;
        _blacklist = IBlackList(_blackListContractAddress);

        __ERC1155_init("");
        __Ownable_init();
        __Pausable_init();
    }

    function mint(
        uint256 artifactType,
        address to,
        uint256 amount,
        bytes memory data
    ) external onlyOwner whenNotPaused isInBlacklist(to) {
        require(
            artifactType <= _artifactTypes,
            "Artifacts: This artifact doesn't exist"
        );
        _mint(to, artifactType, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyOwner whenNotPaused isInBlacklist(to) {
        for (uint256 counter = 0; counter < ids.length; counter++) {
            require(
                ids[counter] <= _artifactTypes,
                "Artifacts: this artifact type doesn't exists"
            );
        }

        _mintBatch(to, ids, amounts, data);
    }

    function lootArtifact(address user, uint256 artifactType) external {
        require(
            _msgSender() == _tools.getMiningAddress(),
            "Artifacts: only mining contract can call this function"
        );
        _mint(user, artifactType, 1, "");
    }

    // ----------------------------
    // administration
    function pause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    function addNewArtifact() public onlyOwner {
        _addNewArtifact();
    }

    function setToolsAddress(address toolsAddress) external onlyOwner {
        require(toolsAddress != address(0), "Artifacts: zero address");
        _tools = ITools(toolsAddress);
    }

    function getBaseUri() external view returns (string memory) {
        return _baseURI;
    }

    function setBaseUri(string calldata newBaseUri) external onlyOwner {
        _setBaseUri(newBaseUri);
    }

    function setUri(
        uint256 artifactType,
        string calldata newUri
    ) external onlyOwner {
        _setUri(artifactType, newUri);
    }

    function uri(
        uint256 artifactType
    ) public view override returns (string memory) {
        require(
            artifactType <= _artifactTypes,
            "Artifacts: This artifact doesn't exist"
        );
        return _typesToUris[artifactType];
    }

    function getArtifactsTypesAmount() external view returns (uint256) {
        return _artifactTypes;
    }

    function _addNewArtifact() private {
        _artifactTypes += 1;
        _tools.increaseArtifactAmount();
        // New artifact gets URI formed from base URI and artifact's type
        _typesToUris[_artifactTypes] = string(
            abi.encodePacked(
                _baseURI,
                Strings.toString(_artifactTypes),
                ".json"
            )
        );
        emit AddNewArtifact(_artifactTypes);
    }

    function _setBaseUri(string calldata newBaseUri) private {
        _baseURI = newBaseUri;
        emit BaseUriChanged(newBaseUri);
    }

    function _setUri(uint256 artifactType, string calldata newUri) private {
        require(
            artifactType <= _artifactTypes,
            "Artifacts: This artifact doesn't exist"
        );
        _typesToUris[artifactType] = newUri;
        emit UriChanged(artifactType, newUri);
    }
}
