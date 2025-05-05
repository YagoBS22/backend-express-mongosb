import authMiddleware from '../middlewares/authMiddleware.js';

const handler = async (req, res) => {
  res.status(200).json({ user: req.user });
};

export default authMiddleware(handler);