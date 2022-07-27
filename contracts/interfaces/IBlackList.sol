// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IBlackList {
    function check(address user) external returns (bool);
}
