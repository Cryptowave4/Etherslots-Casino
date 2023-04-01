// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IGame.sol";
import "./Randomizer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SixSidedDice is IGame, Ownable {
    address public randomizerAddress;
    uint256 private constant MAX_SIDES = 6;

    event DiceRoll(address indexed user, uint256 indexed result);
    event BetResult(address indexed user, uint256 indexed amount, bool indexed won);

    constructor(address _randomizerAddress) {
        randomizerAddress = _randomizerAddress;
    }

    function interact(uint256 betAmount, address user) external override {
        require(betAmount > 0, "Bet amount should be greater than 0");

        // Request a random number from the Randomizer oracle
        uint256 requestId = Randomizer(randomizerAddress).request(500000);

        // Generate a random dice roll
        uint256 result = (uint256(keccak256(abi.encodePacked(block.timestamp, requestId))) % MAX_SIDES) + 1;

        // Emit the DiceRoll event
        emit DiceRoll(user, result);

        // Check if user won bet
        bool won = false;
        if (betUnder > 0 && result <= betUnder) {
            won = true;
        } else if (betOver > 0 && result >= betOver) {
            won = true;
        }

        // Emit the BetResult event
        emit BetResult(user, betAmount, won);
    }
     function rollOver(uint256 betAmount, uint256 targetNumber, address user) external {
        require(targetNumber > 0 && targetNumber < MAX_SIDES, "Target number should be between 1 and 5");
        uint256 betUnder = 0;
        uint256 betOver = targetNumber;
        interact(betAmount, user);
   }
    function rollUnder(uint256 betAmount, uint256 targetNumber, address user) external {
        require(targetNumber > 0 && targetNumber < MAX_SIDES, "Target number should be between 1 and 5");
        uint256 betUnder = targetNumber;
        interact(betAmount, user);
    }

}
