import mongoose from 'mongoose';

const todoSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Task title is required.'],
    trim: true,
    maxlength: [100, 'Taks title cannot exceed 100 characters.'],
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Task description cannot exceed 500 characters.'],
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

todoSchema.pre('save', function (next) {
  if (!this.isNew) {
    this.updatedAt = Date.now();
  }
  next();
});

const Todo = mongoose.models.Todo || mongoose.model('Todo', todoSchema);

export default Todo;