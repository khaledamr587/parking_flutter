const express = require('express');
const { body, query, validationResult } = require('express-validator');
const db = require('../config/database');
const { protect, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// @desc    Get nearby parkings
// @route   GET /api/parkings/nearby
// @access  Public
router.get('/nearby', [
  query('latitude').isFloat({ min: -90, max: 90 }),
  query('longitude').isFloat({ min: -180, max: 180 }),
  query('radius').optional().isFloat({ min: 0.1, max: 50 }),
  query('limit').optional().isInt({ min: 1, max: 100 })
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

    const { latitude, longitude, radius = 5, limit = 20 } = req.query;

    // Calculate distance using Haversine formula
    const result = await db.query(`
      SELECT 
        p.*,
        u.first_name as owner_first_name,
        u.last_name as owner_last_name,
        (
          6371 * acos(
            cos(radians($1)) * cos(radians(p.latitude)) * 
            cos(radians(p.longitude) - radians($2)) + 
            sin(radians($1)) * sin(radians(p.latitude))
          )
        ) AS distance
      FROM parkings p
      LEFT JOIN users u ON p.owner_id = u.id
      WHERE p.is_active = true
        AND (
          6371 * acos(
            cos(radians($1)) * cos(radians(p.latitude)) * 
            cos(radians(p.longitude) - radians($2)) + 
            sin(radians($1)) * sin(radians(p.latitude))
          )
        ) <= $3
      ORDER BY distance
      LIMIT $4
    `, [latitude, longitude, radius, limit]);

    const parkings = result.rows.map(parking => ({
      id: parking.id,
      name: parking.name,
      description: parking.description,
      address: parking.address,
      latitude: parking.latitude,
      longitude: parking.longitude,
      totalSpots: parking.total_spots,
      availableSpots: parking.available_spots,
      hourlyRate: parking.hourly_rate,
      dailyRate: parking.daily_rate,
      currency: parking.currency,
      parkingType: parking.parking_type,
      amenities: parking.amenities || [],
      operatingHours: parking.operating_hours,
      contactPhone: parking.contact_phone,
      contactEmail: parking.contact_email,
      images: parking.images || [],
      rating: parking.rating,
      totalRatings: parking.total_ratings,
      distance: Math.round(parking.distance * 1000), // Convert to meters
      owner: parking.owner_id ? {
        firstName: parking.owner_first_name,
        lastName: parking.owner_last_name
      } : null,
      createdAt: parking.created_at,
      updatedAt: parking.updated_at
    }));

    res.json({
      success: true,
      data: parkings,
      count: parkings.length
    });
  } catch (error) {
    console.error('Get nearby parkings error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Get parking by ID
// @route   GET /api/parkings/:id
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(`
      SELECT 
        p.*,
        u.first_name as owner_first_name,
        u.last_name as owner_last_name,
        u.email as owner_email,
        u.phone as owner_phone
      FROM parkings p
      LEFT JOIN users u ON p.owner_id = u.id
      WHERE p.id = $1 AND p.is_active = true
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Parking not found'
      });
    }

    const parking = result.rows[0];

    // Get reviews for this parking
    const reviewsResult = await db.query(`
      SELECT 
        pr.*,
        u.first_name,
        u.last_name
      FROM parking_reviews pr
      JOIN users u ON pr.user_id = u.id
      WHERE pr.parking_id = $1
      ORDER BY pr.created_at DESC
      LIMIT 10
    `, [id]);

    const parkingData = {
      id: parking.id,
      name: parking.name,
      description: parking.description,
      address: parking.address,
      latitude: parking.latitude,
      longitude: parking.longitude,
      totalSpots: parking.total_spots,
      availableSpots: parking.available_spots,
      hourlyRate: parking.hourly_rate,
      dailyRate: parking.daily_rate,
      currency: parking.currency,
      parkingType: parking.parking_type,
      amenities: parking.amenities || [],
      operatingHours: parking.operating_hours,
      contactPhone: parking.contact_phone,
      contactEmail: parking.contact_email,
      images: parking.images || [],
      rating: parking.rating,
      totalRatings: parking.total_ratings,
      owner: parking.owner_id ? {
        firstName: parking.owner_first_name,
        lastName: parking.owner_last_name,
        email: parking.owner_email,
        phone: parking.owner_phone
      } : null,
      reviews: reviewsResult.rows.map(review => ({
        id: review.id,
        rating: review.rating,
        comment: review.comment,
        userName: `${review.first_name} ${review.last_name}`,
        createdAt: review.created_at
      })),
      createdAt: parking.created_at,
      updatedAt: parking.updated_at
    };

    res.json({
      success: true,
      data: parkingData
    });
  } catch (error) {
    console.error('Get parking error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Search parkings
// @route   GET /api/parkings/search
// @access  Public
router.get('/search', [
  query('q').optional().notEmpty(),
  query('type').optional().isIn(['public', 'private', 'residential']),
  query('minPrice').optional().isFloat({ min: 0 }),
  query('maxPrice').optional().isFloat({ min: 0 }),
  query('amenities').optional().isArray(),
  query('latitude').optional().isFloat({ min: -90, max: 90 }),
  query('longitude').optional().isFloat({ min: -180, max: 180 }),
  query('radius').optional().isFloat({ min: 0.1, max: 50 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('page').optional().isInt({ min: 1 })
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

    const {
      q,
      type,
      minPrice,
      maxPrice,
      amenities,
      latitude,
      longitude,
      radius = 5,
      limit = 20,
      page = 1
    } = req.query;

    let whereConditions = ['p.is_active = true'];
    let queryParams = [];
    let paramIndex = 1;

    // Search by name or description
    if (q) {
      whereConditions.push(`(p.name ILIKE $${paramIndex} OR p.description ILIKE $${paramIndex})`);
      queryParams.push(`%${q}%`);
      paramIndex++;
    }

    // Filter by type
    if (type) {
      whereConditions.push(`p.parking_type = $${paramIndex}`);
      queryParams.push(type);
      paramIndex++;
    }

    // Filter by price range
    if (minPrice !== undefined) {
      whereConditions.push(`p.hourly_rate >= $${paramIndex}`);
      queryParams.push(minPrice);
      paramIndex++;
    }

    if (maxPrice !== undefined) {
      whereConditions.push(`p.hourly_rate <= $${paramIndex}`);
      queryParams.push(maxPrice);
      paramIndex++;
    }

    // Filter by amenities
    if (amenities && amenities.length > 0) {
      const amenityConditions = amenities.map(amenity => {
        whereConditions.push(`$${paramIndex} = ANY(p.amenities)`);
        queryParams.push(amenity);
        paramIndex++;
      });
    }

    const whereClause = whereConditions.join(' AND ');

    let query = `
      SELECT 
        p.*,
        u.first_name as owner_first_name,
        u.last_name as owner_last_name
    `;

    // Add distance calculation if coordinates provided
    if (latitude && longitude) {
      query += `,
        (
          6371 * acos(
            cos(radians($${paramIndex})) * cos(radians(p.latitude)) * 
            cos(radians(p.longitude) - radians($${paramIndex + 1})) + 
            sin(radians($${paramIndex})) * sin(radians(p.latitude))
          )
        ) AS distance
      `;
      queryParams.push(latitude, longitude);
      paramIndex += 2;
    }

    query += `
      FROM parkings p
      LEFT JOIN users u ON p.owner_id = u.id
      WHERE ${whereClause}
    `;

    // Add distance filter if coordinates provided
    if (latitude && longitude) {
      query += ` HAVING distance <= $${paramIndex}`;
      queryParams.push(radius);
      paramIndex++;
    }

    // Add ordering
    if (latitude && longitude) {
      query += ` ORDER BY distance`;
    } else {
      query += ` ORDER BY p.rating DESC, p.total_ratings DESC`;
    }

    // Add pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    queryParams.push(limit, offset);

    const result = await db.query(query, queryParams);

    // Get total count for pagination
    const countQuery = `
      SELECT COUNT(*) as total
      FROM parkings p
      WHERE ${whereClause}
    `;
    const countResult = await db.query(countQuery, queryParams.slice(0, -2));
    const total = parseInt(countResult.rows[0].total);

    const parkings = result.rows.map(parking => ({
      id: parking.id,
      name: parking.name,
      description: parking.description,
      address: parking.address,
      latitude: parking.latitude,
      longitude: parking.longitude,
      totalSpots: parking.total_spots,
      availableSpots: parking.available_spots,
      hourlyRate: parking.hourly_rate,
      dailyRate: parking.daily_rate,
      currency: parking.currency,
      parkingType: parking.parking_type,
      amenities: parking.amenities || [],
      operatingHours: parking.operating_hours,
      contactPhone: parking.contact_phone,
      contactEmail: parking.contact_email,
      images: parking.images || [],
      rating: parking.rating,
      totalRatings: parking.total_ratings,
      distance: parking.distance ? Math.round(parking.distance * 1000) : null,
      owner: parking.owner_id ? {
        firstName: parking.owner_first_name,
        lastName: parking.owner_last_name
      } : null,
      createdAt: parking.created_at,
      updatedAt: parking.updated_at
    }));

    res.json({
      success: true,
      data: parkings,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Search parkings error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Add parking review
// @route   POST /api/parkings/:id/reviews
// @access  Private
router.post('/:id/reviews', protect, [
  body('rating').isInt({ min: 1, max: 5 }),
  body('comment').optional().isLength({ max: 500 })
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

    const { id } = req.params;
    const { rating, comment } = req.body;

    // Check if parking exists
    const parkingResult = await db.query('SELECT id FROM parkings WHERE id = $1 AND is_active = true', [id]);
    if (parkingResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Parking not found'
      });
    }

    // Check if user has already reviewed this parking
    const existingReview = await db.query(
      'SELECT id FROM parking_reviews WHERE user_id = $1 AND parking_id = $2',
      [req.user.id, id]
    );

    if (existingReview.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'You have already reviewed this parking'
      });
    }

    // Add review
    await db.query(`
      INSERT INTO parking_reviews (user_id, parking_id, rating, comment)
      VALUES ($1, $2, $3, $4)
    `, [req.user.id, id, rating, comment]);

    // Update parking rating
    const avgRatingResult = await db.query(`
      SELECT AVG(rating) as avg_rating, COUNT(*) as total_reviews
      FROM parking_reviews
      WHERE parking_id = $1
    `, [id]);

    const avgRating = parseFloat(avgRatingResult.rows[0].avg_rating);
    const totalReviews = parseInt(avgRatingResult.rows[0].total_reviews);

    await db.query(`
      UPDATE parkings 
      SET rating = $1, total_ratings = $2
      WHERE id = $3
    `, [avgRating, totalReviews, id]);

    res.status(201).json({
      success: true,
      message: 'Review added successfully'
    });
  } catch (error) {
    console.error('Add review error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @desc    Get parking reviews
// @route   GET /api/parkings/:id/reviews
// @access  Public
router.get('/:id/reviews', [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 })
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

    const { id } = req.params;
    const { page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    // Check if parking exists
    const parkingResult = await db.query('SELECT id FROM parkings WHERE id = $1 AND is_active = true', [id]);
    if (parkingResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Parking not found'
      });
    }

    // Get reviews
    const result = await db.query(`
      SELECT 
        pr.*,
        u.first_name,
        u.last_name
      FROM parking_reviews pr
      JOIN users u ON pr.user_id = u.id
      WHERE pr.parking_id = $1
      ORDER BY pr.created_at DESC
      LIMIT $2 OFFSET $3
    `, [id, limit, offset]);

    // Get total count
    const countResult = await db.query(
      'SELECT COUNT(*) as total FROM parking_reviews WHERE parking_id = $1',
      [id]
    );
    const total = parseInt(countResult.rows[0].total);

    const reviews = result.rows.map(review => ({
      id: review.id,
      rating: review.rating,
      comment: review.comment,
      userName: `${review.first_name} ${review.last_name}`,
      createdAt: review.created_at
    }));

    res.json({
      success: true,
      data: reviews,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

module.exports = router; 