#!/bin/bash

echo "====== SCRIPT REGISTRO BEM-SUCEDIDO E SALVAR CREDENCIAIS ======"
echo ""

VERCEL_APP_URL="https://backend-express-mongosb.vercel.app"

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
    if $FORMAT_JSON && [[ ("$response_body" == \{*\} || "$response_body" == \[*\]) ]]; then
      echo "Corpo (JSON formatado):"; echo "$response_body" | jq .;
    else
      echo "Corpo (texto simples/não-JSON):"; echo "$response_body";
    fi;
  else
    echo "Corpo: (vazio)";
  fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE: $test_title ---"; echo "";
}

BASE_URL_REGISTER="$VERCEL_APP_URL/auth/register"
TIMESTAMP=$(date +%s)

NEW_USER_NAME="UsuárioFluxoVercel${TIMESTAMP}"
NEW_USER_EMAIL="fluxovercel${TIMESTAMP}@exemplo.com"
NEW_USER_PASSWORD="passwordFluxo123"

CREDENTIALS_FILE="temp_credentials.txt"

echo "Registrando novo usuário via Vercel URL:"
echo "Nome: $NEW_USER_NAME"
echo "Email: $NEW_USER_EMAIL"
echo ""

DATA_REGISTER="{\"name\":\"$NEW_USER_NAME\",\"email\":\"$NEW_USER_EMAIL\",\"password\":\"$NEW_USER_PASSWORD\"}"

run_test "Registro do Usuário para Fluxo" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_REGISTER"

echo "$NEW_USER_EMAIL" > "$CREDENTIALS_FILE"
echo "$NEW_USER_PASSWORD" >> "$CREDENTIALS_FILE"
echo ""
echo "Credenciais (email e senha) salvas em: $CREDENTIALS_FILE"
echo "Próximo passo: Execute o script de login_success.sh"

echo "====== FIM DO SCRIPT ======"
echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo ""