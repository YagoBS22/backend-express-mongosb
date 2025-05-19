const API_BASE_URL = 'https://backend-express-mongosb.vercel.app/api';

function getToken() {
    return localStorage.getItem('authToken');
}

function setToken(token) {
    localStorage.setItem('authToken', token);
}

function removeToken() {
    localStorage.removeItem('authToken');
}

function isLoggedIn() {
    return !!getToken();
}

function redirectToLogin() {
    if (!window.location.pathname.endsWith('/login.html') && !window.location.pathname.endsWith('/register.html')) {
        console.log('Redirecionando para login...');
        window.location.href = 'login.html';
    }
}

function redirectToTodos() {
    window.location.href = 'todos.html';
}

/**
 * @param {string} endpoint
 * @param {string} method
 * @param {object|null} body
 * @param {boolean} requiresAuth
 * @returns {Promise<object>}
 * @throws {Error}
*/
async function makeApiCall(endpoint, method = 'GET', body = null, requiresAuth = true) {
    showLoading();
    const headers = {
        'Content-Type': 'application/json',
    };

    if (requiresAuth) {
        const token = getToken();
        if (!token) {
            hideLoading();
            console.error('Token não encontrado para rota autenticada:', endpoint);
            redirectToLogin();
            throw new Error('Não autenticado. Redirecionando para login.');
        }
        headers['Authorization'] = `Bearer ${token}`;
    }

    const config = {
        method: method,
        headers: headers,
    };

    if (body) {
        config.body = JSON.stringify(body);
    }

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, config);
        let responseData;
        const contentType = response.headers.get("content-type");
        if (contentType && contentType.indexOf("application/json") !== -1) {
            responseData = await response.json();
        } else {
            responseData = await response.text();
            if (!response.ok) {
                responseData = { error: responseData || `Erro HTTP: ${response.status}` };
            }
        }

        if (!response.ok) {
            const errorMessage = (typeof responseData === 'object' && responseData !== null)
                ? (responseData.error || responseData.message || `Erro HTTP: ${response.status}`)
                : (responseData || `Erro HTTP: ${response.status}`);
            if (requiresAuth && (response.status === 401 || response.status === 403)) {
                console.error('Erro de autenticação/autorização:', errorMessage);
                removeToken();
                redirectToLogin();
                throw new Error('Sessão inválida ou expirada. Por favor, faça login novamente.');
            }
            throw new Error(errorMessage);
        }
        return responseData;
    } catch (error) {
        console.error(`Falha na chamada API para ${endpoint}:`, error.message);
        throw error;
    } finally {
        hideLoading();
    }
}