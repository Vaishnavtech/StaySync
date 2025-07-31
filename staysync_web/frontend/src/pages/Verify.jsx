import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Verify.css";

const rooms = {
  "101": "guest101",
  "102": "guest102",
  "103": "guest103",
};

function Verify() {
  const [room, setRoom] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSubmit = (e) => {
    e.preventDefault();
    if (rooms[room] === password) {
      setError("");
      navigate("/dashboard"); // replace with your target route
    } else {
      setError("Invalid room or password ❌");
    }
  };

  return (
    <div className="verify-container">
      <div className="verify-card">
        <h2>LOGIN</h2>
        <form onSubmit={handleSubmit}>
          <label>
            Room Number:
            <select
              value={room}
              onChange={(e) => setRoom(e.target.value)}
              required
            >
              <option value="">--Select--</option>
              {Object.keys(rooms).map((roomNo) => (
                <option key={roomNo} value={roomNo}>
                  {roomNo}
                </option>
              ))}
            </select>
          </label>

          <label>
            Password:
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </label>

          <button type="submit">Verify</button>
          {error && <p className="error">{error}</p>}
        </form>
      </div>
    </div>
  );
}

export default Verify;
