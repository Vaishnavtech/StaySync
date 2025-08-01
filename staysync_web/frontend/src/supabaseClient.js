import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "https://tkhkvpquwqnyvwflfhpx.supabase.co";
const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRraGt2cHF1d3FueXZ3ZmxmaHB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NjEyNjYsImV4cCI6MjA2OTUzNzI2Nn0.a5AZNhl4UawXaRfQUAFqdWRmAmY6rBLH1rshEkRSg6g";

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
