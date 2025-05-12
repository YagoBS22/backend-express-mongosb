import express from 'express';
import protectedController from '../controllers/protectedController.js';
import authMiddleware from '../middlewares/authMiddleware.js';

const router = express.Router();

router.get('/',
  authMiddleware,
  (req, res, next) => {
    return protectedController.accessProtected(req, res);
  }
);

export default router;