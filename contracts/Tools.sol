// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IResources.sol";
import "./interfaces/IBlackList.sol";
import "./interfaces/IArtifacts.sol";
import "./interfaces/ITools.sol";

import "hardhat/console.sol";

contract Tools is
    Initializable,
    OwnableUpgradeable,
    ERC1155Upgradeable,
    PausableUpgradeable,
    IERC1155Receiver,
    ITools
{
    using Strings for uint256;

    IBlackList private _blacklist;
    IArtifacts private _artifacts;

    string private _baseURI;

    address private _miningAddress;

    struct Recipe {
        uint256 toolType;
        // resource id => amount
        mapping(uint256 => uint256) resources;
        // artifacts id => amonut
        mapping(uint256 => uint256) artifacts;
    }

    // tools counter
    uint256 private _toolIds;
    // tool types counter
    uint256 private _toolTypes;
    // artifacts counter
    uint256 private _artifactAmount;
    // recipes counter
    uint256 private _recipeAmount;
    // resources counter
    uint256 private _resourceAmount;

    // resource id => IResources
    mapping(uint256 => IResources) private _resources;
    // tool type => repair cost
    mapping(uint256 => uint256) private _repairCost;
    // tool id => uri
    mapping(uint256 => string) private _tokenURIs;
    // tool type => Tool
    mapping(uint256 => Tool) private _tools;
    // recipe id => Recipe
    mapping(uint256 => Recipe) private _recipes;

    // user address => (tool id => OwnedTool)
    mapping(address => mapping(uint256 => OwnedTool)) private _ownedTools;

    event AddTool(uint256 toolType);
    event Craft(address user, uint256);
    event CreateRecipe(uint256 recipeId);
    event BaseURI(string baseURI);

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory ids,
        uint256[] memory values,
        bytes calldata data
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, IERC165Upgradeable, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC165Upgradeable).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function initialize(
        address blacklistAddress,
        address berryAddress,
        address treeAddress,
        address goldAddress,
        string memory baseURI
    ) public initializer {
        _blacklist = IBlackList(blacklistAddress);

        _resources[1] = IResources(berryAddress);
        _resources[2] = IResources(treeAddress);
        _resources[3] = IResources(goldAddress);

        _artifactAmount = 6;
        _resourceAmount = 3;
        _baseURI = baseURI;

        __ERC1155_init("");
        __Pausable_init();
        __Ownable_init();
    }

    // ----------- Mint functions -----------

    function addTool(
        uint32 miningResource,
        uint32[] calldata miningArtifacts,
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost,
        uint32 rewardRate
    ) external virtual onlyOwner returns (uint256) {
        require(
            miningResource <= _resourceAmount,
            "Tools: invalid mining resource value"
        );
        for (uint256 counter = 0; counter < miningArtifacts.length; counter++) {
            require(
                miningArtifacts[counter] <= _artifactAmount,
                "Tools: invalid arifact value"
            );
        }
        require(maxStrength % 5 == 0, "Tools: invalid strength value");
        require(
            miningDuration > 0,
            "Tools: mining duration must be greather than zero"
        );

        _toolTypes++;
        uint256 newType = _toolTypes;
        _tools[newType].miningResource = miningResource;
        _tools[newType].maxStrength = maxStrength;
        _tools[newType].miningDuration = miningDuration;
        _tools[newType].energyCost = energyCost;
        _tools[newType].strengthCost = strengthCost;
        _tools[newType].rewardRate = rewardRate;

        emit AddTool(newType);
        return newType;
    }

    function mint(
        address account,
        uint128 toolType,
        uint256 amount
    ) public virtual onlyOwner isInBlacklist(account) {
        require(_toolTypes != 0, "Tools: no tools");
        require(toolType <= _toolTypes, "Tools: invalid id value");

        _mint(account, toolType, amount, "");
        for (uint256 counter = 0; counter < amount; counter++) {
            _toolIds++;
            _ownedTools[account][_toolIds] = OwnedTool({
                toolType: toolType,
                strength: _tools[toolType].maxStrength
            });
        }
    }

    function mintBatch(
        address to,
        uint256[] calldata toolTypes,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual onlyOwner isInBlacklist(to) {
        require(_toolTypes != 0, "Tools: no tools");
        for (uint256 counter = 0; counter < toolTypes.length; counter++) {
            require(
                toolTypes[counter] <= _toolTypes,
                "Tools: invalid id value"
            );
        }

        _mintBatch(to, toolTypes, amounts, data);
        for (uint256 counter = 0; counter < toolTypes.length; counter++) {
            for (uint256 i = 0; i < amounts.length; i++) {
                _toolIds++;
                _ownedTools[to][_toolIds].toolType = uint128(
                    toolTypes[counter]
                );
                _ownedTools[to][_toolIds].strength = _tools[toolTypes[counter]]
                    .maxStrength;
            }
        }
    }

    // ----------- URI functions -----------

    function setURI(uint256 toolType, string calldata newURI) public onlyOwner {
        _setURI(toolType, newURI);
    }

    function setBaseURI(string calldata baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function uri(uint256 toolType)
        public
        view
        override
        returns (string memory)
    {
        string memory tokenURI = _tokenURIs[toolType];
        return
            bytes(tokenURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenURI))
                : super.uri(toolType);
    }

    function _setURI(uint256 toolType, string calldata tokenURI)
        internal
        virtual
    {
        _tokenURIs[toolType] = tokenURI;
        emit URI(uri(toolType), toolType);
    }

    function _setBaseURI(string calldata baseURI) internal virtual {
        _baseURI = baseURI;
        emit BaseURI(uri(1));
    }

    // ----------- Recipes Functions -----------

    function createRecipe(
        uint256 toolType,
        uint256[] calldata resourcesAmount,
        uint256[] calldata artifactsAmount
    ) external virtual onlyOwner {
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");
        require(
            resourcesAmount.length == _resourceAmount &&
                artifactsAmount.length == _artifactAmount,
            "Tools: invalid array size"
        );
        _recipeAmount++;

        _recipes[_recipeAmount].toolType = toolType;

        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (resourcesAmount[counter] > 0) {
                _recipes[_recipeAmount].resources[counter] = resourcesAmount[
                    counter
                ];
            }
        }

        for (uint256 counter = 0; counter < _artifactAmount; counter++) {
            if (artifactsAmount[counter] > 0) {
                _recipes[_recipeAmount].artifacts[counter] = artifactsAmount[
                    counter
                ];
            }
        }

        emit CreateRecipe(_recipeAmount);
    }

    function getRecipe(uint256 recipeId)
        public
        view
        virtual
        whenNotPaused
        returns (
            uint256 toolType,
            uint256[] memory resourcesAmount,
            uint256[] memory artifactsAmount
        )
    {
        require(recipeId <= _recipeAmount, "Tools: invalid recipieId value");

        toolType = _recipes[recipeId].toolType;

        resourcesAmount = new uint256[](_resourceAmount);
        artifactsAmount = new uint256[](_artifactAmount);

        for (uint256 counter = 0; counter <= _resourceAmount; counter++) {
            if (_recipes[recipeId].resources[counter] > 0) {
                resourcesAmount[counter] = _recipes[recipeId].resources[
                    counter
                ];
            }
        }

        for (uint256 counter = 0; counter < _artifactAmount; counter++) {
            if (_recipes[recipeId].artifacts[counter] > 0) {
                artifactsAmount[counter] = _recipes[recipeId].artifacts[
                    counter
                ];
            }
        }
    }

    function craft(uint256 toolType)
        external
        whenNotPaused
        isInBlacklist(_msgSender())
    {
        uint256[] memory resourcesAmount;
        uint256[] memory artifactsAmount;

        for (uint256 counter = 1; counter <= _recipeAmount; counter++) {
            if (_recipes[counter].toolType == toolType) {
                (, resourcesAmount, artifactsAmount) = getRecipe(counter);
                break;
            }
        }

        for (uint256 counter = 0; counter < resourcesAmount.length; counter++) {
            if (resourcesAmount[counter] != 0) {
                _resources[counter + 1].transferFrom(
                    _msgSender(),
                    address(this),
                    resourcesAmount[counter]
                );
            }
        }

        for (uint256 counter = 0; counter < artifactsAmount.length; counter++) {
            if (artifactsAmount[counter] != 0) {
                _artifacts.safeTransferFrom(
                    _msgSender(),
                    address(0x01),
                    counter + 1,
                    artifactsAmount[counter],
                    ""
                );
            }
        }

        _mint(_msgSender(), toolType, 1, "");

        _toolIds++;
        _ownedTools[_msgSender()][_toolIds] = OwnedTool({
            toolType: uint128(toolType),
            strength: _tools[toolType].maxStrength
        });

        emit Craft(_msgSender(), toolType);
    }

    // ----------- Repair Functions -----------
    function setRepairCost(uint256[] memory resourcesAmount)
        public
        virtual
        onlyOwner
    {
        require(
            resourcesAmount.length == _resourceAmount,
            "Tools: invalid array size"
        );
        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (resourcesAmount[counter] > 0) {
                _repairCost[counter + 1] = resourcesAmount[counter];
            }
        }
    }

    function getRepairCost()
        public
        view
        virtual
        returns (uint256[] memory resourcesAmount)
    {
        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (_repairCost[counter + 1] > 0) {
                resourcesAmount[counter] = _repairCost[counter + 1];
            }
        }
    }

    function repairTool(uint256 toolId, uint256 repairValue)
        public
        virtual
        whenNotPaused
        isInBlacklist(_msgSender())
    {
        require(
            _ownedTools[_msgSender()][toolId].toolType > 0,
            "Tools: tool does not exist"
        );

        require(
            _ownedTools[_msgSender()][toolId].strength + repairValue <=
                _tools[_ownedTools[_msgSender()][toolId].toolType].maxStrength,
            "Tools: the tool is already strong enough"
        );

        for (uint256 counter = 1; counter <= _resourceAmount; counter++) {
            if (_repairCost[counter] > 0) {
                uint256 amount = _repairCost[counter] * repairValue;
                _resources[counter].transferFrom(
                    _msgSender(),
                    address(this),
                    amount
                );
            }
        }
        _ownedTools[_msgSender()][toolId].strength += uint128(repairValue);
    }

    // ----------- Utils Functions -----------

    function increaseArtifactAmount() external onlyOwner {
        _artifactAmount++;
    }

    function increaseResourceAmount(address newResource) external onlyOwner {
        require(newResource != address(0), "Tools: invalid address");
        _resourceAmount++;
        _resources[_recipeAmount] = IResources(newResource);
    }

    function getRecipieAmount() public view returns (uint256) {
        return _recipeAmount;
    }

    function getToolProperties(address user, uint256 toolId)
        external
        view
        virtual
        returns (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningResource,
            uint256 miningDuration,
            uint256 energyCost,
            uint256 rewardRate
        )
    {
        toolType = _ownedTools[user][toolId].toolType;

        strength = _ownedTools[user][toolId].strength;

        strengthCost = _tools[toolType].strengthCost;
        miningResource = _tools[toolType].miningResource;
        miningDuration = _tools[toolType].miningDuration;
        energyCost = _tools[toolType].energyCost;
        rewardRate = _tools[toolType].rewardRate;

        return (
            toolType,
            strength,
            strengthCost,
            miningResource,
            miningDuration,
            energyCost,
            rewardRate
        );
    }

    function corrupt(
        address user,
        uint256 toolId,
        uint256 strengthCost
    ) external virtual whenNotPaused {
        require(
            _msgSender() == _miningAddress,
            "Tools: msg.sender isn't mining contract"
        );
        _ownedTools[user][toolId].strength -= uint128(strengthCost);
    }

    function getResourceAddress(uint256 resourceId)
        external
        view
        virtual
        returns (address)
    {
        return address(_resources[resourceId]);
    }

    function getArtifactsAddress() external view returns (address) {
        return address(_artifacts);
    }

    function getStrength(uint256 toolId) public view returns (uint256) {
        return _ownedTools[_msgSender()][toolId].strength;
    }

    function setArtifactsAddress(address artifactsAddress) external onlyOwner {
        _artifacts = IArtifacts(artifactsAddress);
    }

    function setMiningAddress(address miningAddress) external onlyOwner {
        _miningAddress = miningAddress;
    }

    function getMiningAddress() external view returns (address) {
        return _miningAddress;
    }

    function getResourceAmount() external view returns (uint256) {
        return _resourceAmount;
    }

    function getArtifactAmount() external view returns (uint256) {
        return _artifactAmount;
    }

    function pause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 toolId,
        uint256 amount,
        bytes memory data
    ) public virtual override(ERC1155Upgradeable, IERC1155Upgradeable) {
        require(amount == 1, "Tools: tokenId is unique");

        uint256 toolType = _ownedTools[from][toolId].toolType;

        require(toolType > 0, "Tools: tool doesn't exist");

        super.safeTransferFrom(from, to, toolType, amount, data);
        _ownedTools[to][toolId] = _ownedTools[from][toolId];
        delete _ownedTools[from][toolId];
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory toolTypes,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override(ERC1155Upgradeable, IERC1155Upgradeable) {
        for (uint256 count = 0; count < toolTypes.length; count++) {
            safeTransferFrom(from, to, toolTypes[count], amounts[count], data);
        }
    }

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "Tools: user in blacklist");
        _;
    }
}
