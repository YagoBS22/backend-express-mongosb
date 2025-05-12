import Todo from '../models/todo.js';
import connectDB from '../database/db.js';

const checkOwnership = async (todoId, userId) => {
  const todo = await Todo.findById(todoId);
  if (!todo) {
    const error = new Error('Task not found.');
    error.statusCode = 404;
    throw error;
  }
  if (todo.user.toString() !== userId.toString()) {
    const error = new Error('Unauthorized access to this task.');
    error.statusCode = 403;
    throw error;
  }
  return todo;
};

export const createTodo = async (userId, todoData) => {
  await connectDB();
  const { title, description } = todoData;

  if (!title || title.trim() === '') {
    const error = new Error('Title is required.');
    error.statusCode = 400;
    throw error;
  }

  const newTodo = new Todo({
    title,
    description: description || '',
    user: userId,
  });
  await newTodo.save();
  console.log(`[TodoService] Tarefa criada: ${newTodo.title} (ID: ${newTodo._id}) pelo usuário ${userId}`);
  return newTodo;
};

export const getAllTodos = async (userId) => {
  await connectDB();
  const todos = await Todo.find({ user: userId }).sort({ createdAt: -1 });
  console.log(`[TodoService] Listando ${todos.length} tarefas para o usuário ${userId}`);
  return todos;
};

export const getTodoById = async (userId, todoId) => {
  await connectDB();
  const todo = await checkOwnership(todoId, userId);
  console.log(`[TodoService] Tarefa encontrada: ${todo.title} (ID: ${todo._id}) para o usuário ${userId}`);
  return todo;
};

export const updateTodo = async (userId, todoId, updateData) => {
  await connectDB();
  const todo = await checkOwnership(todoId, userId);

  const { title, description, completed } = updateData;

  if (typeof title === 'undefined' || typeof description === 'undefined' || typeof completed === 'undefined') {
      const error = new Error('For PUT, all fields (title, description, completed) are required.');
      error.statusCode = 400;
      throw error;
  }
   if (!title || title.trim() === '') {
    const error = new Error('Title is required.');
    error.statusCode = 400;
    throw error;
  }


  todo.title = title;
  todo.description = description;
  todo.completed = completed;

  await todo.save();
  console.log(`[TodoService] Tarefa atualizada (PUT): ${todo.title} (ID: ${todo._id}) pelo usuário ${userId}`);
  return todo;
};

export const patchTodo = async (userId, todoId, patchData) => {
  await connectDB();
  const todo = await checkOwnership(todoId, userId);

  if (typeof patchData.title !== 'undefined') {
    if (patchData.title.trim() === '') {
        const error = new Error('Title is required.');
        error.statusCode = 400;
        throw error;
    }
    todo.title = patchData.title;
  }
  if (typeof patchData.description !== 'undefined') {
    todo.description = patchData.description;
  }
  if (typeof patchData.completed !== 'undefined') {
    todo.completed = patchData.completed;
  }

  await todo.save();
  console.log(`[TodoService] Tarefa atualizada (PATCH): ${todo.title} (ID: ${todo._id}) pelo usuário ${userId}`);
  return todo;
};

export const deleteTodo = async (userId, todoId) => {
  await connectDB();
  const todo = await checkOwnership(todoId, userId);

  const deletedTodo = await Todo.findByIdAndDelete(todoId); 
  if (!deletedTodo) {
      const error = new Error('Task not found.');
      error.statusCode = 404;
      throw error;
  }
  console.log(`[TodoService] Tarefa deletada: ${deletedTodo.title} (ID: ${deletedTodo._id}) pelo usuário ${userId}`);
  return { message: 'Task deleted succesfully!' };
};