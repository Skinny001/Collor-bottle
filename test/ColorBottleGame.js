const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ColorBottleGame", function () {
  let game;

  beforeEach(async function () {
    const ColorBottleGame = await ethers.getContractFactory("ColorBottleGame");
    game = await ColorBottleGame.deploy();
    await game.waitForDeployment(); // Wait for deployment to complete
  });

  it("should initialize with 0 attempts", async function () {
    expect(await game.getCurrentAttempts()).to.equal(0);
  });

  it("should not allow duplicate numbers in guess", async function () {
    await expect(
      game.makeAttempt([1, 1, 2, 3, 4])
    ).to.be.revertedWithCustomError(game, "DuplicateBottleNumber");
  });

  it("should not allow invalid bottle numbers", async function () {
    await expect(
      game.makeAttempt([1, 2, 3, 4, 6])
    ).to.be.revertedWithCustomError(game, "InvalidBottleNumber");
  });

  it("should increment attempts after each guess", async function () {
    await game.makeAttempt([1, 2, 3, 4, 5]);
    expect(await game.getCurrentAttempts()).to.equal(1);
  });

  it("should emit AttemptResult event with correct positions", async function () {
    await expect(game.makeAttempt([1, 2, 3, 4, 5]))
      .to.emit(game, "AttemptResult");
  });

  it("should start a new game and reset attempts", async function () {
    await game.makeAttempt([1, 2, 3, 4, 5]);
    await game.startNewGame();
    expect(await game.getCurrentAttempts()).to.equal(0);
  });
});
