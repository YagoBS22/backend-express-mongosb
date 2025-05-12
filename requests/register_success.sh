#!/bin/bash

echo "====== SCRIPT 01: REGISTRO BEM-SUCEDIDO E SALVAR CREDENCIAIS ======"
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
      echo "Corpo (JSON formatado):"; echo "$response_body" | jq .;
    else
      echo "Corpo (texto simples/não-JSON):"; echo "$response_body";
    fi;
  else
    echo "Corpo: (vazio)";
  fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE: $test_title ---"; echo "";
}

BASE_URL_REGISTER="http://localhost:3000/auth/register"
TIMESTAMP=$(date +%s)

NEW_USER_NAME="UsuárioFluxo${TIMESTAMP}"
NEW_USER_EMAIL="fluxo${TIMESTAMP}@exemplo.com"
NEW_USER_PASSWORD="passwordFluxo123"

CREDENTIALS_FILE="temp_credentials.txt"

echo "Registrando novo usuário:"
echo "Nome: $NEW_USER_NAME"
echo "Email: $NEW_USER_EMAIL"
echo "Senha: $NEW_USER_PASSWORD (será salva para o próximo script)"
echo ""

DATA_REGISTER="{\"name\":\"$NEW_USER_NAME\",\"email\":\"$NEW_USER_EMAIL\",\"password\":\"$NEW_USER_PASSWORD\"}"

run_test "Registro do Usuário para Fluxo" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_REGISTER"

echo "$NEW_USER_EMAIL" > "$CREDENTIALS_FILE"
echo "$NEW_USER_PASSWORD" >> "$CREDENTIALS_FILE"
echo ""
echo "Credenciais (email e senha) salvas em: $CREDENTIALS_FILE"
echo "Próximo passo: Execute 'login_success.sh'"

echo "====== FIM DO SCRIPT 01 ======"
echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo ""