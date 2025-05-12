import express from 'express';
import profileController from '../controllers/profileController.js';
import authMiddleware from '../middlewares/authMiddleware.js';

const router = express.Router();
router.get('/', authMiddleware, profileController.getProfile);

export default router;