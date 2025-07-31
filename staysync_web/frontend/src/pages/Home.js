// Home.js
import React from "react";
import Navbar from "../components/Navbar";
import Hero from "../components/Hero";
import Services from "../components/Services";
import Footer from "../components/Footer";

function Home() {
  return (
    <>
      <Navbar />
      <div
        style={{
          backgroundImage: `url(${process.env.PUBLIC_URL}/reception.png)`,
          backgroundSize: "cover",
          backgroundPosition: "center",
          backgroundRepeat: "no-repeat",
        }}
      >
        <Hero />
        <Services />
      </div>
      <Footer />
    </>
  );
}

export default Home;
