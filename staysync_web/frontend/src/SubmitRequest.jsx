import React from "react";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import ServiceForm from "../components/ServiceForm";

function SubmitRequest() {
  return (
    <>
      <Navbar />
      <div
        style={{ padding: "2rem", background: "#8b6e4b", minHeight: "80vh" }}
      >
        <h2 style={{ textAlign: "center" }}>Submit Your Service Request</h2>
        <ServiceForm />
      </div>
      <Footer />
    </>
  );
}

export default SubmitRequest;
