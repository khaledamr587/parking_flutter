const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { protect } = require('../middleware/auth');
const Stripe = require('stripe');
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

// Get all payments for the current user
router.get('/', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await query(
      `SELECT * FROM payments WHERE user_id = $1 ORDER BY created_at DESC`,
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch payments', details: err.message });
  }
});

// Create a payment intent (for Stripe)
router.post('/intent', protect, async (req, res) => {
  try {
    const { amount, currency = 'usd', reservation_id } = req.body;
    if (!amount || !reservation_id) {
      return res.status(400).json({ error: 'Amount and reservation_id are required' });
    }

    // Create a payment intent with Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe expects amount in cents
      currency,
      metadata: { reservation_id: reservation_id.toString(), user_id: req.user.id.toString() },
    });

    // Optionally, create a payment record in your DB (status: pending)
    await query(
      `INSERT INTO payments (user_id, reservation_id, amount, currency, status, payment_intent_id, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())`,
      [req.user.id, reservation_id, amount, currency, 'pending', paymentIntent.id]
    );

    res.json({ clientSecret: paymentIntent.client_secret, paymentIntentId: paymentIntent.id });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create payment intent', details: err.message });
  }
});

// Get payment status by payment intent ID
router.get('/status/:paymentIntentId', protect, async (req, res) => {
  try {
    const { paymentIntentId } = req.params;
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    res.json({ status: paymentIntent.status });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch payment status', details: err.message });
  }
});

module.exports = router;