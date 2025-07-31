const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { protect } = require('../middleware/auth');

// Get all reservations for the current user
router.get('/', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await query(
      `SELECT r.*, p.name AS parking_name, p.address AS parking_address
       FROM reservations r
       JOIN parkings p ON r.parking_id = p.id
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC`,
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch reservations', details: err.message });
  }
});

// Create a new reservation
router.post('/', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const { parking_id, start_time, end_time, total_amount, payment_method } = req.body;

    // Check if parking exists and has available spots
    const parkingResult = await query('SELECT * FROM parkings WHERE id = $1', [parking_id]);
    if (parkingResult.rows.length === 0) {
      return res.status(404).json({ error: 'Parking not found' });
    }
    const parking = parkingResult.rows[0];
    if (parking.available_spots <= 0) {
      return res.status(400).json({ error: 'No available spots' });
    }

    // Create reservation
    const result = await query(
      `INSERT INTO reservations (user_id, parking_id, start_time, end_time, total_amount, payment_method, status, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, 'pending', NOW(), NOW())
       RETURNING *`,
      [userId, parking_id, start_time, end_time, total_amount, payment_method]
    );

    // Decrement available spots
    await query(
      'UPDATE parkings SET available_spots = available_spots - 1 WHERE id = $1',
      [parking_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create reservation', details: err.message });
  }
});

// Cancel a reservation
router.post('/:id/cancel', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const reservationId = req.params.id;

    // Check reservation exists and belongs to user
    const result = await query(
      'SELECT * FROM reservations WHERE id = $1 AND user_id = $2',
      [reservationId, userId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    const reservation = result.rows[0];
    if (reservation.status === 'cancelled') {
      return res.status(400).json({ error: 'Reservation already cancelled' });
    }

    // Cancel reservation
    await query(
      `UPDATE reservations SET status = 'cancelled', updated_at = NOW() WHERE id = $1`,
      [reservationId]
    );

    // Increment available spots
    await query(
      'UPDATE parkings SET available_spots = available_spots + 1 WHERE id = $1',
      [reservation.parking_id]
    );

    res.json({ message: 'Reservation cancelled' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to cancel reservation', details: err.message });
  }
});

// Extend a reservation (change end_time)
router.post('/:id/extend', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const reservationId = req.params.id;
    const { new_end_time } = req.body;

    // Check reservation exists and belongs to user
    const result = await query(
      'SELECT * FROM reservations WHERE id = $1 AND user_id = $2',
      [reservationId, userId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }

    // Update end_time
    await query(
      `UPDATE reservations SET end_time = $1, updated_at = NOW() WHERE id = $2`,
      [new_end_time, reservationId]
    );

    res.json({ message: 'Reservation extended' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to extend reservation', details: err.message });
  }
});

module.exports = router;