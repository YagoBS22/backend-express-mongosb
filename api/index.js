const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./database/db');

dotenv.config();

const app = express();
app.use(express.json());

connectDB();

app.use('/auth', require('./routes/auth.js'));
app.use('/profile', require('./routes/profile.js'));
app.use('/protected', require('./routes/protected.js'));
module.exports = app;