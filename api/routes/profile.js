const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController.js');
const authMiddleware = require('../middlewares/authMiddleware.js');

router.get('/', authMiddleware, profileController.getProfile);

module.exports = router;