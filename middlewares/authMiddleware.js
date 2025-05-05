import jwt from 'jsonwebtoken';
import User from '../models/user.js';
import connectDB from '../utils/db.js';

export async function authenticateToken(req) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('No token provided');
  }

  const token = authHeader.split(' ')[1];
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  await connectDB();
  const user = await User.findById(decoded.id).select('-password');
  if (!user) throw new Error('User not found');

  return user;
}