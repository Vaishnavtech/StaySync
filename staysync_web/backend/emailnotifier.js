import { createClient } from '@supabase/supabase-js';
import nodemailer from 'nodemailer';
import dotenv from 'dotenv';
dotenv.config();
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});
async function sendEmail(to, room_number, servicetype, notes) {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to,
    subject: `Service Completed: ${servicetype}`,
    text: `Dear Guest,\n\nYour requested service "${servicetype}" for Room ${room_number} has been completed.\n\nNotes: ${notes}\n\nThank you for staying with us!`,
  };

  await transporter.sendMail(mailOptions);
  console.log(`✅ Email sent to ${to} for room ${room_number}`);
}

async function checkAndNotify() {
  const { data, error } = await supabase
    .from('staysync') 
    .select('*')
    .eq('status', 'Completed')
    .eq('notified', false);

  if (error) {
    console.error('Error fetching data:', error.message);
    return;
  }

  if (!data.length) {
    console.log('No completed services found that need notification.');
    return;
  }

  for (const row of data) {
    if (row.email) {
      await sendEmail(row.email, row.room_number, row.servicetype, row.notes);
      await supabase
        .from('staysync')
        .update({ notified: true })
        .eq('id', row.id);
        
    } else {
      console.log(`No email found for row ID ${row.id}`);
    }
  }
}

checkAndNotify();
setInterval(() => {
  console.log("Checking for completed services...");
  checkAndNotify();
}, 10000);