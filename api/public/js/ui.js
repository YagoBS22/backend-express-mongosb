const loadingIndicator = document.getElementById('loadingIndicator');
function showLoading() {
    if (loadingIndicator) loadingIndicator.style.display = 'block';
}

function hideLoading() {
    if (loadingIndicator) loadingIndicator.style.display = 'none';
}

/**
 * @param {string} message
 * @param {string} type
 * @param {string} elementId
*/
function showMessage(message, type = 'info', elementId = 'message') {
    const messageEl = document.getElementById(elementId);
    if (messageEl) {
        messageEl.textContent = message;
        messageEl.className = `message ${type}`;
        messageEl.style.display = 'block';
    } else {
        console.warn(`Elemento de mensagem com ID '${elementId}' não encontrado.`);
    }
}

function clearMessage(elementId = 'message') {
    const messageEl = document.getElementById(elementId);
    if (messageEl) {
        messageEl.textContent = '';
        messageEl.style.display = 'none';
        messageEl.className = 'message';
    }
}