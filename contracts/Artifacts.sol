// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "./interfaces/IBlackList.sol";

contract Artifacts is Initializable, OwnableUpgradeable, ERC1155Upgradeable, PausableUpgradeable {
    uint256 constant public MAGIC_SMOOTHIE = 0;
    uint256 constant public MONEY_TREE = 1;
    uint256 constant public EMERALD = 2;
    uint256 constant public GOLDBERRY = 3;
    uint256 constant public DIAMOND = 4;
    uint256 constant public GOLDEN_TREE = 5;

    string private baseUrl;
    IBlackList private blackList;
    // map artifact id and token level
    mapping(uint256 => uint256) public level;
    // map artifact id and artifact name
    mapping(uint256 => string) public artifactName;

    function initialize(string memory _baseUrl, address _blackListContractAddress) initializer public {
        baseUrl = _baseUrl;
        blackList = IBlackList(_blackListContractAddress);

        artifactName[MAGIC_SMOOTHIE] = "Magic smoothie";
        artifactName[MONEY_TREE] = "Money tree";
        artifactName[EMERALD] = "Emerald";
        artifactName[GOLDBERRY] = "Goldberry";
        artifactName[DIAMOND] = "Diamond";
        artifactName[GOLDEN_TREE] = "Golden tree";

        level[MAGIC_SMOOTHIE] = 3;
        level[MONEY_TREE] = 3;
        level[EMERALD] = 3;
        level[GOLDBERRY] = 4;
        level[DIAMOND] = 4;
        level[GOLDEN_TREE] = 4;

        __ERC1155_init(string.concat(baseUrl, "{id}.json"));
        __Ownable_init();
        __Pausable_init();
    }

    function mint(uint256 artifactId, address to, uint256 amount) onlyOwner whenNotPaused isInBlacklist(to) external {
        for (uint256 index = 0; index < amount; index++) {
            _mint(to, artifactId, 1, "");
        }
    }

    // ----------------------------
    // override super functions 
    function setApprovalForAll(address operator, bool approved) override isInBlacklist(msg.sender) public {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) override isInBlacklist(from) public {
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) override isInBlacklist(from) public {
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

    modifier isInBlacklist(address user) {
        require(!blackList.check(user), "User in blacklist");
        _;
    }
}