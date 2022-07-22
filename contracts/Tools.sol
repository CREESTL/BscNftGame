// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IResources.sol";


contract Tools is ERC1155, Ownable {
    using Strings for uint256;

    string private _baseURI = "";

    struct Tool {
        uint8 level;
        uint256 miningResource;
        uint256[] miningArtifacts; 
        uint256 maxStrength;
        uint256 miningDuration;
        uint256 resourcesCost; 
        uint256 strengthCost;
        uint256 rewardRate;

    }

    struct OwnedTool {
        uint256 toolType;
        uint256 strength;
    }

    struct Recipe {
        uint256 toolId;
        mapping (uint256 => uint256) resources; 
        mapping (uint256 => uint256) artifacts;
    }

    uint256 private _toolIds;
    uint256 private _toolTypes;
    uint256 private _artifactAmount = 6;
    uint256 private _recipeAmount;
    uint256 private _resourceAmount = 3;
    
    mapping (uint256 => IResources) private _resources; 

    mapping (uint256 => uint256) private _repairCost;
    mapping (uint256 => string) private _tokenURIs;
    mapping (uint256 => Tool) private _tools;
    mapping (uint256 => Recipe) private _recipes;
    mapping (address => mapping(uint256 => OwnedTool)) _ownedTools;

    constructor() ERC1155("") {}

    // ----------- Mint functions -----------

    function addTool(uint8 level, uint256 miningResource, uint256[] memory miningArtifacts, uint256 maxStrength, uint256 miningDuration, uint256 resourcesCost, uint256 strengthCost, uint256 rewardRate) external onlyOwner returns (uint256) {
        require (miningResource <= _resourceAmount, "Tools: invalid mining resource value");
        for (uint256 counter = 0; counter < miningArtifacts.length; counter++) {
            require (miningArtifacts[counter] <= _artifactAmount, "Tools: invalid arifact value");
        }
        require (maxStrength % 5 == 0, "Tools: invalid strength value");
        
        _toolTypes++;
        uint256 newType = _toolTypes; 
        _tools[newType].level = level;
        _tools[newType].miningResource = miningResource;
        _tools[newType].miningArtifacts = miningArtifacts;
        _tools[newType].maxStrength = maxStrength;
        _tools[newType].miningDuration = miningDuration;
        _tools[newType].resourcesCost = resourcesCost;
        _tools[newType].strengthCost = strengthCost;
        _tools[newType].rewardRate = rewardRate;
        
        //emit AddTool(newItem);
        return newType;
    }

    function mint(address account, uint256 id, uint256 amount) public onlyOwner {
        require (id <= _toolTypes, "Tools: invalid id value");
        _mint(account, id, amount, "");
        
        _toolIds++;
        _ownedTools[account][_toolIds].toolType = id;
        _ownedTools[account][_toolIds].strength = _tools[id].maxStrength;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
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

    function setURI(uint256 toolType, string memory newuri) public onlyOwner {
        _setURI(toolType, newuri);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function uri(uint256 toolId) public view override returns (string memory) {
        
        string memory tokenURI = _tokenURIs[toolId];

        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(toolId);
    }

    function _setURI(uint256 toolType, string memory tokenURI) internal virtual {
        _tokenURIs[toolType] = tokenURI;
        //emit URI(uri(tokenId), tokenId);
    }

    function _setBaseURI(string memory baseURI) internal virtual {
        _baseURI = baseURI;
        //emit BaseURI(uri(tokenId));
    }

    // ----------- Recipes Functions -----------

    function createRecipe(uint256 toolId, uint256[] memory resourcesAmount,  uint256[] memory artifactsAmount) external virtual onlyOwner {
        require(toolId <= _toolIds, "Tools: invalid toolId value");
        require(resourcesAmount.length == _resourceAmount && artifactsAmount.length == _artifactAmount, "Tools: invalid array size");

        _recipes[_recipeAmount].toolId = toolId;
        
        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (resourcesAmount[counter] > 0) {
                _recipes[_recipeAmount].resources[counter] = resourcesAmount[counter];
            }
        }

        for (uint256 counter = 0; counter < _artifactAmount; counter++) {
            if (artifactsAmount[counter] > 0) {
                _recipes[_recipeAmount].artifacts[counter] = artifactsAmount[counter];
            }
        }

        _recipeAmount++;

        //emit CreateRecipe(_recipeAmount - 1);
    } 

    function getRecipe(uint256 recipieId) public view virtual returns (uint256 toolId, uint256[] memory resourcesAmount, uint256[] memory artifactsAmount) {
        require (recipieId <= _recipeAmount, "Tools: invalid recipieId value");
        toolId = _recipes[recipieId].toolId;
        for (uint256 counter = 0; counter < _resourceAmount; counter++) {
            if (_recipes[recipieId].resources[counter] > 0) {
                resourcesAmount[counter] = _recipes[recipieId].resources[counter];
            }
        }
        for (uint256 counter = 0; counter < _artifactAmount; counter++) {
            if (_recipes[recipieId].artifacts[counter] > 0) {
                artifactsAmount[counter] = _recipes[recipieId].artifacts[counter];
            }
        }
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
    
    function repairTool(uint256 toolId, uint256 repairValue) public virtual { 
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
}
