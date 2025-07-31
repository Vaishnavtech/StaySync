import React, { useState } from "react";
import { supabase } from "../supabaseClient";

function ServiceForm() {
  const [formData, setFormData] = useState({
    room_number: "",
    serviceType: "",
    notes: "",
  });

  const [submitted, setSubmitted] = useState(false);

  const handleChange = (e) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const { error } = await supabase.from("staysync").insert([
      {
        room_number: parseInt(formData.room_number),
        serviceType: formData.serviceType,
        notes: formData.notes,
        status: "Pending",
        createdAt: new Date().toISOString(),
      },
    ]);

    if (error) {
      alert("Error submitting request");
      console.error(error);
    } else {
      setSubmitted(true);
    }
  };

  if (submitted) {
    return (
      <p style={{ textAlign: "center", color: "green" }}>
        Request submitted successfully!
      </p>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      style={{
        maxWidth: "500px",
        margin: "0 auto",
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        background: "#8b6e4b",
      }}
    >
      <input
        type="number"
        name="room_number"
        placeholder="Room Number"
        value={formData.room_number}
        onChange={handleChange}
        required
      />
      <select
        name="serviceType"
        value={formData.serviceType}
        onChange={handleChange}
        required
      >
        <option value="">Select Service</option>
        <option value="Room Cleaning">Room Cleaning</option>
        <option value="Laundry">Laundry</option>
        <option value="Cab Booking">Cab Booking</option>
      </select>
      <textarea
        name="notes"
        placeholder="Additional Notes"
        value={formData.notes}
        onChange={handleChange}
        rows="4"
      />
      <button
        type="submit"
        style={{ padding: "0.5rem", background: "#8b6e4b", color: "white" }}
      >
        Submit
      </button>
    </form>
  );
}

export default ServiceForm;
