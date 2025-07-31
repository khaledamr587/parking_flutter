const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { protect, authorize } = require('../middleware/auth');

// Middleware: Only allow admin users
const adminOnly = [protect, authorize('admin')];

// Get all users
router.get('/users', adminOnly, async (req, res) => {
  try {
    const result = await query('SELECT id, email, phone, first_name, last_name, user_type, is_active, created_at FROM users ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch users', details: err.message });
  }
});

// Get all parkings
router.get('/parkings', adminOnly, async (req, res) => {
  try {
    const result = await query('SELECT * FROM parkings ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch parkings', details: err.message });
  }
});

// Add a new parking
router.post('/parkings', adminOnly, async (req, res) => {
  try {
    const { name, description, latitude, longitude, address, total_spots, hourly_rate, daily_rate, currency } = req.body;
    const result = await query(
      `INSERT INTO parkings (name, description, latitude, longitude, address, total_spots, available_spots, hourly_rate, daily_rate, currency, is_open, created_at, updated_at, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $6, $7, $8, $9, true, NOW(), NOW(), true)
       RETURNING *`,
      [name, description, latitude, longitude, address, total_spots, hourly_rate, daily_rate, currency]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to add parking', details: err.message });
  }
});

// Update a parking
router.put('/parkings/:id', adminOnly, async (req, res) => {
  try {
    const parkingId = req.params.id;
    const { name, description, latitude, longitude, address, total_spots, hourly_rate, daily_rate, currency, is_open, is_active } = req.body;
    const result = await query(
      `UPDATE parkings SET
        name = $1,
        description = $2,
        latitude = $3,
        longitude = $4,
        address = $5,
        total_spots = $6,
        hourly_rate = $7,
        daily_rate = $8,
        currency = $9,
        is_open = $10,
        is_active = $11,
        updated_at = NOW()
       WHERE id = $12
       RETURNING *`,
      [name, description, latitude, longitude, address, total_spots, hourly_rate, daily_rate, currency, is_open, is_active, parkingId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Parking not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update parking', details: err.message });
  }
});

// Delete a parking
router.delete('/parkings/:id', adminOnly, async (req, res) => {
  try {
    const parkingId = req.params.id;
    await query('DELETE FROM parkings WHERE id = $1', [parkingId]);
    res.json({ message: 'Parking deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete parking', details: err.message });
  }
});

// Get statistics (users, parkings, reservations, payments)
router.get('/stats', adminOnly, async (req, res) => {
  try {
    const users = await query('SELECT COUNT(*) FROM users');
    const parkings = await query('SELECT COUNT(*) FROM parkings');
    const reservations = await query('SELECT COUNT(*) FROM reservations');
    const payments = await query('SELECT COUNT(*) FROM payments');
    res.json({
      users: parseInt(users.rows[0].count, 10),
      parkings: parseInt(parkings.rows[0].count, 10),
      reservations: parseInt(reservations.rows[0].count, 10),
      payments: parseInt(payments.rows[0].count, 10),
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch stats', details: err.message });
  }
});

module.exports = router;