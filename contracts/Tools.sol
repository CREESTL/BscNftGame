// SPDX-License-Identifier: MIT
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

    enum Resources {
        Berry,
        Tree,
        Gold
    }

    string private _baseURI;

    address private _miningAddress;

    struct Recipe {
        // resource amount
        uint256 resourcesAmount;
        // artifacts id => amonut
        mapping(uint256 => uint256) artifacts;
    }

    address private _zeroAddress;

    // tools counter
    uint256 private _toolIds;
    // tool types counter
    uint256 private _toolTypes;
    // artifacts counter
    uint256 private _artifactAmount;
    // resources counter
    uint256 private _resourceAmount;

    // enum Resources => IResources
    mapping(Resources => IResources) private _resources;
    // tool type => repair cost
    mapping(uint256 => uint256) private _repairCost;
    // tool id => uri
    mapping(uint256 => string) private _tokenURIs;
    // tool type => Tool
    mapping(uint256 => Tool) private _tools;
    // recipe toolType => Recipe
    mapping(uint256 => Recipe) private _recipes;

    // user address => (tool id => OwnedTool)
    mapping(address => mapping(uint256 => OwnedTool)) private _ownedTools;

    event AddTool(uint256 toolType, string newURI);
    event Craft(address user, uint256 toolType);
    event RecipeCreatedOrUpdated(
        uint256 toolType,
        uint256 resourcesAmount,
        uint256[] artifactsAmount
    );
    event BaseURI(string baseURI);
    event ToolRepaired(uint256 toolId);
    event ToolPropertiesSet(uint256 toolType);

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "Tools: user in blacklist");
        _;
    }

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

    function supportsInterface(
        bytes4 interfaceId
    )
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
        _zeroAddress = 0x000000000000000000000000000000000000dEaD;

        _blacklist = IBlackList(blacklistAddress);

        _resources[Resources.Berry] = IResources(berryAddress);
        _resources[Resources.Tree] = IResources(treeAddress);
        _resources[Resources.Gold] = IResources(goldAddress);

        _resourceAmount = 3;
        _baseURI = baseURI;

        __ERC1155_init("");
        __Pausable_init();
        __Ownable_init();
    }

    // ----------- Mint functions -----------

    function addTool(
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost,
        uint256 resourcesAmount,
        uint256[] calldata artifactsAmount,
        string calldata newURI
    ) external virtual onlyOwner returns (uint256) {
        require(maxStrength % 5 == 0, "Tools: invalid strength value");
        require(
            miningDuration > 0,
            "Tools: mining duration must be greather than zero"
        );

        _toolTypes++;
        uint256 newType = _toolTypes;
        _tools[newType].maxStrength = maxStrength;
        _tools[newType].miningDuration = miningDuration;
        _tools[newType].energyCost = energyCost;
        _tools[newType].strengthCost = strengthCost;

        emit AddTool(newType, newURI);
        setURI(newType, newURI);
        setRecipe(newType, resourcesAmount, artifactsAmount);
        return newType;
    }

    function setToolProperties(
        uint256 toolType,
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost
    ) external virtual onlyOwner {
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");
        require(maxStrength % 5 == 0, "Tools: invalid strength value");
        require(
            miningDuration > 0,
            "Tools: mining duration must be greather than zero"
        );

        _tools[toolType].maxStrength = maxStrength;
        _tools[toolType].miningDuration = miningDuration;
        _tools[toolType].energyCost = energyCost;
        _tools[toolType].strengthCost = strengthCost;

        emit ToolPropertiesSet(toolType);
    }

    function mint(
        address to,
        uint128 toolType,
        uint256 amount
    ) public virtual onlyOwner isInBlacklist(to) {
        require(_toolTypes != 0, "Tools: no tools");
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");

        _mint(to, toolType, amount, "");
        for (uint256 counter = 0; counter < amount; counter++) {
            _toolIds++;
            _ownedTools[to][_toolIds] = OwnedTool({
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
                "Tools: invalid toolTypes value"
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

    function uri(
        uint256 toolType
    ) public view override returns (string memory) {
        string memory tokenURI = _tokenURIs[toolType];
        return
            bytes(tokenURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenURI))
                : super.uri(toolType);
    }

    function _setURI(
        uint256 toolType,
        string calldata tokenURI
    ) internal virtual {
        _tokenURIs[toolType] = tokenURI;
        emit URI(uri(toolType), toolType);
    }

    function _setBaseURI(string calldata baseURI) internal virtual {
        _baseURI = baseURI;
        emit BaseURI(uri(1));
    }

    // ----------- Recipes Functions -----------

    function setRecipe(
        uint256 toolType,
        uint256 resourcesAmount,
        uint256[] calldata artifactsAmount
    ) public virtual onlyOwner {
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");
        require(
            artifactsAmount.length == _artifactAmount,
            "Tools: invalid array size"
        );

        _recipes[toolType].resourcesAmount = resourcesAmount;

        for (uint256 counter = 0; counter < _artifactAmount; counter++) {
            _recipes[toolType].artifacts[counter] = artifactsAmount[counter];
        }

        emit RecipeCreatedOrUpdated(toolType, resourcesAmount, artifactsAmount);
    }

    function getRecipe(
        uint256 toolType
    )
        public
        view
        virtual
        whenNotPaused
        returns (uint256 resourcesAmount, uint256[] memory artifactsAmount)
    {
        artifactsAmount = new uint256[](_artifactAmount);

        resourcesAmount = _recipes[toolType].resourcesAmount;

        for (uint256 counter = 0; counter < _artifactAmount; counter++) {
            if (_recipes[toolType].artifacts[counter] > 0) {
                artifactsAmount[counter] = _recipes[toolType].artifacts[
                    counter
                ];
            }
        }
    }

    function craft(
        uint256 toolType
    ) external whenNotPaused isInBlacklist(_msgSender()) {
        uint256 resourcesAmount;
        uint256[] memory artifactsAmount;

        (resourcesAmount, artifactsAmount) = getRecipe(toolType);

        _resources[Resources.Gold].transferFrom(
            _msgSender(),
            _zeroAddress,
            resourcesAmount
        );

        _resources[Resources.Tree].transferFrom(
            _msgSender(),
            _zeroAddress,
            resourcesAmount * 5
        );

        for (uint256 counter = 0; counter < artifactsAmount.length; counter++) {
            if (artifactsAmount[counter] != 0) {
                _artifacts.safeTransferFrom(
                    _msgSender(),
                    _zeroAddress,
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
    function repairTool(
        uint256 toolId
    ) public virtual whenNotPaused isInBlacklist(_msgSender()) {
        OwnedTool memory tool = _ownedTools[_msgSender()][toolId];
        uint256 toolTypeId = tool.toolType;
        require(toolTypeId > 0, "Tools: tool does not exist");

        uint128 maxStrength = _tools[tool.toolType].maxStrength;
        uint256 auraAmount = (maxStrength - tool.strength) / 5;

        require(auraAmount != 0, "Tools: the tool is already strong enough");

        _resources[Resources.Gold].transferFrom(
            _msgSender(),
            _zeroAddress,
            auraAmount
        );

        _ownedTools[_msgSender()][toolId].strength = maxStrength;
        emit ToolRepaired(toolId);
    }

    // ----------- Utils Functions -----------

    function increaseArtifactAmount() external {
        require(
            msg.sender == address(_artifacts),
            "Tools: caller is not an Artifacts contract"
        );
        _artifactAmount++;
    }

    function getToolProperties(
        address user,
        uint256 toolId
    )
        external
        view
        virtual
        returns (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        )
    {
        toolType = _ownedTools[user][toolId].toolType;

        strength = _ownedTools[user][toolId].strength;

        strengthCost = _tools[toolType].strengthCost;
        miningDuration = _tools[toolType].miningDuration;
        energyCost = _tools[toolType].energyCost;

        return (toolType, strength, strengthCost, miningDuration, energyCost);
    }

    function getToolTypeProperties(
        uint256 toolType
    )
        external
        view
        virtual
        returns (
            uint256 maxStrength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        )
    {
        maxStrength = _tools[toolType].maxStrength;
        strengthCost = _tools[toolType].strengthCost;
        miningDuration = _tools[toolType].miningDuration;
        energyCost = _tools[toolType].energyCost;

        return (maxStrength, strengthCost, miningDuration, energyCost);
    }

    function corrupt(
        address user,
        uint256 toolId,
        uint256 strengthCost
    ) external virtual whenNotPaused {
        require(
            _msgSender() == _miningAddress,
            "Tools: msg.sender isn't Mining contract"
        );
        _ownedTools[user][toolId].strength -= uint128(strengthCost);
    }

    function getResourceAddress(
        uint256 resourceId
    ) external view virtual returns (address) {
        return address(_resources[Resources(resourceId)]);
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

    function getArtifactsTypesAmount() external view returns (uint256) {
        return _artifactAmount;
    }

    function getToolsTypesAmount() external view returns (uint256) {
        return _toolTypes;
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
        uint256[] memory toolIds,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override(ERC1155Upgradeable, IERC1155Upgradeable) {
        for (uint256 count = 0; count < toolIds.length; count++) {
            require(amounts[count] == 1, "Tools: tokenId is unique");
            safeTransferFrom(from, to, toolIds[count], 1, data);
        }
    }
}
