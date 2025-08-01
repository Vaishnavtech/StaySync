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
