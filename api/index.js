import express from 'express';
import dotenv from 'dotenv';

import authRouter from './routes/auth.js';
import profileRouter from './routes/profile.js';
import protectedRouter from './routes/protected.js';
import todoRouter from './routes/todo.js';

dotenv.config();

const app = express();

app.use(express.json());

app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      error: "JSON mal formado na requisição"
    });
  }
  next();
});

app.use('/auth', authRouter);
app.use('/profile', profileRouter);
app.use('/protected', protectedRouter);
app.use('/todos', todoRouter);

app.use((req, res, next) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

app.use((err, req, res, next) => {
  res.status(err.status || err.statusCode || 500).json({
    error: 'Erro interno do servidor',
    message: err.message
  });
});

export default app;