import authMiddleware from '../middlewares/authMiddleware.js';

const handler = async (req, res) => {
  res.status(200).json({ message: 'Access granted to protected route!', user: req.user });
};

export default authMiddleware(handler);