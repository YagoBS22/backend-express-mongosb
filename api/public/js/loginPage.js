document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');

    if (isLoggedIn()) {
        redirectToTodos();
    }

    if (loginForm) {
        loginForm.addEventListener('submit', async function (event) {
            event.preventDefault();
            clearMessage('message');

            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            try {
                const data = await makeApiCall('/auth/login', 'POST', { email, password }, false);
                if (data.token) {
                    setToken(data.token);
                    showMessage('Login bem-sucedido! Redirecionando...', 'success', 'message');
                    setTimeout(redirectToTodos, 1000);
                } else {
                    throw new Error(data.message || data.error || 'Token não recebido do servidor.');
                }
            } catch (error) {
                showMessage(`Erro no login: ${error.message}`, 'error', 'message');
            }
        });
    }
});