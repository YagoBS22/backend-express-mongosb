const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const User = require('../models/user');

exports.register = async (userData) => {
  const user = new User(userData);
  return await user.save();
};

exports.login = async (email, password) => {
  const user = await User.findOne({ email }).select('+password');
  if (!user) throw { status: 401, message: 'Usuário não encontrado' };

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) throw { status: 401, message: 'Senha incorreta' };

  const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: '1h'
  });
  return { token };
};