// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IGame.sol";
import "./Randomizer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SlotMachine is IGame, Ownable {
    address public randomizerAddress;
    uint256 public constant NUM_REELS = 3;
    uint256 public constant NUM_SYMBOLS = 5;

    uint256[NUM_SYMBOLS] public payoutMultipliers = [0, 2, 3, 5, 10];

    event SpinResult(uint256[NUM_REELS] result);
    event Payout(address indexed player, uint256 amount);

    constructor(address _randomizerAddress) {
        randomizerAddress = _randomizerAddress;
    }

    function interact(uint256 betAmount, address user) external override {
        require(betAmount > 0, "Bet amount should be greater than 0");

        // Request a random number from the Randomizer oracle
        uint256 requestId = Randomizer(randomizerAddress).request(500000);

        // Simulate the slot machine spin and calculate the result
        uint256[NUM_REELS] memory spinResult;
        uint256 payout = betAmount;
        for (uint256 i = 0; i < NUM_REELS; i++) {
            spinResult[i] = (uint256(keccak256(abi.encodePacked(block.timestamp, requestId, i))) % NUM_SYMBOLS);
            payout *= payoutMultipliers[spinResult[i]];
        }

        // Emit the SpinResult event
        emit SpinResult(spinResult);

        // Calculate the payout amount and emit the Payout event
        if (payout > 0) {
            emit Payout(user, payout);
        }
    }

    function setRandomizerAddress(address _randomizerAddress) external onlyOwner {
        randomizerAddress = _randomizerAddress;
    }
}
