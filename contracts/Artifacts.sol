// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IBlackList.sol";
import "./interfaces/IArtifacts.sol";

contract Artifacts is
    Initializable,
    OwnableUpgradeable,
    ERC1155Upgradeable,
    IArtifacts,
    PausableUpgradeable
{
    IBlackList private _blacklist;

    string private _baseURI;
    uint256 private _artifactTypes;

    // artifact type => level
    mapping(uint256 => uint256) private _artifactLevel;
    // artifact type => artifact name
    mapping(uint256 => string) private _artifactNames;
    // user address => (token id => Artifact)
    mapping(address => mapping(uint256 => Artifact)) private _artifacts;

    function initialize(
        string memory _baseUrl,
        address _blackListContractAddress
    ) public initializer {
        _baseURI = _baseUrl;
        _blacklist = IBlackList(_blackListContractAddress);

        _artifactTypes = 6;
        _artifactNames[1] = "Magic smoothie";
        _artifactNames[2] = "Money tree";
        _artifactNames[3] = "Emerald";
        _artifactNames[4] = "Goldberry";
        _artifactNames[5] = "Diamond";
        _artifactNames[6] = "Golden tree";

        _artifactLevel[1] = 3;
        _artifactLevel[2] = 3;
        _artifactLevel[3] = 3;
        _artifactLevel[4] = 4;
        _artifactLevel[5] = 4;
        _artifactLevel[6] = 4;

        __ERC1155_init("");
        __Ownable_init();
        __Pausable_init();
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        // TODO: change _artifacts when transfer
    }

    function mint(
        uint256 artifactType,
        address to,
        uint256 amount
    ) external virtual onlyOwner whenNotPaused isInBlacklist(to) {
        require(artifactType < _artifactTypes, "This artifact doesn't exist.");
        for (uint256 index = 0; index < amount; index++) {
            _mint(to, artifactType, 1, "");
        }
    }

    // ----------------------------
    // override super functions
    function setApprovalForAll(address operator, bool approved)
        public
        override(ERC1155Upgradeable, IERC1155Upgradeable)
        isInBlacklist(_msgSender())
    {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override(ERC1155Upgradeable, IERC1155Upgradeable)
        isInBlacklist(from)
    {
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override(ERC1155Upgradeable, IERC1155Upgradeable)
        isInBlacklist(from)
    {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
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

    function addNewArtifact(string memory name, uint256 _level)
        external
        virtual
        onlyOwner
    {
        _artifactTypes += 1;
        _artifactLevel[_artifactTypes - 1] = _level;
        _artifactNames[_artifactTypes - 1] = name;
    }

    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(id < _artifactTypes, "This token doesn't exist");
        return
            string(abi.encodePacked(_baseURI, Strings.toString(id), ".json"));
    }

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "User in blacklist");
        _;
    }
}
