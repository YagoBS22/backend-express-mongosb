document.addEventListener('DOMContentLoaded', () => {
    if (!isLoggedIn()) {
        redirectToLogin();
        return;
    }

    const todoListPendingEl = document.getElementById('todoListPending');
    const todoListCompletedEl = document.getElementById('todoListCompleted');
    const addTodoForm = document.getElementById('addTodoForm');
    const todoMessageEl = document.getElementById('todoMessage');
    const logoutButton = document.getElementById('logoutButton');
    const userInfoEl = document.getElementById('userInfo');

    async function fetchUserProfile() {
        try {
            const profileData = await makeApiCall('/profile', 'GET');
            if (profileData && profileData.user) {
                userInfoEl.textContent = `Bem-vindo(a), ${profileData.user.name || profileData.user.email}!`;
            } else {
                userInfoEl.textContent = 'Bem-vindo(a)! (Não foi possível carregar nome/email)';
            }
        } catch (error) {
            console.warn("Não foi possível buscar o perfil do usuário:", error.message);
            userInfoEl.textContent = 'Bem-vindo(a)!';
        }
    }

    async function fetchTodos() {
        clearMessage('todoMessage');
        try {
            const todos = await makeApiCall('/todos', 'GET');
            renderTodos(todos);
        } catch (error) {
            showMessage(`Erro ao carregar tarefas: ${error.message}`, 'error', 'todoMessage');
        }
    }

    function renderTodos(todos) {
        todoListPendingEl.innerHTML = '';
        todoListCompletedEl.innerHTML = '';

        let hasPending = false;
        let hasCompleted = false;

        if (!todos || todos.length === 0) {
            const li = document.createElement('li');
            li.textContent = 'Nenhuma tarefa encontrada.';
            todoListPendingEl.appendChild(li);
            return;
        }

        todos.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        todos.forEach(todo => {
            const li = document.createElement('li');
            li.className = todo.completed ? 'completed' : '';

            const titleSpan = document.createElement('span');
            titleSpan.className = 'todo-title';
            titleSpan.textContent = todo.title;
            li.appendChild(titleSpan);

            if (todo.description) {
                const descSpan = document.createElement('span');
                descSpan.textContent = ` - ${todo.description}`;
                descSpan.style.fontSize = '0.9em';
                descSpan.style.color = '#555';
                li.appendChild(descSpan);
            }

            const actionsDiv = document.createElement('div');
            actionsDiv.className = 'actions';

            const toggleButton = document.createElement('button');
            toggleButton.textContent = todo.completed ? 'Marcar Pendente' : 'Concluir';
            toggleButton.className = todo.completed ? 'secondary' : 'primary';
            toggleButton.onclick = () => toggleTodoStatus(todo._id, !todo.completed);

            const deleteButton = document.createElement('button');
            deleteButton.textContent = 'Excluir';
            deleteButton.className = 'danger';
            deleteButton.onclick = () => deleteTodoItem(todo._id);

            actionsDiv.appendChild(toggleButton);
            actionsDiv.appendChild(deleteButton);
            li.appendChild(actionsDiv);

            if (todo.completed) {
                todoListCompletedEl.appendChild(li);
                hasCompleted = true;
            } else {
                todoListPendingEl.appendChild(li);
                hasPending = true;
            }
        });

        if (!hasPending) {
            const li = document.createElement('li');
            li.textContent = 'Nenhuma tarefa pendente.';
            todoListPendingEl.appendChild(li);
        }
        if (!hasCompleted) {
            const li = document.createElement('li');
            li.textContent = 'Nenhuma tarefa concluída.';
            todoListCompletedEl.appendChild(li);
        }
    }

    if (addTodoForm) {
        addTodoForm.addEventListener('submit', async (event) => {
            event.preventDefault();
            clearMessage('todoMessage');
            const titleInput = document.getElementById('todoTitle');
            const descriptionInput = document.getElementById('todoDescription');
            const title = titleInput.value;
            const description = descriptionInput.value;

            if (!title.trim()) {
                showMessage('O título da tarefa é obrigatório.', 'error', 'todoMessage');
                return;
            }

            try {
                await makeApiCall('/todos', 'POST', { title, description });
                showMessage('Tarefa adicionada com sucesso!', 'success', 'todoMessage');
                addTodoForm.reset();
                fetchTodos();
            } catch (error) {
                showMessage(`Erro ao adicionar tarefa: ${error.message}`, 'error', 'todoMessage');
            }
        });
    }

    async function toggleTodoStatus(todoId, newStatus) {
        clearMessage('todoMessage');
        try {
            await makeApiCall(`/todos/${todoId}`, 'PATCH', { completed: newStatus });
            fetchTodos();
        } catch (error) {
            showMessage(`Erro ao atualizar status da tarefa: ${error.message}`, 'error', 'todoMessage');
        }
    }

    async function deleteTodoItem(todoId) {
        clearMessage('todoMessage');
        if (!confirm('Tem certeza que deseja excluir esta tarefa?')) return;
        try {
            await makeApiCall(`/todos/${todoId}`, 'DELETE');
            showMessage('Tarefa excluída com sucesso!', 'success', 'todoMessage');
            fetchTodos();
        } catch (error) {
            showMessage(`Erro ao excluir tarefa: ${error.message}`, 'error', 'todoMessage');
        }
    }

    if (logoutButton) {
        logoutButton.addEventListener('click', () => {
            removeToken();
            redirectToLogin();
        });
    }

    fetchUserProfile();
    fetchTodos();
});