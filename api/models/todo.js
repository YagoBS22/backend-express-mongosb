// api/models/todo.js
import mongoose from 'mongoose';

const todoSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'O título da tarefa é obrigatório.'],
    trim: true,
    maxlength: [100, 'O título não pode exceder 100 caracteres.'],
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'A descrição não pode exceder 500 caracteres.'],
  },
  completed: {
    type: Boolean,
    default: false,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
}, {
  timestamps: true,
});

todoSchema.pre('save', function(next) {
  if (!this.isNew) {
    this.updatedAt = Date.now();
  }
  next();
});

const Todo = mongoose.models.Todo || mongoose.model('Todo', todoSchema);

export default Todo;