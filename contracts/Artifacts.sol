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

import "hardhat/console.sol";

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

    event AddNewArtifact(uint256);

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "Artifacts: user in blacklist");
        _;
    }

    function initialize(
        string memory _baseUrl,
        address _blackListContractAddress
    ) public initializer {
        _baseURI = _baseUrl;
        _blacklist = IBlackList(_blackListContractAddress);

        _artifactTypes = 6;

        __ERC1155_init("");
        __Ownable_init();
        __Pausable_init();
    }

    function mint(
        uint256 artifactType,
        address to,
        uint256 amount,
        bytes memory data
    ) external virtual onlyOwner whenNotPaused isInBlacklist(to) {
        require(artifactType <= _artifactTypes, "Artifacts: This artifact doesn't exist");
        _mint(to, artifactType, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external virtual {
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

    function addNewArtifact()
        external
        virtual
        onlyOwner
    {
        _artifactTypes += 1;
        _tools.increaseArtifactAmount();
        emit AddNewArtifact(_artifactTypes);
    }

    function setToolsAddress(address toolsAddress) external onlyOwner {
        require(toolsAddress != address(0), "Artifacts: zero address");
        _tools = ITools(toolsAddress);
    }

    function uri(uint256 artifactType)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(artifactType <= _artifactTypes, "Artifacts: This artifact doesn't exist");
        return
            string(
                abi.encodePacked(
                    _baseURI,
                    Strings.toString(artifactType),
                    ".json"
                )
            );
    }

    function getArtifactsTypesAmount() external view returns (uint256) {
        return _artifactTypes;
    }
}
