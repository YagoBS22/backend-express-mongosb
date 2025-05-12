#!/bin/bash

echo "====== SCRIPT 02: LOGIN BEM-SUCEDIDO E SALVAR TOKEN ======"
echo ""

CREDENTIALS_FILE="temp_credentials.txt"
TOKEN_FILE="temp_jwt_token.txt"

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "ERRO: Arquivo de credenciais '$CREDENTIALS_FILE' não encontrado."
    echo "Por favor, execute o script 'register_success.sh' primeiro."
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
    echo ""
    exit 1
fi

USER_EMAIL=$(sed -n '1p' "$CREDENTIALS_FILE")
USER_PASSWORD=$(sed -n '2p' "$CREDENTIALS_FILE")

if [ -z "$USER_EMAIL" ] || [ -z "$USER_PASSWORD" ]; then
    echo "ERRO: Não foi possível ler email ou senha do arquivo '$CREDENTIALS_FILE'."
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
    echo ""
    exit 1
fi

echo "Tentando login com as credenciais de '$CREDENTIALS_FILE':"
echo "Email: $USER_EMAIL"
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
      if [ "$status_code" -eq 200 ]; then
        TOKEN_FROM_LOGIN=$(echo "$response_body" | jq -r .token)
        if [ -n "$TOKEN_FROM_LOGIN" ] && [ "$TOKEN_FROM_LOGIN" != "null" ]; then
          echo "$TOKEN_FROM_LOGIN" > "$TOKEN_FILE"
          echo ""
          echo "TOKEN JWT OBTIDO E SALVO EM: $TOKEN_FILE"
        else
          echo "AVISO: Token não encontrado na resposta, apesar do status 200."
        fi
      fi
    else
      echo "Corpo (texto simples/não-JSON):"; echo "$response_body";
    fi;
  else
    echo "Corpo: (vazio)";
  fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE: $test_title ---"; echo "";
}

BASE_URL_LOGIN="http://localhost:3000/auth/login"
DATA_LOGIN="{\"email\":\"$USER_EMAIL\",\"password\":\"$USER_PASSWORD\"}"

run_test "Login do Usuário Registrado" -X POST "$BASE_URL_LOGIN" -H "Content-Type: application/json" -d "$DATA_LOGIN"

echo "Próximo passo: Execute 'protected_valid.sh'"
echo "====== FIM DO SCRIPT 02 ======"
echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo ""