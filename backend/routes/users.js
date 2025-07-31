const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { protect } = require('../middleware/auth');

// Get current user profile
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

// Update user profile
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