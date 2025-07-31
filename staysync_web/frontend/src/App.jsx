/*
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import Verify from "./pages/Verify";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Verify />} />
        <Route path="/home" element={<Home />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
*/

// App.jsx
import { Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import Verify from "./pages/Verify";
import SubmitRequest from "./pages/SubmitRequest";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Verify />} />
      <Route path="/home" element={<Home />} />
      <Route path="/submit-request" element={<SubmitRequest />} />
    </Routes>
  );
}

export default App;
