const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { protect } = require('../middleware/auth');

// Get current user profile (alias for /me)
router.get('/me', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await query(
      'SELECT id, email, phone, first_name, last_name, profile_image, is_email_verified, is_phone_verified, user_type, created_at, updated_at FROM users WHERE id = $1',
      [userId]
    );
    
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
        user: {
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
      }
    });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch user profile',
      details: err.message 
    });
  }
});

// Get current user profile (original route)
router.get('/profile', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await query(
      'SELECT id, email, phone, first_name, last_name, profile_image, is_email_verified, is_phone_verified, user_type, created_at FROM users WHERE id = $1',
      [userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch user profile', details: err.message });
  }
});

// Update user profile (alias for /me)
router.put('/me', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const { first_name, last_name, phone } = req.body;
    
    const result = await query(
      'UPDATE users SET first_name = $1, last_name = $2, phone = $3, updated_at = NOW() WHERE id = $4 RETURNING id, email, phone, first_name, last_name, profile_image, is_email_verified, is_phone_verified, user_type, created_at, updated_at',
      [first_name, last_name, phone, userId]
    );
    
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
        user: {
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
      }
    });
  } catch (err) {
    console.error('Update user error:', err);
    res.status(500).json({ 
      success: false,
      error: 'Failed to update user profile',
      details: err.message 
    });
  }
});

// Update user profile (original route)
router.put('/profile', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const { first_name, last_name, phone } = req.body;
    
    const result = await query(
      'UPDATE users SET first_name = $1, last_name = $2, phone = $3, updated_at = NOW() WHERE id = $4 RETURNING id, email, phone, first_name, last_name, profile_image, is_email_verified, is_phone_verified, user_type, created_at',
      [first_name, last_name, phone, userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update user profile', details: err.message });
  }
});

// Get user by ID (for admin or public info)
router.get('/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const result = await query(
      'SELECT id, first_name, last_name, profile_image, user_type, created_at FROM users WHERE id = $1 AND is_active = true',
      [userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch user', details: err.message });
  }
});

module.exports = router;