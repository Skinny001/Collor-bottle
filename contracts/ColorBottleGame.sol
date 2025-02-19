// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ColorBottleGame {
    // ------------------- Errors ------------------- //
    error GameAlreadyWon();
    error MaxAttemptsReached();
    error InvalidBottleNumber(uint256 bottleNumber);
    error DuplicateBottleNumber();

    // ------------------- State Variables ------------------- //
    uint256[5] private correctSequence;
    uint256 public attempts;
    bool public gameWon;

    // ------------------- Events ------------------- //
    event AttemptResult(uint256 correctPositions);
    event NewGameStarted();

    // ------------------- Constructor ------------------- //
    constructor() {
        shuffleBottles();
    }

    // ------------------- Functions ------------------- //
    
    function shuffleBottles() private {
        for (uint256 i = 0; i < 5; i++) {
            correctSequence[i] = i + 1;
        }
        
        for (uint256 i = 4; i > 0; i--) {
            uint256 j = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % (i + 1);
            (correctSequence[i], correctSequence[j]) = (correctSequence[j], correctSequence[i]);
        }
        
        attempts = 0;
        gameWon = false;
        emit NewGameStarted();
    }

    function makeAttempt(uint256[5] memory playerGuess) public returns (uint256) {
        if (gameWon) {
            revert GameAlreadyWon();
        }
        if (attempts >= 5) {
            revert MaxAttemptsReached();
        }

        bool[6] memory used = [false, false, false, false, false, false];

        for (uint256 i = 0; i < 5; i++) {
            if (playerGuess[i] < 1 || playerGuess[i] > 5) {
                revert InvalidBottleNumber(playerGuess[i]);
            }
            if (used[playerGuess[i]]) {
                revert DuplicateBottleNumber();
            }
            used[playerGuess[i]] = true;
        }

        uint256 correctPositions = 0;
        for (uint256 i = 0; i < 5; i++) {
            if (playerGuess[i] == correctSequence[i]) {
                correctPositions++;
            }
        }

        attempts++;

        if (correctPositions == 5) {
            gameWon = true;
        } else if (attempts == 5) {
            shuffleBottles();
        }

        emit AttemptResult(correctPositions);
        return correctPositions;
    }

    function startNewGame() public {
        shuffleBottles();
    }

    function getCurrentAttempts() public view returns (uint256) {
        return attempts;
    }
}
