const express = require('express');
const router = express.Router();
const protectedController = require('../controllers/protectedController.js');
const authMiddleware = require('../middlewares/authMiddleware.js');

router.get('/', authMiddleware, protectedController.accessProtected);

module.exports = router;