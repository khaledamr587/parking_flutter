const twilio = require('twilio');

// Initialize Twilio client
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Send SMS
const sendSMS = async (to, message) => {
  try {
    const result = await twilioClient.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: to
    });

    console.log(`SMS sent successfully to ${to}. SID: ${result.sid}`);
    return result;
  } catch (error) {
    console.error('Error sending SMS:', error);
    throw error;
  }
};

// Send verification code via SMS
const sendVerificationSMS = async (phoneNumber, verificationCode) => {
  const message = `Your Parking App verification code is: ${verificationCode}. This code will expire in 10 minutes.`;
  return await sendSMS(phoneNumber, message);
};

// Send booking confirmation SMS
const sendBookingConfirmationSMS = async (phoneNumber, bookingDetails) => {
  const message = `Your parking booking at ${bookingDetails.parkingName} is confirmed for ${bookingDetails.date} at ${bookingDetails.startTime}. Booking ID: ${bookingDetails.bookingId}`;
  return await sendSMS(phoneNumber, message);
};

// Send payment confirmation SMS
const sendPaymentConfirmationSMS = async (phoneNumber, paymentDetails) => {
  const message = `Payment of €${paymentDetails.amount} processed successfully. Transaction ID: ${paymentDetails.transactionId}. Thank you for using Parking App!`;
  return await sendSMS(phoneNumber, message);
};

// Send reminder SMS
const sendReminderSMS = async (phoneNumber, reminderDetails) => {
  const message = `Reminder: Your parking reservation at ${reminderDetails.parkingName} starts in ${reminderDetails.minutesUntilStart} minutes.`;
  return await sendSMS(phoneNumber, message);
};

// Send expiry warning SMS
const sendExpiryWarningSMS = async (phoneNumber, expiryDetails) => {
  const message = `Warning: Your parking reservation at ${expiryDetails.parkingName} expires in ${expiryDetails.minutesUntilExpiry} minutes.`;
  return await sendSMS(phoneNumber, message);
};

module.exports = {
  sendSMS,
  sendVerificationSMS,
  sendBookingConfirmationSMS,
  sendPaymentConfirmationSMS,
  sendReminderSMS,
  sendExpiryWarningSMS
}; 