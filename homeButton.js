import React from "react";
import "./Button.css";

function Button(props) {
  return (
    <button className="button" style={{ backgroundColor: props.color }}>
      {props.children}
    </button>
  );
}

export default Button;
