// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IResources.sol";
import "./interfaces/IBlackList.sol";
import "./interfaces/IArtifacts.sol";
import "./interfaces/ITools.sol";

contract Tools is Initializable, OwnableUpgradeable, ERC1155Upgradeable, PausableUpgradeable, ITools {
    using Strings for uint256;

    IBlackList private _blacklist;
    IArtifacts private _artifacts;

    string private _baseURI;

    struct Recipe {
        uint256 toolType;
        // resource id => amount
        mapping (uint256 => uint256) resources; 
        // artifacts id => amonut
        mapping (uint256 => uint256) artifacts;
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
    
    // TODO: в майнинге дергать адреса 
    mapping (uint256 => IResources) private _resources; 
    // token type => cost
    mapping (uint256 => uint256) private _repairCost;
    // token id => uri
    mapping (uint256 => string) private _tokenURIs;
    // token id => tool
    mapping (uint256 => Tool) private _tools;
    // recipe id => Recipe
    mapping (uint256 => Recipe) private _recipes;
    // user address => (tool id => OwnedTool) 
    mapping (address => mapping(uint256 => OwnedTool)) _ownedTools;

    event AddTool(uint256 toolType);
    event Craft(address user, uint256);
    event CreateRecipe(uint256 recipeId);
    event BaseURI(string baseURI);

    function initialize(address blacklistAddress, address berryAddress, address treeAddress, address goldAddress, string memory baseURI) initializer public {
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

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) virtual override internal {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        for (uint256 counter = 0; counter < ids.length; counter++) {
            _ownedTools[to][ids[counter]] = OwnedTool({
                toolType: _ownedTools[from][ids[counter]].toolType,
                strength: _ownedTools[from][ids[counter]].strength
            });
            delete _ownedTools[from][ids[counter]];
        }
    }

    // ----------- Mint functions -----------

    function addTool(uint256 miningResource, uint256[] calldata miningArtifacts, uint256 maxStrength, uint256 miningDuration, uint256 energyCost, uint256 strengthCost, uint256 rewardRate) external virtual onlyOwner returns (uint256) {
        require(miningResource != 0, "Tools: resource doesn't exist");
        require (miningResource <= _resourceAmount, "Tools: invalid mining resource value");
        for (uint256 counter = 0; counter < miningArtifacts.length; counter++) {
            require (miningArtifacts[counter] <= _artifactAmount, "Tools: invalid arifact value");
        }
        require (maxStrength % 5 == 0, "Tools: invalid strength value");
        require(miningDuration > 0, "Tools: mining duration must be greather than zero");

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

    function mint(address account, uint256 id, uint256 amount) public onlyOwner isInBlacklist(account) {
        require(_toolTypes != 0, "Tools: no tools");
        require (id <= _toolTypes, "Tools: invalid id value");
        _mint(account, id, amount, "");
        
        _toolIds++;
        _ownedTools[account][_toolIds].toolType = id;
        _ownedTools[account][_toolIds].strength = _tools[id].maxStrength;
    }

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) public onlyOwner isInBlacklist(to) {
        require(_toolTypes != 0, "Tools: no tools");
        for (uint256 counter = 0; counter < ids.length; counter++) {
            require (ids[counter] <= _toolTypes, "Tools: invalid id value");
        }
        _mintBatch(to, ids, amounts, data);
        for (uint256 counter = 0; counter < ids.length; counter++) {
            _toolIds++;
            _ownedTools[to][_toolIds].toolType = ids[counter];
            _ownedTools[to][_toolIds].strength = _tools[ids[counter]].maxStrength;
        }
    }

    // ----------- URI functions -----------

    function setURI(uint256 toolType, string calldata newURI) public onlyOwner {
        _setURI(toolType, newURI);
    }

    function setBaseURI(string calldata baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function uri(uint256 toolType) public view override returns (string memory) {        
        string memory tokenURI = _tokenURIs[toolType];
        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(toolType);
    }

    function _setURI(uint256 toolType, string calldata tokenURI) internal virtual {
        _tokenURIs[toolType] = tokenURI;
        emit URI(uri(toolType), toolType);
    }

    function _setBaseURI(string calldata baseURI) internal virtual {
        _baseURI = baseURI;
        emit BaseURI(uri(1));
    }

    // ----------- Recipes Functions -----------

    function createRecipe(uint256 toolType, uint256[] calldata resourcesAmount,  uint256[] calldata artifactsAmount) external virtual onlyOwner {
        require(toolType <= _toolIds, "Tools: invalid toolId value");
        require(resourcesAmount.length == _resourceAmount && artifactsAmount.length == _artifactAmount, "Tools: invalid array size");
        _recipeAmount++;

        _recipes[_recipeAmount].toolType = toolType;
        
        for (uint256 counter = 1; counter < _resourceAmount - 1; counter++) {
            if (resourcesAmount[counter] > 0) {
                _recipes[_recipeAmount].resources[counter] = resourcesAmount[counter];
            }
        }

        for (uint256 counter = 1; counter < _artifactAmount - 1; counter++) {
            if (artifactsAmount[counter] > 0) {
                _recipes[_recipeAmount].artifacts[counter] = artifactsAmount[counter];
            }
        }

        emit CreateRecipe(_recipeAmount);
    } 

    function getRecipe(uint256 recipeId) public view virtual whenNotPaused returns (uint256 toolType, uint256[] memory resourcesAmount, uint256[] memory artifactsAmount) {
        require (recipeId <= _recipeAmount, "Tools: invalid recipieId value");
        toolType = _recipes[recipeId].toolType;
        for (uint256 counter = 1; counter < _resourceAmount - 1; counter++) {
            if (_recipes[recipeId].resources[counter] > 0) {
                resourcesAmount[counter] = _recipes[recipeId].resources[counter];
            }
        }
        for (uint256 counter = 1; counter < _artifactAmount - 1; counter++) {
            if (_recipes[recipeId].artifacts[counter] > 0) {
                artifactsAmount[counter] = _recipes[recipeId].artifacts[counter];
            }
        }
    }

    function craft(uint256 toolType) external whenNotPaused isInBlacklist(msg.sender) {
        uint256[] memory resourcesAmount;
        uint256[] memory artifactsAmount;
        
        for (uint256 counter = 1; counter < _recipeAmount - 1; counter++) {
            if (_recipes[counter].toolType == toolType) {
                (, resourcesAmount, artifactsAmount) = getRecipe(counter);
                break;
            }
        }
        for (uint256 counter = 1; counter < resourcesAmount.length; counter++) {
            if (resourcesAmount[counter] != 0) {
                _resources[counter].transferFrom(msg.sender, address(this), resourcesAmount[counter]);
            }
        }
        for (uint256 counter = 1; counter < artifactsAmount.length; counter++) {
            if (artifactsAmount[counter] != 0) {
                _artifacts.safeTransferFrom(msg.sender, address(this), counter, artifactsAmount[counter], ""); 
            }
        }

        emit Craft(msg.sender, toolType);        
    }

    // ----------- Repair Functions -----------
    function setRepairCost(uint256[] memory resourcesAmount) public virtual onlyOwner {
        require(resourcesAmount.length == _resourceAmount, "Tools: invalid array size");
        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (resourcesAmount[counter] > 0) {
                _repairCost[counter] = resourcesAmount[counter];
            }
        } 
    }

    function getRepairCost() public view virtual returns (uint256[] memory resourcesAmount) {
        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (_repairCost[counter] > 0) {
                resourcesAmount[counter] = _repairCost[counter];
            }
        }
    }
    
    function repairTool(uint256 toolId, uint256 repairValue) public virtual whenNotPaused isInBlacklist(msg.sender) { 
        require (_ownedTools[_msgSender()][toolId].toolType > 0, "Tools: tool does not exist");
        for (uint256 counter = 1; counter <= _resourceAmount; counter++) {
            if (_repairCost[counter] > 0) {
                uint256 amount = _repairCost[counter] * repairValue;
                _resources[counter].transferFrom(_msgSender(), address(this), amount);
            }
        }
        _ownedTools[_msgSender()][toolId].strength += repairValue;
    }
    // ----------- Utils Functions -----------

    function increaseArtifactAmount() external onlyOwner {
        _artifactAmount++;
    }

    function increaseResourceAmount(address newResource) external onlyOwner {
        require (newResource != address(0), "Tools: invalid address");
        _resourceAmount++;
        _resources[_recipeAmount] = IResources(newResource);
    }

    function getRecipieAmount() public view returns (uint256) {
        return _recipeAmount;
    }

    function pause() onlyOwner external {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "User in blacklist");
        _;
    }
}
