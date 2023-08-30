// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

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

/// @title This contracts represents tools that are used to mine resources and artifacts.
contract Tools is
    Initializable,
    OwnableUpgradeable,
    ERC1155Upgradeable,
    PausableUpgradeable,
    IERC1155Receiver,
    ITools
{
    using Strings for uint256;

    /// @dev The address of the Blacklist contract
    IBlackList private _blacklist;
    /// @dev The address of the Artifacts contract
    IArtifacts private _artifacts;
    /// @dev The address of the Mining contract
    address private _miningAddress;

    /// @dev Base URI for IPFS
    string private _baseURI;

    /// @dev Zero address to burn tokens
    address private constant _zeroAddress =
        0x000000000000000000000000000000000000dEaD;

    /// @dev IDs of tools. Each one is unique
    uint256 private _toolIds;
    /// @dev Types of tools
    uint256 private _toolTypes;
    /// @dev Number of types of artifacts
    uint256 private _artifactTypesAmount;
    /// @dev Number of types of resources
    uint256 private _resourceTypesAmount;

    /// @dev Mapping (enum Resources => IResources)
    mapping(Resources => IResources) private _resources;
    /// @dev Mapping (tool type => repair cost)
    mapping(uint256 => uint256) private _repairCost;
    /// @dev Mapping (tool id => URI)
    mapping(uint256 => string) private _idsToURIs;
    /// @dev Mapping (tool type => Tool)
    mapping(uint256 => Tool) private _typesToTools;
    /// @dev Mapping (tool type => Recipe)
    mapping(uint256 => Recipe) private _typesToRecipes;
    /// @dev Mapping (user address => (tool id => OwnedTool))
    mapping(address => mapping(uint256 => OwnedTool)) private _ownedTools;

    /// @dev Checks that user is not blacklisted
    modifier ifNotBlacklisted(address user) {
        require(!_blacklist.check(user), "Tools: user in blacklist");
        _;
    }

    function initialize(
        address blacklistAddress,
        address berryAddress,
        address treeAddress,
        address goldAddress,
        string memory baseURI
    ) external initializer {
        _blacklist = IBlackList(blacklistAddress);

        // Initially, there are only 3 types of resources
        _resources[Resources.Berry] = IResources(berryAddress);
        _resources[Resources.Tree] = IResources(treeAddress);
        _resources[Resources.Gold] = IResources(goldAddress);
        _resourceTypesAmount = 3;

        _baseURI = baseURI;

        __ERC1155_init("");
        __Pausable_init();
        __Ownable_init();
    }

    /// @dev The next 2 functions are required for ERC1155 standard
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    /// @notice See {ITools-getToolProperties}
    function getToolProperties(
        address user,
        uint256 toolId
    )
        external
        view
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

        strengthCost = _typesToTools[toolType].strengthCost;
        miningDuration = _typesToTools[toolType].miningDuration;
        energyCost = _typesToTools[toolType].energyCost;

        return (toolType, strength, strengthCost, miningDuration, energyCost);
    }

    /// @notice See {ITools-getToolTypeProperties}
    function getToolTypeProperties(
        uint256 toolType
    )
        external
        view
        returns (
            uint256 maxStrength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        )
    {
        maxStrength = _typesToTools[toolType].maxStrength;
        strengthCost = _typesToTools[toolType].strengthCost;
        miningDuration = _typesToTools[toolType].miningDuration;
        energyCost = _typesToTools[toolType].energyCost;

        return (maxStrength, strengthCost, miningDuration, energyCost);
    }

    /// @notice See {ITools-getResourceAddress}
    function getResourceAddress(
        uint256 resourceId
    ) external view returns (address) {
        return address(_resources[Resources(resourceId)]);
    }

    /// @notice See {ITools-getArtifactsAddress}
    function getArtifactsAddress() external view returns (address) {
        return address(_artifacts);
    }

    /// @notice See {ITools-getMiningAddress}
    function getMiningAddress() external view returns (address) {
        return _miningAddress;
    }

    /// @notice See {ITools-getStrength}
    function getStrength(uint256 toolId) external view returns (uint256) {
        return _ownedTools[_msgSender()][toolId].strength;
    }

    /// @notice See {ITools-getResourcesTypesAmount}
    function getResourcesTypesAmount() external view returns (uint256) {
        return _resourceTypesAmount;
    }

    /// @notice See {ITools-getArtifactsTypesAmount}
    function getArtifactsTypesAmount() external view returns (uint256) {
        return _artifactTypesAmount;
    }

    /// @notice See {ITools-getToolsTypesAmount}
    function getToolsTypesAmount() external view returns (uint256) {
        return _toolTypes;
    }

    /// @notice See {ITools-addTool}
    function addTool(
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost,
        uint256 resourcesAmount,
        uint256[] calldata artifactsAmounts,
        string calldata newURI
    ) external onlyOwner returns (uint256) {
        require(maxStrength % 5 == 0, "Tools: invalid strength value");
        require(
            miningDuration > 0,
            "Tools: mining duration must be greather than zero"
        );

        _toolTypes++;
        uint256 newType = _toolTypes;
        _typesToTools[newType].maxStrength = maxStrength;
        _typesToTools[newType].miningDuration = miningDuration;
        _typesToTools[newType].energyCost = energyCost;
        _typesToTools[newType].strengthCost = strengthCost;

        emit AddTool(newType, newURI);
        setURI(newType, newURI);
        setRecipe(newType, resourcesAmount, artifactsAmounts);
        return newType;
    }

    /// @notice See {ITools-setToolProperties}
    function setToolProperties(
        uint256 toolType,
        uint32 maxStrength,
        uint32 miningDuration,
        uint32 energyCost,
        uint32 strengthCost
    ) external onlyOwner {
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");
        require(maxStrength % 5 == 0, "Tools: invalid strength value");
        require(
            miningDuration > 0,
            "Tools: mining duration must be greather than zero"
        );

        _typesToTools[toolType].maxStrength = maxStrength;
        _typesToTools[toolType].miningDuration = miningDuration;
        _typesToTools[toolType].energyCost = energyCost;
        _typesToTools[toolType].strengthCost = strengthCost;

        emit ToolPropertiesSet(toolType);
    }

    /// @notice See {ITools-craft}
    function craft(
        uint256 toolType
    ) external whenNotPaused ifNotBlacklisted(_msgSender()) {
        uint256 resourcesAmount;
        uint256[] memory artifactsAmounts;

        (resourcesAmount, artifactsAmounts) = getRecipe(toolType);

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

        for (
            uint256 counter = 0;
            counter < artifactsAmounts.length;
            counter++
        ) {
            if (artifactsAmounts[counter] != 0) {
                _artifacts.safeTransferFrom(
                    _msgSender(),
                    _zeroAddress,
                    counter + 1,
                    artifactsAmounts[counter],
                    ""
                );
            }
        }

        _mint(_msgSender(), toolType, 1, "");

        _toolIds++;
        _ownedTools[_msgSender()][_toolIds] = OwnedTool({
            toolType: uint128(toolType),
            strength: _typesToTools[toolType].maxStrength
        });

        emit Craft(_msgSender(), toolType, _toolIds);
    }

    /// @notice See {ITools-increaseArtifactsTypesAmount}
    function increaseArtifactsTypesAmount() external {
        require(
            msg.sender == address(_artifacts),
            "Tools: caller is not an Artifacts contract"
        );
        _artifactTypesAmount++;
    }

    /// @notice See {ITools-corrupt}
    function corrupt(
        address user,
        uint256 toolId,
        uint256 strengthCost
    ) external whenNotPaused {
        require(
            _msgSender() == _miningAddress,
            "Tools: msg.sender isn't Mining contract"
        );
        _ownedTools[user][toolId].strength -= uint128(strengthCost);
    }

    /// @notice See {ITools-setArtifactsAddress}
    function setArtifactsAddress(address artifactsAddress) external onlyOwner {
        _artifacts = IArtifacts(artifactsAddress);
    }

    /// @notice See {ITools-setMiningAddress}
    function setMiningAddress(address miningAddress) external onlyOwner {
        _miningAddress = miningAddress;
    }

    /// @notice See {ITools-pause}
    function pause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @notice See {ITools-mint}
    function mint(
        address to,
        uint128 toolType,
        uint256 amount
    ) external onlyOwner ifNotBlacklisted(to) {
        require(_toolTypes != 0, "Tools: no tools");
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");

        _mint(to, toolType, amount, "");
        emit MintType(to, toolType, amount);
        for (uint256 counter = 0; counter < amount; counter++) {
            _toolIds++;
            _ownedTools[to][_toolIds] = OwnedTool({
                toolType: toolType,
                strength: _typesToTools[toolType].maxStrength
            });
            emit MintId(to, toolType, _toolIds);
        }
    }

    /// @notice See {ITools-mintBatch}
    function mintBatch(
        address to,
        uint256[] calldata toolTypes,
        uint256[] calldata amounts
    ) external onlyOwner ifNotBlacklisted(to) {
        require(_toolTypes != 0, "Tools: no tools");
        for (uint256 counter = 0; counter < toolTypes.length; counter++) {
            require(
                toolTypes[counter] <= _toolTypes,
                "Tools: invalid toolTypes value"
            );
        }

        _mintBatch(to, toolTypes, amounts, "");
        for (uint256 counter = 0; counter < toolTypes.length; counter++) {
            emit MintType(to, toolTypes[counter], amounts[counter]);
            for (uint256 i = 0; i < amounts.length; i++) {
                _toolIds++;
                _ownedTools[to][_toolIds].toolType = uint128(
                    toolTypes[counter]
                );
                _ownedTools[to][_toolIds].strength = _typesToTools[
                    toolTypes[counter]
                ].maxStrength;
                emit MintId(to, toolTypes[counter], _toolIds);
            }
        }
    }

    /// @dev This function is required for ERC1155 standard
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable, IERC165Upgradeable, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC165Upgradeable).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @notice See {ITools-getRecipe}
    function getRecipe(
        uint256 toolType
    )
        public
        view
        whenNotPaused
        returns (uint256 resourcesAmount, uint256[] memory artifactsAmounts)
    {
        artifactsAmounts = new uint256[](_artifactTypesAmount);

        resourcesAmount = _typesToRecipes[toolType].resourcesAmount;

        for (uint256 counter = 0; counter < _artifactTypesAmount; counter++) {
            if (_typesToRecipes[toolType].artifacts[counter] > 0) {
                artifactsAmounts[counter] = _typesToRecipes[toolType].artifacts[
                    counter
                ];
            }
        }
    }

    /// @notice See {ITools-uri}
    function uri(
        uint256 toolType
    ) public view override(ERC1155Upgradeable, ITools) returns (string memory) {
        string memory tokenURI = _idsToURIs[toolType];
        return
            bytes(tokenURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenURI))
                : super.uri(toolType);
    }

    /// @notice See {ITools-setURI}
    function setURI(uint256 toolType, string calldata newURI) public onlyOwner {
        _setURI(toolType, newURI);
    }

    /// @notice See {ITools-setBaseURI}
    function setBaseURI(string calldata baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    /// @notice See {ITools-setRecipe}
    function setRecipe(
        uint256 toolType,
        uint256 resourcesAmount,
        uint256[] calldata artifactsAmounts
    ) public onlyOwner {
        require(toolType <= _toolTypes, "Tools: invalid toolTypes value");
        require(
            artifactsAmounts.length == _artifactTypesAmount,
            "Tools: invalid array size"
        );

        _typesToRecipes[toolType].resourcesAmount = resourcesAmount;

        for (uint256 counter = 0; counter < _artifactTypesAmount; counter++) {
            _typesToRecipes[toolType].artifacts[counter] = artifactsAmounts[
                counter
            ];
        }

        emit RecipeCreatedOrUpdated(
            toolType,
            resourcesAmount,
            artifactsAmounts
        );
    }

    /// @notice See {ITools-repairTool}
    function repairTool(
        uint256 toolId
    ) public whenNotPaused ifNotBlacklisted(_msgSender()) {
        OwnedTool memory tool = _ownedTools[_msgSender()][toolId];
        uint256 toolTypeId = tool.toolType;
        require(toolTypeId > 0, "Tools: tool does not exist");

        uint128 maxStrength = _typesToTools[tool.toolType].maxStrength;
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

    /// @notice See {ITools-safeTransferFrom}
    function safeTransferFrom(
        address from,
        address to,
        uint256 toolId,
        uint256 amount,
        bytes memory data
    )
        public
        override(ERC1155Upgradeable, ITools)
        whenNotPaused
        ifNotBlacklisted(from)
        ifNotBlacklisted(to)
    {
        require(amount == 1, "Tools: tokenId is unique");

        uint256 toolType = _ownedTools[from][toolId].toolType;
        require(toolType > 0, "Tools: tool doesn't exist");

        require(
            _ownedTools[from][toolId].strength ==
                _typesToTools[toolType].maxStrength,
            "Tools: tool is not fully repaired"
        );

        super.safeTransferFrom(from, to, toolType, amount, data);
        emit Transfer(from, to, toolType, toolId);
        _ownedTools[to][toolId] = _ownedTools[from][toolId];
        delete _ownedTools[from][toolId];
    }

    /// @notice See {ITools-safeBatchTransferFrom}
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory toolIds,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        override(ERC1155Upgradeable, ITools)
        whenNotPaused
        ifNotBlacklisted(from)
        ifNotBlacklisted(to)
    {
        for (uint256 count = 0; count < toolIds.length; count++) {
            require(amounts[count] == 1, "Tools: tokenId is unique");
            safeTransferFrom(from, to, toolIds[count], 1, data);
        }
    }

    /// @dev Private implementation of `setURI`
    function _setURI(uint256 toolType, string calldata tokenURI) internal {
        _idsToURIs[toolType] = tokenURI;
        emit URI(uri(toolType), toolType);
    }

    /// @dev Private implementation of `setBaseURI`
    function _setBaseURI(string calldata baseURI) internal {
        _baseURI = baseURI;
        emit BaseURI(uri(1));
    }
}
