require('dotenv').config();

const db = require('../config/database');

const createTables = async () => {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');

    // Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255),
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        phone VARCHAR(20),
        google_id VARCHAR(255),
        apple_id VARCHAR(255),
        is_email_verified BOOLEAN DEFAULT FALSE,
        is_phone_verified BOOLEAN DEFAULT FALSE,
        user_type VARCHAR(20) DEFAULT 'user' CHECK (user_type IN ('user', 'admin', 'owner')),
        profile_image VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Parkings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS parkings (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        address TEXT NOT NULL,
        latitude DECIMAL(10, 8) NOT NULL,
        longitude DECIMAL(11, 8) NOT NULL,
        total_spots INTEGER NOT NULL,
        available_spots INTEGER NOT NULL,
        hourly_rate DECIMAL(10, 2) NOT NULL,
        daily_rate DECIMAL(10, 2),
        currency VARCHAR(3) DEFAULT 'EUR',
        parking_type VARCHAR(50) DEFAULT 'public' CHECK (parking_type IN ('public', 'private', 'residential')),
        amenities TEXT[], -- Array of amenities like ['security', 'covered', 'electric_charging']
        operating_hours JSONB, -- Store as JSON: {"monday": {"open": "06:00", "close": "22:00"}, ...}
        contact_phone VARCHAR(20),
        contact_email VARCHAR(255),
        images TEXT[], -- Array of image URLs
        rating DECIMAL(3, 2) DEFAULT 0,
        total_ratings INTEGER DEFAULT 0,
        is_active BOOLEAN DEFAULT TRUE,
        owner_id INTEGER REFERENCES users(id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Reservations table
    await client.query(`
      CREATE TABLE IF NOT EXISTS reservations (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        parking_id INTEGER NOT NULL REFERENCES parkings(id) ON DELETE CASCADE,
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP NOT NULL,
        duration_hours INTEGER NOT NULL,
        total_amount DECIMAL(10, 2) NOT NULL,
        currency VARCHAR(3) DEFAULT 'EUR',
        status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled', 'expired')),
        payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
        payment_method VARCHAR(50),
        payment_intent_id VARCHAR(255),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Payments table
    await client.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        reservation_id INTEGER NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
        amount DECIMAL(10, 2) NOT NULL,
        currency VARCHAR(3) DEFAULT 'EUR',
        payment_method VARCHAR(50) NOT NULL,
        payment_intent_id VARCHAR(255),
        status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'succeeded', 'failed', 'cancelled', 'refunded')),
        stripe_payment_intent_id VARCHAR(255),
        transaction_id VARCHAR(255),
        receipt_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Verification codes table (for email/phone verification)
    await client.query(`
      CREATE TABLE IF NOT EXISTS verification_codes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        code VARCHAR(10) NOT NULL,
        type VARCHAR(20) NOT NULL CHECK (type IN ('email', 'phone', 'password_reset')),
        expires_at TIMESTAMP NOT NULL,
        is_used BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // User sessions table (for JWT token management)
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_sessions (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        token_hash VARCHAR(255) NOT NULL,
        device_info TEXT,
        ip_address INET,
        expires_at TIMESTAMP NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Parking reviews table
    await client.query(`
      CREATE TABLE IF NOT EXISTS parking_reviews (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        parking_id INTEGER NOT NULL REFERENCES parkings(id) ON DELETE CASCADE,
        reservation_id INTEGER REFERENCES reservations(id),
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, parking_id, reservation_id)
      )
    `);

    // Disputes table
    await client.query(`
      CREATE TABLE IF NOT EXISTS disputes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        reservation_id INTEGER REFERENCES reservations(id),
        parking_id INTEGER REFERENCES parkings(id),
        type VARCHAR(50) NOT NULL CHECK (type IN ('payment_issue', 'parking_issue', 'service_issue', 'other')),
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
        admin_response TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create indexes for better performance
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
      CREATE INDEX IF NOT EXISTS idx_users_apple_id ON users(apple_id);
      CREATE INDEX IF NOT EXISTS idx_parkings_location ON parkings(latitude, longitude);
      CREATE INDEX IF NOT EXISTS idx_parkings_owner ON parkings(owner_id);
      CREATE INDEX IF NOT EXISTS idx_reservations_user ON reservations(user_id);
      CREATE INDEX IF NOT EXISTS idx_reservations_parking ON reservations(parking_id);
      CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
      CREATE INDEX IF NOT EXISTS idx_reservations_dates ON reservations(start_time, end_time);
      CREATE INDEX IF NOT EXISTS idx_payments_reservation ON payments(reservation_id);
      CREATE INDEX IF NOT EXISTS idx_verification_codes_user ON verification_codes(user_id);
      CREATE INDEX IF NOT EXISTS idx_verification_codes_expires ON verification_codes(expires_at);
      CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id);
      CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(token_hash);
      CREATE INDEX IF NOT EXISTS idx_parking_reviews_parking ON parking_reviews(parking_id);
      CREATE INDEX IF NOT EXISTS idx_disputes_user ON disputes(user_id);
      CREATE INDEX IF NOT EXISTS idx_disputes_status ON disputes(status);
    `);

    await client.query('COMMIT');
    console.log('✅ Database tables created successfully');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error creating tables:', error);
    throw error;
  } finally {
    client.release();
  }
};

// Run migration
createTables()
  .then(() => {
    console.log('🎉 Database migration completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Migration failed:', error);
    process.exit(1);
  }); 