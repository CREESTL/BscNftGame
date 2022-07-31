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

    // artifact type => level
    mapping(uint256 => uint256) private _artifactsLevel;
    // artifact type => artifact name
    mapping(uint256 => string) private _artifactsName;
    // user address => (artifact type => Artifact)
    mapping(address => mapping(uint256 => Artifact)) private _ownedArtifacts;

    event AddNewArtifact(uint256);

    function initialize(
        string memory _baseUrl,
        address _blackListContractAddress
    ) public initializer {
        _baseURI = _baseUrl;
        _blacklist = IBlackList(_blackListContractAddress);

        _artifactTypes = 6;
        _artifactsName[1] = "Magic smoothie";
        _artifactsName[2] = "Money tree";
        _artifactsName[3] = "Emerald";
        _artifactsName[4] = "Goldberry";
        _artifactsName[5] = "Diamond";
        _artifactsName[6] = "Golden tree";

        _artifactsLevel[1] = 3;
        _artifactsLevel[2] = 3;
        _artifactsLevel[3] = 3;
        _artifactsLevel[4] = 4;
        _artifactsLevel[5] = 4;
        _artifactsLevel[6] = 4;

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
        super._afterTokenTransfer(operator, from, to, ids, amounts, data);
        for (uint256 counter = 0; counter < ids.length; counter++) {
            _ownedArtifacts[to][ids[counter]] = Artifact({
                name: _ownedArtifacts[from][ids[counter]].name,
                level: _ownedArtifacts[from][ids[counter]].level
            });
            delete _ownedArtifacts[from][ids[counter]];
        }
    }

    function mint(
        uint256 artifactType,
        address to,
        uint256 amount,
        bytes memory data
    ) external virtual onlyOwner whenNotPaused isInBlacklist(to) {
        require(
            _artifactTypes != 0,
            "Artifacts: there is no awailable artifacts"
        );
        require(artifactType < _artifactTypes, "This artifact doesn't exist.");
        _mint(to, artifactType, amount, data);
        _ownedArtifacts[to][artifactType] = Artifact({
            name: _artifactsName[artifactType],
            level: uint128(_artifactsLevel[artifactType])
        });
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external virtual {
        for (uint256 counter = 0; counter < ids.length; counter++) {
            require(
                _artifactTypes != 0,
                "Artifacts: there is no awailable artifacts"
            );
            require(
                ids[counter] <= _artifactTypes,
                "Artifacts: this artifact type doesn't exists"
            );
        }

        _mintBatch(to, ids, amounts, data);

        for (uint256 counter = 0; counter < ids.length; counter++) {
            for (uint256 i = 0; i < amounts[i]; i++) {
                _ownedArtifacts[to][ids[counter]] = Artifact({
                    name: _artifactsName[ids[counter]],
                    level: uint128(_artifactsLevel[ids[counter]])
                });
            }
        }
    }

    // ----------------------------
    // override super functions
    // function setApprovalForAll(address operator, bool approved)
    //     public
    //     override(ERC1155Upgradeable, IERC1155Upgradeable)
    //     isInBlacklist(_msgSender())
    // {
    //     super.setApprovalForAll(operator, approved);
    // }

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 id,
    //     uint256 amount,
    //     bytes memory data
    // )
    //     public
    //     virtual
    //     override(ERC1155Upgradeable, IERC1155Upgradeable)
    //     isInBlacklist(from)
    // {
    //     super.safeTransferFrom(from, to, id, amount, data);
    // }

    // function safeBatchTransferFrom(
    //     address from,
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data
    // )
    //     public
    //     virtual
    //     override(ERC1155Upgradeable, IERC1155Upgradeable)
    //     isInBlacklist(from)
    // {
    //     super.safeBatchTransferFrom(from, to, ids, amounts, data);
    // }

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
        _artifactsLevel[_artifactTypes - 1] = _level;
        _artifactsName[_artifactTypes - 1] = name;
        _tools.increaseArtifactAmount();
        emit AddNewArtifact(_artifactTypes);
    }

    function setToolsAddress(address toolsAddress) external onlyOwner {
        require(toolsAddress != address(0));
        _tools = ITools(toolsAddress);
    }

    function uri(uint256 artifactType)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(artifactType <= _artifactTypes, "This token doesn't exist");
        return
            string(
                abi.encodePacked(
                    _baseURI,
                    Strings.toString(artifactType),
                    ".json"
                )
            );
    }

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "User in blacklist");
        _;
    }
}
