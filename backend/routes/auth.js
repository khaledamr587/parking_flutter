const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { protect } = require('../middleware/auth');
const { sendVerificationEmail, sendPasswordResetEmail } = require('../utils/email');
const { sendSMS } = require('../utils/sms');

const router = express.Router();

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  });
};

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('firstName').notEmpty().trim(),
  body('lastName').notEmpty().trim(),
  body('phone').optional().isMobilePhone()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { email, password, firstName, lastName, phone } = req.body;

    // Check if user exists
    const existingUser = await db.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'User already exists'
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Create user
    const result = await db.query(`
      INSERT INTO users (email, password_hash, first_name, last_name, phone)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, email, first_name, last_name, phone, user_type, is_email_verified, is_phone_verified
    `, [email, passwordHash, firstName, lastName, phone]);

    const user = result.rows[0];

    // Generate token
    const token = generateToken(user.id);

    // Send verification email
    if (email) {
      try {
        await sendVerificationEmail(user.email, user.id);
      } catch (error) {
        console.log('Email verification skipped (environment not configured):', error.message);
        // Continue without email verification for testing
      }
    }

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          firstName: user.first_name,
          lastName: user.last_name,
          phone: user.phone,
          userType: user.user_type,
          isEmailVerified: user.is_email_verified,
          isPhoneVerified: user.is_phone_verified
        },
        token
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Check for user
    const result = await db.query(`
      SELECT id, email, password_hash, first_name, last_name, phone, user_type, is_email_verified, is_phone_verified
      FROM users WHERE email = $1
    `, [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    const user = result.rows[0];

    // Check password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    // Generate token
    const token = generateToken(user.id);

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          firstName: user.first_name,
          lastName: user.last_name,
          phone: user.phone,
          userType: user.user_type,
          isEmailVerified: user.is_email_verified,
          isPhoneVerified: user.is_phone_verified
        },
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Get current logged in user
// @route   GET /api/auth/me
// @access  Private
router.get('/me', protect, async (req, res) => {
  try {
    const result = await db.query(`
      SELECT id, email, first_name, last_name, phone, user_type, is_email_verified, is_phone_verified, profile_image, created_at, updated_at
      FROM users WHERE id = $1
    `, [req.user.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const user = result.rows[0];

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        phone: user.phone,
        userType: user.user_type,
        isEmailVerified: user.is_email_verified,
        isPhoneVerified: user.is_phone_verified,
        profileImage: user.profile_image,
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Logout user / clear cookie
// @route   POST /api/auth/logout
// @access  Private
router.post('/logout', protect, async (req, res) => {
  try {
    // In a more complex setup, you might want to blacklist the token
    // For now, we'll just return success
    res.json({
      success: true,
      data: {}
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Forgot password
// @route   POST /api/auth/forgot-password
// @access  Public
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { email } = req.body;

    // Check if user exists
    const result = await db.query('SELECT id, email, first_name FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const user = result.rows[0];

    // Generate reset code
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes

    // Save reset code
    await db.query(`
      INSERT INTO verification_codes (user_id, code, type, expires_at)
      VALUES ($1, $2, $3, $4)
    `, [user.id, resetCode, 'password_reset', expiresAt]);

    // Send reset email
    await sendPasswordResetEmail(user.email, resetCode);

    res.json({
      success: true,
      message: 'Password reset email sent'
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Reset password
// @route   POST /api/auth/reset-password
// @access  Public
router.post('/reset-password', [
  body('email').isEmail().normalizeEmail(),
  body('code').isLength({ min: 6, max: 6 }),
  body('newPassword').isLength({ min: 6 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { email, code, newPassword } = req.body;

    // Verify reset code
    const result = await db.query(`
      SELECT vc.user_id, vc.is_used, vc.expires_at
      FROM verification_codes vc
      JOIN users u ON vc.user_id = u.id
      WHERE u.email = $1 AND vc.code = $2 AND vc.type = 'password_reset'
      ORDER BY vc.created_at DESC
      LIMIT 1
    `, [email, code]);

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid reset code'
      });
    }

    const verificationCode = result.rows[0];

    if (verificationCode.is_used) {
      return res.status(400).json({
        success: false,
        error: 'Reset code already used'
      });
    }

    if (new Date() > verificationCode.expires_at) {
      return res.status(400).json({
        success: false,
        error: 'Reset code expired'
      });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(newPassword, salt);

    // Update password and mark code as used
    await db.query('BEGIN');

    await db.query('UPDATE users SET password_hash = $1 WHERE id = $2', [
      passwordHash, verificationCode.user_id
    ]);

    await db.query('UPDATE verification_codes SET is_used = true WHERE user_id = $1 AND code = $2', [
      verificationCode.user_id, code
    ]);

    await db.query('COMMIT');

    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    await db.query('ROLLBACK');
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Verify email
// @route   POST /api/auth/verify-email
// @access  Public
router.post('/verify-email', [
  body('email').isEmail().normalizeEmail(),
  body('code').isLength({ min: 6, max: 6 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { email, code } = req.body;

    // Verify code
    const result = await db.query(`
      SELECT vc.user_id, vc.is_used, vc.expires_at
      FROM verification_codes vc
      JOIN users u ON vc.user_id = u.id
      WHERE u.email = $1 AND vc.code = $2 AND vc.type = 'email'
      ORDER BY vc.created_at DESC
      LIMIT 1
    `, [email, code]);

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid verification code'
      });
    }

    const verificationCode = result.rows[0];

    if (verificationCode.is_used) {
      return res.status(400).json({
        success: false,
        error: 'Verification code already used'
      });
    }

    if (new Date() > verificationCode.expires_at) {
      return res.status(400).json({
        success: false,
        error: 'Verification code expired'
      });
    }

    // Mark email as verified and code as used
    await db.query('BEGIN');

    await db.query('UPDATE users SET is_email_verified = true WHERE id = $1', [
      verificationCode.user_id
    ]);

    await db.query('UPDATE verification_codes SET is_used = true WHERE user_id = $1 AND code = $2', [
      verificationCode.user_id, code
    ]);

    await db.query('COMMIT');

    res.json({
      success: true,
      message: 'Email verified successfully'
    });
  } catch (error) {
    await db.query('ROLLBACK');
    console.error('Verify email error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Send phone verification code
// @route   POST /api/auth/send-phone-verification
// @access  Private
router.post('/send-phone-verification', protect, [
  body('phone').isMobilePhone()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { phone } = req.body;

    // Generate verification code
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Save verification code
    await db.query(`
      INSERT INTO verification_codes (user_id, code, type, expires_at)
      VALUES ($1, $2, $3, $4)
    `, [req.user.id, verificationCode, 'phone', expiresAt]);

    // Send SMS
    await sendSMS(phone, `Your verification code is: ${verificationCode}`);

    res.json({
      success: true,
      message: 'Verification code sent'
    });
  } catch (error) {
    console.error('Send phone verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Verify phone
// @route   POST /api/auth/verify-phone
// @access  Private
router.post('/verify-phone', protect, [
  body('code').isLength({ min: 6, max: 6 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: errors.array()
      });
    }

    const { code } = req.body;

    // Verify code
    const result = await db.query(`
      SELECT id, is_used, expires_at
      FROM verification_codes
      WHERE user_id = $1 AND code = $2 AND type = 'phone'
      ORDER BY created_at DESC
      LIMIT 1
    `, [req.user.id, code]);

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid verification code'
      });
    }

    const verificationCode = result.rows[0];

    if (verificationCode.is_used) {
      return res.status(400).json({
        success: false,
        error: 'Verification code already used'
      });
    }

    if (new Date() > verificationCode.expires_at) {
      return res.status(400).json({
        success: false,
        error: 'Verification code expired'
      });
    }

    // Mark phone as verified and code as used
    await db.query('BEGIN');

    await db.query('UPDATE users SET is_phone_verified = true WHERE id = $1', [req.user.id]);

    await db.query('UPDATE verification_codes SET is_used = true WHERE id = $1', [
      verificationCode.id
    ]);

    await db.query('COMMIT');

    res.json({
      success: true,
      message: 'Phone verified successfully'
    });
  } catch (error) {
    await db.query('ROLLBACK');
    console.error('Verify phone error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

module.exports = router; 