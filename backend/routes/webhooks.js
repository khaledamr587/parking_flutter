const express = require('express');
const router = express.Router();
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const db = require('../config/database');

// Stripe webhook endpoint
router.post('/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    // Verify the webhook signature
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    // Handle the event
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
      case 'payment_intent.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
      case 'charge.succeeded':
        await handleChargeSucceeded(event.data.object);
        break;
      case 'charge.failed':
        await handleChargeFailed(event.data.object);
        break;
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Error processing webhook:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
});

// Handle successful payment
async function handlePaymentSucceeded(paymentIntent) {
  try {
    const { reservation_id, user_id } = paymentIntent.metadata;
    
    if (reservation_id) {
      // Update reservation status
      await db.query(
        'UPDATE reservations SET status = $1, payment_status = $2, updated_at = NOW() WHERE id = $3',
        ['confirmed', 'paid', reservation_id]
      );

      // Create payment record
      await db.query(
        'INSERT INTO payments (reservation_id, user_id, amount, currency, payment_method, stripe_payment_intent_id, status, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())',
        [
          reservation_id,
          user_id,
          paymentIntent.amount / 100, // Convert from cents
          paymentIntent.currency,
          paymentIntent.payment_method_types[0] || 'card',
          paymentIntent.id,
          'succeeded'
        ]
      );

      console.log(`Payment succeeded for reservation ${reservation_id}`);
    }
  } catch (error) {
    console.error('Error handling payment succeeded:', error);
  }
}

// Handle failed payment
async function handlePaymentFailed(paymentIntent) {
  try {
    const { reservation_id } = paymentIntent.metadata;
    
    if (reservation_id) {
      // Update reservation status
      await db.query(
        'UPDATE reservations SET status = $1, payment_status = $2, updated_at = NOW() WHERE id = $3',
        ['cancelled', 'failed', reservation_id]
      );

      console.log(`Payment failed for reservation ${reservation_id}`);
    }
  } catch (error) {
    console.error('Error handling payment failed:', error);
  }
}

// Handle successful charge
async function handleChargeSucceeded(charge) {
  console.log('Charge succeeded:', charge.id);
}

// Handle failed charge
async function handleChargeFailed(charge) {
  console.log('Charge failed:', charge.id);
}

module.exports = router; 