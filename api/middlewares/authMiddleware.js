import jwt from 'jsonwebtoken';
import User from '../models/user.js';
import connectDB from '../database/db.js';

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    await connectDB();
    const user = await User.findById(decoded.id).select('-password');

    if (!user) {
      return res.status(401).json({ message: 'User associated with token not found.' });
    }

    req.user = user;
    next();

  } catch (err) {
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({ message: 'Invalid token.', type: err.name });
    } else if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired.', type: err.name });
    }

    return res.status(500).json({ message: 'Internal server error during authentication.' });
  }
};

export default authMiddleware;