document.addEventListener('DOMContentLoaded', () => {
    if (!isLoggedIn()) {
        redirectToLogin();
        return;
    }
    const protectedDataEl = document.getElementById('protectedData');
    const logoutButton = document.getElementById('logoutButton');

    async function fetchProtectedData() {
        clearMessage('message');
        try {
            const data = await makeApiCall('/protected', 'GET');

            if (typeof data === 'string') {
                protectedDataEl.textContent = data;
            } else if (typeof data === 'object') {
                protectedDataEl.innerHTML = `<pre>${JSON.stringify(data, null, 2)}</pre>`;
            } else {
                protectedDataEl.textContent = 'Dados recebidos, mas formato inesperado.';
            }
            showMessage('Dados protegidos carregados com sucesso!', 'success', 'message');

        } catch (error) {
            showMessage(`Erro ao carregar dados protegidos: ${error.message}`, 'error', 'message');
            protectedDataEl.textContent = 'Falha ao carregar dados.';
        }
    }

    if (logoutButton) {
        logoutButton.addEventListener('click', () => {
            removeToken();
            redirectToLogin();
        });
    }

    fetchProtectedData();
});