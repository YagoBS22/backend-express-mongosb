import { login, register } from '../services/authService.js';

const authController = {
  registerUser: async (req, res) => {
    try {
      const user = await register(req.body);
      res.status(201).json(user);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  loginUser: async (req, res) => {
    try {
      const token = await login(req.body);
      res.json({ token });
    } catch (err) {
      res.status(401).json({ error: err.message });
      }
   }
}

export default authController;