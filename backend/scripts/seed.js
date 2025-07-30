const db = require('../config/database');
const bcrypt = require('bcryptjs');

const seedData = async () => {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');

    // Create admin user
    const adminPasswordHash = await bcrypt.hash('admin123', 10);
    const adminResult = await client.query(`
      INSERT INTO users (email, password_hash, first_name, last_name, user_type, is_email_verified, is_phone_verified)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (email) DO NOTHING
      RETURNING id
    `, ['admin@parkingapp.com', adminPasswordHash, 'Admin', 'User', 'admin', true, true]);

    // Create sample users
    const userPasswordHash = await bcrypt.hash('user123', 10);
    const users = [
      ['john@example.com', userPasswordHash, 'John', 'Doe', 'user'],
      ['jane@example.com', userPasswordHash, 'Jane', 'Smith', 'user'],
      ['owner@parkingapp.com', userPasswordHash, 'Parking', 'Owner', 'owner']
    ];

    for (const [email, password, firstName, lastName, userType] of users) {
      await client.query(`
        INSERT INTO users (email, password_hash, first_name, last_name, user_type, is_email_verified, is_phone_verified)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        ON CONFLICT (email) DO NOTHING
      `, [email, password, firstName, lastName, userType, true, true]);
    }

    // Get owner user ID
    const ownerResult = await client.query('SELECT id FROM users WHERE email = $1', ['owner@parkingapp.com']);
    const ownerId = ownerResult.rows[0]?.id;

    // Create sample parkings
    const parkings = [
      {
        name: 'Central Parking',
        description: 'Convenient parking in the heart of the city',
        address: '123 Main Street, City Center',
        latitude: 48.8566,
        longitude: 2.3522,
        total_spots: 50,
        available_spots: 15,
        hourly_rate: 5.00,
        daily_rate: 25.00,
        parking_type: 'public',
        amenities: ['security', 'covered', 'electric_charging'],
        operating_hours: {
          monday: { open: '06:00', close: '22:00' },
          tuesday: { open: '06:00', close: '22:00' },
          wednesday: { open: '06:00', close: '22:00' },
          thursday: { open: '06:00', close: '22:00' },
          friday: { open: '06:00', close: '22:00' },
          saturday: { open: '08:00', close: '20:00' },
          sunday: { open: '08:00', close: '20:00' }
        },
        contact_phone: '+33123456789',
        contact_email: 'central@parking.com',
        images: ['https://example.com/parking1.jpg'],
        rating: 4.2,
        total_ratings: 45,
        owner_id: ownerId
      },
      {
        name: 'Downtown Parking',
        description: 'Modern parking facility with 24/7 access',
        address: '456 Business Ave, Downtown',
        latitude: 48.8606,
        longitude: 2.3376,
        total_spots: 30,
        available_spots: 8,
        hourly_rate: 7.00,
        daily_rate: 35.00,
        parking_type: 'public',
        amenities: ['security', 'covered', 'valet'],
        operating_hours: {
          monday: { open: '00:00', close: '23:59' },
          tuesday: { open: '00:00', close: '23:59' },
          wednesday: { open: '00:00', close: '23:59' },
          thursday: { open: '00:00', close: '23:59' },
          friday: { open: '00:00', close: '23:59' },
          saturday: { open: '00:00', close: '23:59' },
          sunday: { open: '00:00', close: '23:59' }
        },
        contact_phone: '+33123456790',
        contact_email: 'downtown@parking.com',
        images: ['https://example.com/parking2.jpg'],
        rating: 4.5,
        total_ratings: 32,
        owner_id: ownerId
      },
      {
        name: 'Shopping Center Parking',
        description: 'Free parking for shopping center customers',
        address: '789 Mall Road, Shopping District',
        latitude: 48.8526,
        longitude: 2.3666,
        total_spots: 100,
        available_spots: 25,
        hourly_rate: 3.00,
        daily_rate: 15.00,
        parking_type: 'public',
        amenities: ['security', 'free_wifi'],
        operating_hours: {
          monday: { open: '09:00', close: '21:00' },
          tuesday: { open: '09:00', close: '21:00' },
          wednesday: { open: '09:00', close: '21:00' },
          thursday: { open: '09:00', close: '21:00' },
          friday: { open: '09:00', close: '22:00' },
          saturday: { open: '09:00', close: '22:00' },
          sunday: { open: '10:00', close: '20:00' }
        },
        contact_phone: '+33123456791',
        contact_email: 'shopping@parking.com',
        images: ['https://example.com/parking3.jpg'],
        rating: 3.8,
        total_ratings: 67,
        owner_id: ownerId
      },
      {
        name: 'Airport Parking',
        description: 'Long-term parking for airport travelers',
        address: 'Airport Terminal 1, Aviation District',
        latitude: 48.8584,
        longitude: 2.2945,
        total_spots: 200,
        available_spots: 45,
        hourly_rate: 8.00,
        daily_rate: 40.00,
        parking_type: 'public',
        amenities: ['security', 'covered', 'shuttle_service'],
        operating_hours: {
          monday: { open: '00:00', close: '23:59' },
          tuesday: { open: '00:00', close: '23:59' },
          wednesday: { open: '00:00', close: '23:59' },
          thursday: { open: '00:00', close: '23:59' },
          friday: { open: '00:00', close: '23:59' },
          saturday: { open: '00:00', close: '23:59' },
          sunday: { open: '00:00', close: '23:59' }
        },
        contact_phone: '+33123456792',
        contact_email: 'airport@parking.com',
        images: ['https://example.com/parking4.jpg'],
        rating: 4.1,
        total_ratings: 89,
        owner_id: ownerId
      },
      {
        name: 'Residential Parking',
        description: 'Private parking for residents only',
        address: '321 Residential Blvd, Residential Area',
        latitude: 48.8647,
        longitude: 2.3490,
        total_spots: 20,
        available_spots: 5,
        hourly_rate: 4.00,
        daily_rate: 20.00,
        parking_type: 'residential',
        amenities: ['security', 'gated'],
        operating_hours: {
          monday: { open: '00:00', close: '23:59' },
          tuesday: { open: '00:00', close: '23:59' },
          wednesday: { open: '00:00', close: '23:59' },
          thursday: { open: '00:00', close: '23:59' },
          friday: { open: '00:00', close: '23:59' },
          saturday: { open: '00:00', close: '23:59' },
          sunday: { open: '00:00', close: '23:59' }
        },
        contact_phone: '+33123456793',
        contact_email: 'residential@parking.com',
        images: ['https://example.com/parking5.jpg'],
        rating: 4.3,
        total_ratings: 23,
        owner_id: ownerId
      }
    ];

    for (const parking of parkings) {
      await client.query(`
        INSERT INTO parkings (
          name, description, address, latitude, longitude, total_spots, available_spots,
          hourly_rate, daily_rate, parking_type, amenities, operating_hours,
          contact_phone, contact_email, images, rating, total_ratings, owner_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
        ON CONFLICT DO NOTHING
      `, [
        parking.name, parking.description, parking.address, parking.latitude, parking.longitude,
        parking.total_spots, parking.available_spots, parking.hourly_rate, parking.daily_rate,
        parking.parking_type, parking.amenities, JSON.stringify(parking.operating_hours),
        parking.contact_phone, parking.contact_email, parking.images, parking.rating,
        parking.total_ratings, parking.owner_id
      ]);
    }

    // Get user and parking IDs for sample reservations
    const userResult = await client.query('SELECT id FROM users WHERE email = $1', ['john@example.com']);
    const parkingResult = await client.query('SELECT id FROM parkings LIMIT 3');
    
    const userId = userResult.rows[0]?.id;
    const parkingIds = parkingResult.rows.map(row => row.id);

    if (userId && parkingIds.length > 0) {
      // Create sample reservations
      const now = new Date();
      const reservations = [
        {
          user_id: userId,
          parking_id: parkingIds[0],
          start_time: new Date(now.getTime() + 2 * 60 * 60 * 1000), // 2 hours from now
          end_time: new Date(now.getTime() + 4 * 60 * 60 * 1000), // 4 hours from now
          duration_hours: 2,
          total_amount: 10.00,
          status: 'confirmed',
          payment_status: 'paid'
        },
        {
          user_id: userId,
          parking_id: parkingIds[1],
          start_time: new Date(now.getTime() - 24 * 60 * 60 * 1000), // Yesterday
          end_time: new Date(now.getTime() - 22 * 60 * 60 * 1000), // Yesterday + 2 hours
          duration_hours: 2,
          total_amount: 14.00,
          status: 'completed',
          payment_status: 'paid'
        }
      ];

      for (const reservation of reservations) {
        const reservationResult = await client.query(`
          INSERT INTO reservations (
            user_id, parking_id, start_time, end_time, duration_hours,
            total_amount, status, payment_status
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          RETURNING id
        `, [
          reservation.user_id, reservation.parking_id, reservation.start_time,
          reservation.end_time, reservation.duration_hours, reservation.total_amount,
          reservation.status, reservation.payment_status
        ]);

        // Create corresponding payment record
        if (reservationResult.rows[0]) {
          await client.query(`
            INSERT INTO payments (
              reservation_id, amount, payment_method, status, stripe_payment_intent_id
            ) VALUES ($1, $2, $3, $4, $5)
          `, [
            reservationResult.rows[0].id,
            reservation.total_amount,
            'stripe',
            'succeeded',
            'pi_sample_' + Date.now()
          ]);
        }
      }
    }

    await client.query('COMMIT');
    console.log('✅ Sample data seeded successfully');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error seeding data:', error);
    throw error;
  } finally {
    client.release();
  }
};

// Run seed
seedData()
  .then(() => {
    console.log('🎉 Database seeding completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Seeding failed:', error);
    process.exit(1);
  }); 