// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

interface IMining {
    struct MiningSession {
        uint32 endTime;
        uint32 rewardRate;
        uint32 energyCost;
        uint16 toolType;
        uint16 strengthCost;
        bool started;
    }
}
