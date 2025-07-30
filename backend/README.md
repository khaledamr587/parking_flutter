# Parking App Backend API

A complete Node.js/Express backend for the Flutter Parking App with PostgreSQL database integration.

## Features

- **Authentication**: JWT-based authentication with email/phone verification
- **User Management**: Registration, login, profile management
- **Parking Management**: CRUD operations for parking locations
- **Reservation System**: Booking, cancellation, extension of parking spots
- **Payment Integration**: Stripe payment processing
- **SMS/Email**: Twilio SMS and Nodemailer email services
- **Reviews & Ratings**: Parking review system
- **Admin Panel**: Admin routes for managing the system
- **Security**: Rate limiting, input validation, CORS protection

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Payment**: Stripe
- **SMS**: Twilio
- **Email**: Nodemailer
- **Validation**: Express-validator
- **Security**: Helmet, CORS, Rate limiting

## Prerequisites

- Node.js (v16 or higher)
- PostgreSQL database
- Twilio account (for SMS)
- Stripe account (for payments)
- Gmail account (for email)

## Installation

1. **Clone the repository and navigate to backend folder**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp env.example .env
   ```
   
   Edit `.env` file with your actual values:
   ```env
   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=khaled_db
   DB_USER=your_username
   DB_PASSWORD=your_password

   # Server Configuration
   PORT=3000
   NODE_ENV=development

   # JWT Configuration
   JWT_SECRET=your_jwt_secret_key_here_make_it_long_and_random
   JWT_EXPIRES_IN=7d

   # Twilio Configuration
   TWILIO_ACCOUNT_SID=your_twilio_account_sid
   TWILIO_AUTH_TOKEN=your_twilio_auth_token
   TWILIO_PHONE_NUMBER=your_twilio_phone_number

   # Stripe Configuration
   STRIPE_SECRET_KEY=your_stripe_secret_key
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret

   # Email Configuration
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASS=your_email_app_password
   ```

4. **Set up the database**
   ```bash
   # Run database migration
   npm run migrate
   
   # Seed with sample data
   npm run seed
   ```

5. **Start the server**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - Logout user
- `POST /api/auth/forgot-password` - Send password reset email
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/verify-email` - Verify email
- `POST /api/auth/send-phone-verification` - Send phone verification SMS
- `POST /api/auth/verify-phone` - Verify phone

### Parkings
- `GET /api/parkings/nearby` - Get nearby parkings
- `GET /api/parkings/search` - Search parkings
- `GET /api/parkings/:id` - Get parking details
- `POST /api/parkings/:id/reviews` - Add parking review
- `GET /api/parkings/:id/reviews` - Get parking reviews

### Reservations
- `GET /api/reservations` - Get user reservations
- `POST /api/reservations` - Create reservation
- `GET /api/reservations/:id` - Get reservation details
- `PUT /api/reservations/:id` - Update reservation
- `DELETE /api/reservations/:id` - Cancel reservation

### Payments
- `POST /api/payments/create-intent` - Create payment intent
- `POST /api/payments/confirm` - Confirm payment
- `GET /api/payments/history` - Get payment history

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `DELETE /api/users/profile` - Delete user account

### Admin (Protected)
- `GET /api/admin/dashboard` - Admin dashboard stats
- `GET /api/admin/parkings` - Manage parkings
- `GET /api/admin/users` - Manage users
- `GET /api/admin/reservations` - Manage reservations
- `GET /api/admin/disputes` - Manage disputes

## Database Schema

The backend creates the following tables:
- `users` - User accounts and profiles
- `parkings` - Parking locations and details
- `reservations` - Parking reservations
- `payments` - Payment transactions
- `verification_codes` - Email/phone verification codes
- `user_sessions` - JWT token management
- `parking_reviews` - User reviews and ratings
- `disputes` - User disputes and support tickets

## Environment Variables

### Required
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` - PostgreSQL connection
- `JWT_SECRET` - Secret key for JWT tokens
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER` - Twilio SMS
- `STRIPE_SECRET_KEY` - Stripe payment processing
- `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS` - Email service

### Optional
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `JWT_EXPIRES_IN` - JWT token expiration (default: 7d)
- `CORS_ORIGIN` - CORS allowed origins
- `RATE_LIMIT_WINDOW_MS` - Rate limiting window (default: 15 minutes)
- `RATE_LIMIT_MAX_REQUESTS` - Rate limiting max requests (default: 100)

## Deployment

### Local Development
```bash
npm run dev
```

### Production Deployment

1. **Set environment variables for production**
2. **Build and start**
   ```bash
   npm start
   ```

### Docker Deployment
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Cloud Deployment Options

#### Heroku
1. Create Heroku app
2. Add PostgreSQL addon
3. Set environment variables
4. Deploy with Git

#### Railway
1. Connect GitHub repository
2. Add PostgreSQL service
3. Set environment variables
4. Deploy automatically

#### DigitalOcean App Platform
1. Connect repository
2. Add PostgreSQL database
3. Set environment variables
4. Deploy

## Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## API Documentation

### Request Format
All requests should include:
- `Content-Type: application/json` header
- `Authorization: Bearer <token>` header (for protected routes)

### Response Format
```json
{
  "success": true,
  "data": {},
  "message": "Success message"
}
```

### Error Format
```json
{
  "success": false,
  "error": "Error message",
  "details": []
}
```

## Security Features

- **JWT Authentication** - Secure token-based authentication
- **Password Hashing** - bcrypt password encryption
- **Input Validation** - Express-validator for all inputs
- **Rate Limiting** - Prevent abuse
- **CORS Protection** - Cross-origin request security
- **Helmet** - Security headers
- **SQL Injection Protection** - Parameterized queries

## Monitoring

- **Health Check**: `GET /health`
- **Logging**: Morgan HTTP request logging
- **Error Handling**: Centralized error handling middleware

## Support

For issues and questions:
1. Check the logs for error details
2. Verify environment variables are set correctly
3. Ensure database connection is working
4. Check API endpoint documentation

## License

MIT License 