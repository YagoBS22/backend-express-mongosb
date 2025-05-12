import express from 'express';
import * as todoController from '../controllers/todoController.js';
import authMiddleware from '../middlewares/authMiddleware.js';

const router = express.Router();

router.use(authMiddleware);

// POST /[recurso]: cria um novo item
router.post('/', (req, res) => todoController.createTodoItem(req, res));

// GET /[recurso]: lista todos os itens do usuário autenticado
router.get('/', (req, res) => todoController.getTodoItems(req, res));

// GET /[recurso]/:id: retorna detalhes de um item
router.get('/:id', (req, res) => todoController.getTodoItemById(req, res));

// PUT /[recurso]/:id: atualiza todos os dados de um item
router.put('/:id', (req, res) => todoController.updateTodoItem(req, res));

// PATCH /[recurso]/:id: atualiza parcialmente os dados de um item
router.patch('/:id', (req, res) => todoController.patchTodoItem(req, res));

// DELETE /[recurso]/:id: remove um item
router.delete('/:id', (req, res) => todoController.deleteTodoItem(req, res));

export default router;