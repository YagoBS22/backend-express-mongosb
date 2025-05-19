// api/index.js (Adicionando todoRouter)
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import authRouter from './routes/auth.js';
import profileRouter from './routes/profile.js';
import protectedRouter from './routes/protected.js';
import todoRouter from './routes/todo.js'; // <--- ADICIONE ESTA IMPORTAÇÃO

import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
const app = express();
// Atualize a mensagem de log
console.log('Express app inicializado (com auth, profile, protected, todo).');

// Configuração do CORS (mantenha como estava)
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:5173',
  'https://backend-express-mongosb.vercel.app'
];
const corsOptions = {
  origin: function (origin, callback) {
    if (!process.env.VERCEL_ENV && !origin) {
        return callback(null, true);
    }
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      console.warn(`CORS: Requisição bloqueada da origem: ${origin}`);
      callback(new Error('Não permitido pelo CORS'));
    }
  },
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));
app.use(express.json());

app.use('/api', express.static(path.join(__dirname, 'public')));

// Rota de status da API
app.get('/api/', (req, res) => {
  console.log(`Rota /api/ (status) acessada! req.path: ${req.path}`);
  res.status(200).json({ message: 'Rota /api/ (status) funcionando!' });
});

// Montar roteadores
app.use('/api/auth', authRouter);
app.use('/api/profile', profileRouter);
app.use('/api/protected', protectedRouter);
app.use('/api/todos', todoRouter); // <--- ADICIONE ESTA LINHA

// Handler 404 (ajuste a mensagem de log se quiser)
app.use((req, res, next) => {
  console.log(`[404 com todoRouter] Rota não encontrada: ${req.method} ${req.originalUrl}, path visto: ${req.path}`);
  res.status(404).json({
    error: `NÃO ENCONTRADO (com todoRouter): ${req.method} ${req.path}`,
    originalUrl: req.originalUrl
  });
});

// Handler de erro global (ajuste a mensagem de log se quiser)
app.use((err, req, res, next) => {
  console.error('[ERRO com todoRouter]', err.message, err.stack ? err.stack.substring(0, 200) + "..." : "");
  if (err.message && err.message.includes("Missing parameter name")) {
      console.error(">>> ERRO DE PARÂMETRO DE ROTA DETECTADO <<<");
  }
  res.status(500).json({ error: 'Erro interno do servidor (com todoRouter)', message: err.message });
});

export default app;