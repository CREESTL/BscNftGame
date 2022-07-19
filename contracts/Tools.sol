// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Tools is ERC1155, Ownable {
    using Strings for uint256;

    string private _baseURI = "";

    struct Recipe {
        uint256 toolId;
        mapping (uint256 => uint256) resources;
        mapping (uint256 => uint256) artifacts;
    }

    uint256 private _artifactAmount = 6;
    uint256 private _recipeAmount = 0;
    uint256 private _resourceAmount = 3;
    
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => Recipe) private _recipes;

    constructor() ERC1155("") {}

    // ----------- Mint functions -----------

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    // ----------- URI functions -----------

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId];

        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(tokenId);
    }

    function _setURI(uint256 tokenId, string memory tokenURI) internal virtual {
        _tokenURIs[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }

    function _setBaseURI(string memory baseURI) internal virtual {
        _baseURI = baseURI;
    }

    // ----------- Recipes Functions -----------

    function createRecipe(uint256 toolId, uint256[] memory resourcesId, uint256[] memory amount1, uint256[] memory artifactsId, uint256[] memory amount2) external virtual onlyOwner {
        require(resourcesId.length <= _resourceAmount && artifactsId.length <= _artifactAmount, "Tools: invalid array size");
        require(resourcesId.length == amount1.length && artifactsId.length == amount2.length, "Tools: the sizes of the arrays do not match");

        _recipes[_recipeAmount].toolId = toolId;
        for (uint256 counter = 0; counter < resourcesId.length; counter++) {
            _recipes[_recipeAmount].resources[resourcesId[counter]] = amount1[counter];
        }
        for (uint256 counter = 0; counter < artifactsId.length; counter++) {
            _recipes[_recipeAmount].artifacts[artifactsId[counter]] = amount2[counter];
        }

        _recipeAmount++;

        //emit CreateRecipe(_recipeAmount - 1);
    } 

    function getRecipe(uint256 recipieId) public view virtual returns (uint256 toolId, uint256[] memory resourcesId, uint256[] memory amount1, uint256[] memory artifactsId, uint256[] memory amount2) {
        // TODO
    }

    // ----------- Utils Functions -----------

    function increaseArtifactAmount() external onlyOwner {
        _artifactAmount++;
    }

    function increaseResourceAmount() external onlyOwner {
        _resourceAmount++;
    }

    function getRecipieAmount() public view returns (uint256) {
        return _recipeAmount;
    }
}
