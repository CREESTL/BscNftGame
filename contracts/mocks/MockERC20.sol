// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Mock ERC20 contract to be used in tests
contract Resource is ERC20 {
    constructor() ERC20("Test", "Test") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
