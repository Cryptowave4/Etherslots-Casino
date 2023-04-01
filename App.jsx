// src/App.js

import { createClient, configureChains, WagmiConfig } from 'wagmi';
import { publicProvider } from 'wagmi/providers/public';
import { mainnet } from "wagmi/chains";
import Signin from './signin';
import User from './user';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import logo from "./logo.svg";
import "./Ap.css";
import Button from "./styles/homeButton";
import web3 from "./services/web3.jsx";
import { useEffect, useState } from "react";
import EsgButton from "./styles/EsgButton";
import homeButton from './styles/homeButton';
import rlttButton from './styles/rlttButton';

const { provider, webSocketProvider } = configureChains([mainnet], [
  publicProvider(),
]);

const client = createClient({
  provider,
  webSocketProvider,
  autoConnect: true,
});

const router = createBrowserRouter([
  {
    path: '/signin',
    element: <Signin />,
  },
  {
    path: '/user',
    element: <User />,
  },
]);

function App() {
  return (
    <Router>
      <div className="App">
        <header className="App-header">
          <EsgButton />
          <Switch>
            <Route path="/" exact component={EtherSlotsGame} />
            {EtherSlotsGame}
            {/*h="/etherslotsgame" component={Etherslotsgame} /> */}
          </Switch>
          <homeButton />
          <Switch>
            <Route path="/" exact component={homeButton} />
            {homeButton}
            {/*h="/" component={Etherslotsgame} /> */}
          </Switch>
          <homeButton />
          <Switch>
            <Route path="/" exact component={rltButton} />
            {rltButton}
            {/*h="/" component={EtherSlots Roulette} /> */}
          </Switch>
          <homeButton />
          <Switch>
            <Route path="/" exact component={homeButton} />
            {homeButton}
            {/*h="/" component={Ethers} /> */}
          </Switch>
        </header>
      </div>
      <WagmiConfig client={client}>
      <RouterProvider router={router} />
    </WagmiConfig>
  );

export default App;

