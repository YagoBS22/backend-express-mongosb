document.addEventListener('DOMContentLoaded', () => {
    const registerForm = document.getElementById('registerForm');

    if (registerForm) {
        registerForm.addEventListener('submit', async function (event) {
            event.preventDefault();
            clearMessage('message');

            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            if (password.length < 8) {
                showMessage('A senha deve ter pelo menos 8 caracteres.', 'error', 'message');
                return;
            }

            try {
                const data = await makeApiCall('/auth/register', 'POST', { name, email, password }, false);
                showMessage('Registro bem-sucedido! Você pode fazer login agora.', 'success', 'message');
                registerForm.reset();
                setTimeout(() => {
                    window.location.href = 'login.html';
                }, 1000);
            } catch (error) {
                showMessage(`Erro no registro: ${error.message}`, 'error', 'message');
            }
        });
    }
});