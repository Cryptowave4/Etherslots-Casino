// src/EsgButton.js

import React from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";

const StyledButton = styled.button`
display: inline-block;
padding: 10px 20px;
border-radius: 20px;
border: 10px gradient rgb(200, 140, 200) rgb(130, 130, 208);
color: #975263;
font-size: 26px;
font-weight: bold;
text-transform: uppercase;
cursor: pointer;
transition: background-color 0.4s ease-in-out;
}

.button:hover {
background-color: #7b59aa;
color: #e84c3e;
}
`;

const EsgButton = () => {
  return (
    <Link to="/etherslotsgame">
      <StyledButton>Etherslots Game</StyledButton>
    </Link>
  );
};

export default EsgButton;
