import React, { useState } from "react";
import { supabase } from "../supabaseClient";

function SubmitRequest() {
  const [formData, setFormData] = useState({
    room_number: "",
    serviceType: "",
    notes: "",
  });

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log("Submitting:", formData);

    const { error, data } = await supabase.from("staysync").insert([
      {
        room_number: parseInt(formData.room_number),
        servicetype: formData.serviceType,
        notes: formData.notes,
        status: "Pending",
        createdat: new Date().toISOString(),
      },
    ]);

    if (error) {
      console.error("Supabase insert error:", error);
      alert("Submission failed: " + error.message);
    } else {
      console.log("Inserted data:", data);
      alert("Request submitted successfully!");
      setFormData({
        room_number: "",
        serviceType: "",
        notes: "",
      });
    }
  };

  return (
    <div style={{ padding: "2rem" }}>
      <h2>Submit Service Request</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Room Number:
          <input
            type="number"
            name="room_number"
            value={formData.room_number}
            onChange={handleChange}
            required
          />
        </label>
        <br />
        <br />
        <label>
          Service Type:
          <select
            name="serviceType"
            value={formData.serviceType}
            onChange={handleChange}
            required
          >
            <option value="">--Select--</option>
            <option value="Room Cleaning">Room Cleaning</option>
            <option value="Laundry">Laundry</option>
            <option value="Cab Booking">Cab Booking</option>
            <option value="Food Order">Food Order</option>
          </select>
        </label>
        <br />
        <br />
        <label>
          Notes:
          <textarea
            name="notes"
            value={formData.notes}
            onChange={handleChange}
          />
        </label>
        <br />
        <br />
        <button type="submit">Submit Request</button>
      </form>
    </div>
  );
}

export default SubmitRequest;
