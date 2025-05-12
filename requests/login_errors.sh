#!/bin/bash

echo "====== TESTES CONSOLIDADOS DE ERROS DE LOGIN ======"
echo ""

if ! command -v jq &> /dev/null; then
    FORMAT_JSON=false
    echo "AVISO: 'jq' não encontrado. A saída JSON não será formatada."
else
    FORMAT_JSON=true
fi

run_test() {
  local test_title="$1"; shift; local curl_args=("$@");
  echo ""; echo "--- INÍCIO DO TESTE: $test_title ---";
  curl_output=$(curl -s "${curl_args[@]}" -w "\nHTTP_STATUS_CODE:%{http_code}");
  response_body=$(echo "$curl_output" | sed '$d'); status_code=$(echo "$curl_output" | tail -n1 | sed 's/HTTP_STATUS_CODE://');
  echo "--- Resposta do Servidor para '$test_title' ---";
  if [[ -n "$response_body" ]]; then
    if $FORMAT_JSON && [[ "$response_body" =~ ^\{.*\} || "$response_body" =~ ^\[.*\] ]]; then
      echo "$response_body" | jq .;
    else
      echo "$response_body";
    fi;
  else
    echo "Corpo: (vazio)";
  fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE: $test_title ---"; echo ""; sleep 2;
}

BASE_URL_LOGIN="http://localhost:3000/auth/login"
BASE_URL_REGISTER="http://localhost:3000/auth/register"
TIMESTAMP=$(date +%s)

# Teste 1: E-mail não encontrado
TITLE_EMAIL_NOT_FOUND="Login: E-mail não cadastrado"
DATA_EMAIL_NOT_FOUND="{\"email\":\"naoexiste${TIMESTAMP}@exemplo.com\",\"password\":\"password123\"}"
run_test "$TITLE_EMAIL_NOT_FOUND" -X POST "$BASE_URL_LOGIN" -H "Content-Type: application/json" -d "$DATA_EMAIL_NOT_FOUND"

# Teste 2: Senha inválida (para e-mail existente)
TITLE_WRONG_PASSWORD="Login: Senha inválida para e-mail existente"
EXISTING_EMAIL_FOR_LOGIN_TEST="login.existente${TIMESTAMP}@exemplo.com"
CORRECT_PASSWORD="correctPassword123"
WRONG_PASSWORD_FOR_LOGIN="wrongPassword123"
DATA_REGISTER_FOR_LOGIN_TEST="{\"name\":\"Usuário Login Teste\",\"email\":\"$EXISTING_EMAIL_FOR_LOGIN_TEST\",\"password\":\"$CORRECT_PASSWORD\"}"
DATA_LOGIN_WRONG_PASSWORD="{\"email\":\"$EXISTING_EMAIL_FOR_LOGIN_TEST\",\"password\":\"$WRONG_PASSWORD_FOR_LOGIN\"}"
echo "Registrando usuário base ($EXISTING_EMAIL_FOR_LOGIN_TEST) para teste de senha inválida no login..."
curl -s -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_REGISTER_FOR_LOGIN_TEST" > /dev/null
run_test "$TITLE_WRONG_PASSWORD" -X POST "$BASE_URL_LOGIN" -H "Content-Type: application/json" -d "$DATA_LOGIN_WRONG_PASSWORD"

# Teste 3: E-mail inválido (formato) - O backend atual retorna "Invalid credentials"
TITLE_EMAIL_INVALID_FORMAT_LOGIN="Login: E-mail com formato inválido"
DATA_EMAIL_INVALID_FORMAT_LOGIN="{\"email\":\"emailcomformatoinvalido\",\"password\":\"password123\"}"
run_test "$TITLE_EMAIL_INVALID_FORMAT_LOGIN" -X POST "$BASE_URL_LOGIN" -H "Content-Type: application/json" -d "$DATA_EMAIL_INVALID_FORMAT_LOGIN"

# Teste 4: Requisição mal formatada (JSON inválido)
TITLE_MALFORMED_JSON_LOGIN="Login: JSON mal formado na requisição"
DATA_MALFORMED_JSON_LOGIN='{"email":"teste@exemplo.com", "password":"password123"' # Falta '}'
run_test "$TITLE_MALFORMED_JSON_LOGIN" -X POST "$BASE_URL_LOGIN" -H "Content-Type: application/json" -d "$DATA_MALFORMED_JSON_LOGIN"

echo "====== FIM DOS TESTES DE ERROS DE LOGIN ======"


echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo "" 