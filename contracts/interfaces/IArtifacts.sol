// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";


interface IArtifacts is IERC1155Upgradeable {
    function mint(uint256 artifactId, address to, uint256 amount) external;
    function setApprovalForAll(address operator, bool approved) external; 
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
}