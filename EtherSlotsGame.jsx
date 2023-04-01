// src/EtherSlotsGame.js

import Web3 from 'web3';
import React, { useRef, useEffect } from 'react';
import Phaser from 'phaser';
import EtherSlotsGame from './EtherSlotsGame.css';
const PhaserSlotGame = () => {
  const gameContainer = useRef(null);

  useEffect(() => {
    const config = {
      type: Phaser.AUTO,
      width: 1000,
      height: 800,
      parent: gameContainer.current,
      scene: {
        preload: preload,
        create: create,
        update: update
      }
    };

    const game = new Phaser.Game(config);

    const wheelCount = 4;
    const symbols = ['symbol1', 'symbol2', 'symbol3', 'symbol4', 'symbol5', 'symbol6', 'symbol7'];
    const spinDuration = 2000;
    let wheels = [];
    let spinning = false;

    function preload() {
      for (let i = 1; i <= symbols.length; i++) {
        this.load.image(`symbol${i}`,src\components\slotsimg\0.png `${i - 1}.png`);
        this.load.image(`symbol${i}`,src\components\slotsimg\1.png `${i - 2}.png`);
        this.load.image(`symbol${i}`,src\components\slotsimg\2.png `${i - 3}.png`);
        this.load.image(`symbol${i}`,src\components\slotsimg\3.png `${i - 4}.png`);
        this.load.image(`symbol${i}`,src\components\slotsimg\4.png `${i - 5}.png`);
        this.load.image(`symbol${i}`,src\components\slotsimg\5.png `${i - 6}.png`);
        this.load.image(`symbol${i}`,src\components\slotsimg\6.png `${i - 7}.png`);
      }
      this.load.image('background','src\components\slotsimg\25bg.jpg');
    }

    function create() {
      for (let i = 0; i < wheelCount; i++) {
        const wheel = this.add.group();
        for (let j = 0; j < 5; j++) {
          const symbol = this.add.sprite(100 + i * 100, 50 + j * 100, Phaser.Math.RND.pick(symbols));
          wheel.add(symbol);
        }
        wheels.push(wheel);
      }

      this.input.on('pointerdown', spin, this);
    }

    function update() {
      if (spinning) {
        for (let i = 0; i < wheelCount; i++) {
          const wheel = wheels[i];
          wheel.children.iterate(child => {
            child.y += 10;
            if (child.y > 550) {
              child.y = -50;
              child.setTexture(Phaser.Math.RND.pick(symbols));
            }
          });
        }
      }
    }

    function spin() {
      if (!spinning) {
        spinning = true;
        setTimeout(() => {
          spinning = false;
        }, spinDuration);
      }
    }

    return () => {
      game.destroy(true);
    };
  }, []);

  return <div ref={gameContainer} />;
};

export default EtherSlotsGame;
