const nodemailer = require('nodemailer');
const db = require('../config/database');

// Create transporter
const createTransporter = () => {
  return nodemailer.createTransporter({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: process.env.EMAIL_PORT === '465', // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });
};

// Send verification email
const sendVerificationEmail = async (email, userId) => {
  try {
    // Generate verification code
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes

    // Save verification code to database
    await db.query(`
      INSERT INTO verification_codes (user_id, code, type, expires_at)
      VALUES ($1, $2, $3, $4)
    `, [userId, verificationCode, 'email', expiresAt]);

    // Create transporter
    const transporter = createTransporter();

    // Email content
    const mailOptions = {
      from: `"Parking App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Verify Your Email - Parking App',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center;">
            <h1>Welcome to Parking App!</h1>
          </div>
          <div style="padding: 20px; background-color: #f9f9f9;">
            <h2>Email Verification</h2>
            <p>Thank you for registering with Parking App. To complete your registration, please verify your email address.</p>
            <div style="background-color: #e8f5e8; padding: 15px; border-radius: 5px; text-align: center; margin: 20px 0;">
              <h3 style="margin: 0; color: #2e7d32;">Your Verification Code:</h3>
              <h1 style="margin: 10px 0; color: #2e7d32; font-size: 32px; letter-spacing: 5px;">${verificationCode}</h1>
            </div>
            <p>This code will expire in 30 minutes.</p>
            <p>If you didn't create an account with Parking App, please ignore this email.</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
              <p style="color: #666; font-size: 12px;">
                This is an automated email. Please do not reply to this message.
              </p>
            </div>
          </div>
        </div>
      `
    };

    // Send email
    await transporter.sendMail(mailOptions);
    console.log(`Verification email sent to ${email}`);

  } catch (error) {
    console.error('Error sending verification email:', error);
    throw error;
  }
};

// Send password reset email
const sendPasswordResetEmail = async (email, resetCode) => {
  try {
    // Create transporter
    const transporter = createTransporter();

    // Email content
    const mailOptions = {
      from: `"Parking App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Password Reset - Parking App',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background-color: #2196F3; color: white; padding: 20px; text-align: center;">
            <h1>Password Reset Request</h1>
          </div>
          <div style="padding: 20px; background-color: #f9f9f9;">
            <h2>Reset Your Password</h2>
            <p>You requested to reset your password for your Parking App account.</p>
            <div style="background-color: #e3f2fd; padding: 15px; border-radius: 5px; text-align: center; margin: 20px 0;">
              <h3 style="margin: 0; color: #1565c0;">Your Reset Code:</h3>
              <h1 style="margin: 10px 0; color: #1565c0; font-size: 32px; letter-spacing: 5px;">${resetCode}</h1>
            </div>
            <p>This code will expire in 30 minutes.</p>
            <p>If you didn't request a password reset, please ignore this email and your password will remain unchanged.</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
              <p style="color: #666; font-size: 12px;">
                This is an automated email. Please do not reply to this message.
              </p>
            </div>
          </div>
        </div>
      `
    };

    // Send email
    await transporter.sendMail(mailOptions);
    console.log(`Password reset email sent to ${email}`);

  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw error;
  }
};

// Send booking confirmation email
const sendBookingConfirmationEmail = async (email, bookingDetails) => {
  try {
    // Create transporter
    const transporter = createTransporter();

    // Email content
    const mailOptions = {
      from: `"Parking App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Booking Confirmation - Parking App',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center;">
            <h1>Booking Confirmed!</h1>
          </div>
          <div style="padding: 20px; background-color: #f9f9f9;">
            <h2>Your parking reservation has been confirmed</h2>
            <div style="background-color: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <h3>Booking Details:</h3>
              <p><strong>Parking:</strong> ${bookingDetails.parkingName}</p>
              <p><strong>Date:</strong> ${bookingDetails.date}</p>
              <p><strong>Time:</strong> ${bookingDetails.startTime} - ${bookingDetails.endTime}</p>
              <p><strong>Duration:</strong> ${bookingDetails.duration} hours</p>
              <p><strong>Total Amount:</strong> €${bookingDetails.totalAmount}</p>
              <p><strong>Booking ID:</strong> ${bookingDetails.bookingId}</p>
            </div>
            <p>Please arrive on time and enjoy your parking experience!</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
              <p style="color: #666; font-size: 12px;">
                This is an automated email. Please do not reply to this message.
              </p>
            </div>
          </div>
        </div>
      `
    };

    // Send email
    await transporter.sendMail(mailOptions);
    console.log(`Booking confirmation email sent to ${email}`);

  } catch (error) {
    console.error('Error sending booking confirmation email:', error);
    throw error;
  }
};

// Send payment receipt email
const sendPaymentReceiptEmail = async (email, paymentDetails) => {
  try {
    // Create transporter
    const transporter = createTransporter();

    // Email content
    const mailOptions = {
      from: `"Parking App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Payment Receipt - Parking App',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background-color: #FF9800; color: white; padding: 20px; text-align: center;">
            <h1>Payment Successful!</h1>
          </div>
          <div style="padding: 20px; background-color: #f9f9f9;">
            <h2>Payment Receipt</h2>
            <div style="background-color: #fff3e0; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <h3>Payment Details:</h3>
              <p><strong>Transaction ID:</strong> ${paymentDetails.transactionId}</p>
              <p><strong>Amount:</strong> €${paymentDetails.amount}</p>
              <p><strong>Payment Method:</strong> ${paymentDetails.paymentMethod}</p>
              <p><strong>Date:</strong> ${paymentDetails.date}</p>
              <p><strong>Status:</strong> ${paymentDetails.status}</p>
            </div>
            <p>Thank you for using Parking App!</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
              <p style="color: #666; font-size: 12px;">
                This is an automated email. Please do not reply to this message.
              </p>
            </div>
          </div>
        </div>
      `
    };

    // Send email
    await transporter.sendMail(mailOptions);
    console.log(`Payment receipt email sent to ${email}`);

  } catch (error) {
    console.error('Error sending payment receipt email:', error);
    throw error;
  }
};

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendBookingConfirmationEmail,
  sendPaymentReceiptEmail
}; 