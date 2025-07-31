// Navbar.js
import React from "react";
import { Link } from "react-router-dom";

function Navbar() {
  return (
    <nav
      style={{
        padding: "1rem 2rem",
        background: "#8b6e4b",
        color: "#fff",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
      }}
    >
      <h2 style={{ margin: 0 }}>StaySync</h2>
      <div>
        <Link
          to="/submit"
          style={{ color: "#fff", margin: "0 1rem", textDecoration: "none" }}
        >
          Submit Request
        </Link>
        <Link
          to="/track"
          style={{ color: "#fff", margin: "0 1rem", textDecoration: "none" }}
        >
          Track Status
        </Link>
      </div>
    </nav>
  );
}

export default Navbar;
