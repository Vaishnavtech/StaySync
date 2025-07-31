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
          minHeight: "100vh",
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
/*
import React, { useEffect } from "react";
import Navbar from "../components/Navbar";
import Hero from "../components/Hero";
import Services from "../components/Services";
import Footer from "../components/Footer";
import { supabase } from "../supabaseClient"; // ✅ import supabase

function Home() {
  // ✅ Fetch from Supabase once component loads
  useEffect(() => {
    const fetchData = async () => {
      const { data, error } = await supabase.from("StaySync").select("*");

      if (error) {
        console.error("Supabase error:", error.message);
      } else {
        console.log("Fetched data from Supabase:", data);
      }
    };

    fetchData();
  }, []);

  return (
    <>
      <Navbar />
      <div
        style={{
          backgroundImage: `url(${process.env.PUBLIC_URL}/reception.png)`,
          backgroundSize: "cover",
          backgroundPosition: "center",
          backgroundRepeat: "no-repeat",
          minHeight: "100vh",
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
*/
