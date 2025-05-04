const { validationResult } = require('express-validator');
const authService = require('../services/authService');

exports.register = async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const user = await authService.register(req.body);
    res.status(201).json({ message: 'Usuário criado', user: { name: user.name, email: user.email } });
  } catch (err) {
    if (err.code === 11000) err.message = 'Email já cadastrado';
    err.status = err.status || 400;
    next(err);
  }
};

exports.login = async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.json(result);
  } catch (err) {
    next(err);
  }
};