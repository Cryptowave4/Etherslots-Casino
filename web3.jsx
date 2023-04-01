// src/web3.jsx

import React, { useState, useEffect } from "react";
import web3 from "../services/web3";
import diceContract from "../contracts/Dice.json";
import slotsContract from "../contracts/slotsContract.sol";
import rouletteContract from "../contracts/rouletteContract.sol";
import stakeContract from "../contracts/stakeContract.sol";
function DiceGame() {
  const [contract, setContract] = useState(null);
  const [betAmount, setBetAmount] = useState(0);
  const [betNumber, setBetNumber] = useState(1);

  useEffect(() => {
    async function initContract() {
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = diceContract.networks[networkId];
      const instance = new web3.eth.Contract(
        diceContract.abi,
        deployedNetwork && deployedNetwork.address
      );
      setContract(instance);
    }
    initContract();
  }, []);

  async function rollDice() {
    const accounts = await web3.eth.getAccounts();
    await contract.methods.rollDice(betNumber).send({
      from: accounts[0],
      value: web3.utils.toWei(betAmount, "ether"),
    });
    // ...
  }

  // ...
}
