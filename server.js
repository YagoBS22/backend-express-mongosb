require('dotenv').config();
const express = require('express');
const mongoose = require('./API/database/connection');
const morgan = require('morgan');
const authRoutes = require('./API/routes/authRoutes');
const protectedRoutes = require('./API/routes/protectedRoutes');

const app = express();
app.use(express.json());
app.use(morgan('dev'));

// Routes
app.use('/api', authRoutes);
app.use('/api', protectedRoutes);

// Root Route
app.get('/', (req, res) => {
  res.send('backend-express-mongodb tá on!');
});

// 404 Error Handling
app.use((req, res, next) => {
  res.status(404).json({ error: 'Route not found' });
});

// General Error Handling
app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({ error: err.message });
});

// .env Error Handling
if (!process.env.MONGO_URI || !process.env.JWT_SECRET) {
  console.error('Missing required environment variables');
  process.exit(1);
}

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

// Handle Unhandled Promise Rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
  process.exit(1);
});