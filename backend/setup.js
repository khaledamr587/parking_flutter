#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 Setting up Parking App Backend...\n');

// Check if Node.js version is compatible
const nodeVersion = process.version;
const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);

if (majorVersion < 16) {
  console.error('❌ Node.js version 16 or higher is required');
  console.error(`Current version: ${nodeVersion}`);
  process.exit(1);
}

console.log(`✅ Node.js version: ${nodeVersion}`);

// Check if .env file exists
const envPath = path.join(__dirname, '.env');
if (!fs.existsSync(envPath)) {
  console.log('📝 Creating .env file from template...');
  
  const envExamplePath = path.join(__dirname, 'env.example');
  if (fs.existsSync(envExamplePath)) {
    fs.copyFileSync(envExamplePath, envPath);
    console.log('✅ .env file created from template');
    console.log('⚠️  Please edit .env file with your actual configuration values');
  } else {
    console.error('❌ env.example file not found');
    process.exit(1);
  }
} else {
  console.log('✅ .env file already exists');
}

// Install dependencies
console.log('\n📦 Installing dependencies...');
try {
  execSync('npm install', { stdio: 'inherit' });
  console.log('✅ Dependencies installed successfully');
} catch (error) {
  console.error('❌ Failed to install dependencies');
  process.exit(1);
}

// Check if PostgreSQL is running
console.log('\n🗄️  Checking PostgreSQL connection...');
try {
  // This is a simple check - you'll need to configure your database connection
  console.log('⚠️  Please ensure PostgreSQL is running and your database is configured');
  console.log('   Update the .env file with your database credentials');
} catch (error) {
  console.error('❌ PostgreSQL connection failed');
  console.error('   Please check your database configuration');
}

console.log('\n🎯 Setup completed! Next steps:');
console.log('1. Edit .env file with your configuration');
console.log('2. Run: npm run migrate (to create database tables)');
console.log('3. Run: npm run seed (to add sample data)');
console.log('4. Run: npm run dev (to start development server)');
console.log('\n📚 For more information, see README.md');

console.log('\n🔑 Required API Keys:');
console.log('- Twilio Account SID and Auth Token');
console.log('- Twilio Phone Number');
console.log('- Stripe Secret Key');
console.log('- Gmail App Password (for email)');

console.log('\n🌐 Your API will be available at: http://localhost:3000/api');
console.log('🏥 Health check: http://localhost:3000/health'); 