import * as todoService from '../services/todoService.js';

export const createTodoItem = async (req, res) => {
  try {
    const todo = await todoService.createTodo(req.user.id, req.body);
    res.status(201).json(todo);
  } catch (err) {
    console.error('[TodoController] Erro ao criar tarefa:', err.message);
    res.status(err.statusCode || 400).json({ error: err.message });
  }
};

export const getTodoItems = async (req, res) => {
  try {
    const todos = await todoService.getAllTodos(req.user.id);
    res.status(200).json(todos);
  } catch (err) {
    console.error('[TodoController] Erro ao listar tarefas:', err.message);
    res.status(err.statusCode || 500).json({ error: err.message });
  }
};

export const getTodoItemById = async (req, res) => {
  try {
    const todo = await todoService.getTodoById(req.user.id, req.params.id);
    res.status(200).json(todo);
  } catch (err) {
    console.error(`[TodoController] Erro ao buscar tarefa ${req.params.id}:`, err.message);
    res.status(err.statusCode || 404).json({ error: err.message });
  }
};

export const updateTodoItem = async (req, res) => {
  try {
    const todo = await todoService.updateTodo(req.user.id, req.params.id, req.body);
    res.status(200).json(todo);
  } catch (err) {
    console.error(`[TodoController] Erro ao atualizar (PUT) tarefa ${req.params.id}:`, err.message);
    res.status(err.statusCode || 400).json({ error: err.message });
  }
};

export const patchTodoItem = async (req, res) => {
  try {
    const todo = await todoService.patchTodo(req.user.id, req.params.id, req.body);
    res.status(200).json(todo);
  } catch (err) {
    console.error(`[TodoController] Erro ao atualizar (PATCH) tarefa ${req.params.id}:`, err.message);
    res.status(err.statusCode || 400).json({ error: err.message });
  }
};

export const deleteTodoItem = async (req, res) => {
  try {
    const result = await todoService.deleteTodo(req.user.id, req.params.id);
    res.status(200).json(result);
  } catch (err) {
    console.error(`[TodoController] Erro ao deletar tarefa ${req.params.id}:`, err.message);
    res.status(err.statusCode || 404).json({ error: err.message });
  }
};