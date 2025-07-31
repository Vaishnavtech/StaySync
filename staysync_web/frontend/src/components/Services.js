// Services.js
import React from "react";

function Services() {
  const items = [
    "Room Cleaning",
    "Laundry Pickup",
    "In-Room Dining",
    "Cab Request",
    "Wake-Up Call",
  ];

  return (
    <div
      style={{
        padding: "3rem",
        color: "#fff",
        textShadow: "1px 1px 3px rgba(0,0,0,0.6)",
      }}
    >
      <h2 style={{ fontSize: "1.8rem", marginBottom: "1rem" }}>
        Available Services
      </h2>
      <ul
        style={{
          listStyleType: "square",
          paddingLeft: "1.5rem",
          fontSize: "1.1rem",
        }}
      >
        {items.map((service) => (
          <li key={service} style={{ marginBottom: "0.5rem" }}>
            {service}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default Services;
