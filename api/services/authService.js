import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/user.js';
import connectDB from '../database/db.js';
import validator from 'validator';

export async function login(reqBody) {
  const { email, password } = reqBody;

  if (!email || !password) {
    let missingFields = [];
    if (!email) missingFields.push('email');
    if (!password) missingFields.push('password');
    throw new Error(`Login: Missing required fields: ${missingFields.join(', ')}`);
  }

  await connectDB();

  const user = await User.findOne({ email });
  if (!user) throw new Error('Invalid credentials');

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error('Invalid credentials');

  const token = jwt.sign(
    { id: user._id }, 
    process.env.JWT_SECRET, 
    { expiresIn: '1h' }
  );
  
  return token;
}

export async function register(reqBody) {
  const { name, email, password } = reqBody;
  
  if (!name || !email || !password) {
    let missingFields = [];
    if (!name) missingFields.push('name');
    if (!email) missingFields.push('email');
    if (!password) missingFields.push('password');
    throw new Error(`Registration: Missing required fields: ${missingFields.join(', ')}`);
  }
  
  await connectDB();
  
  const existingUser = await User.findOne({ email });
  if (existingUser) throw new Error('User already exists');

  if (!validator.isEmail(email)) {
    throw new Error('Invalid email format');
  }

  if (password.length < 8) {
    throw new Error('Passwords must be at least 8 characters long');
  }

  const newUser = new User({ 
    name,
    email, 
    password: password
  });

  await newUser.save();
  return newUser;
}