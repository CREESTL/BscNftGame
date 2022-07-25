// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IBlackList.sol";
import "./interfaces/IArtifacts.sol";

contract Artifacts is Initializable, OwnableUpgradeable, ERC1155Upgradeable, IArtifacts, PausableUpgradeable {
    IBlackList public blackList;

    string public baseUri;
    uint256 public idCount;
    // map artifact id and token level
    mapping(uint256 => uint256) public level;
    // map artifact id and artifact name
    mapping(uint256 => string) public artifactName;

    function initialize(string memory _baseUri, address _blackListContractAddress) initializer public {
        baseUri = _baseUri;
        blackList = IBlackList(_blackListContractAddress);

        idCount = 6;
        artifactName[0] = "Magic smoothie";
        artifactName[1] = "Money tree";
        artifactName[2] = "Emerald";
        artifactName[3] = "Goldberry";
        artifactName[4] = "Diamond";
        artifactName[5] = "Golden tree";

        level[0] = 3;
        level[1] = 3;
        level[2] = 3;
        level[3] = 4;
        level[4] = 4;
        level[5] = 4;

        __ERC1155_init("");
        __Ownable_init();
        __Pausable_init();
        _pause();
    }

    function mint(uint256 artifactId, address to, uint256 amount) onlyOwner whenNotPaused isInBlacklist(to) override external {
        require(artifactId < idCount, "This artifact doesn't exist.");
        for (uint256 index = 0; index < amount; index++) {
            _mint(to, artifactId, 1, "");
        }
    }

    // ----------------------------
    // override super functions 
    function setApprovalForAll(address operator, bool approved) override(IArtifacts, ERC1155Upgradeable) isInBlacklist(msg.sender) public {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) override(IArtifacts, ERC1155Upgradeable) isInBlacklist(from) public {
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) override(IArtifacts, ERC1155Upgradeable) isInBlacklist(from) public {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
    
    // ----------------------------
    // administration
    function pause() onlyOwner external {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    function addNewArtifact(string memory name, uint256 _level) onlyOwner virtual external {
        idCount += 1;
        level[idCount-1] = _level;
        artifactName[idCount-1] = name;
    }

    function uri(uint256 id) view virtual override public returns(string memory) {
        require(id < idCount, "This token doesn't exist");
        return string(abi.encodePacked(baseUri, Strings.toString(id), ".json"));
    }

    modifier isInBlacklist(address user) {
        require(!blackList.check(user), "User in blacklist");
        _;
    }
}