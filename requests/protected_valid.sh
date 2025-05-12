#!/bin/bash

echo "====== SCRIPT 03: ACESSO À ROTA PROTEGIDA COM TOKEN SALVO ======"
echo ""

TOKEN_FILE="temp_jwt_token.txt"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "ERRO: Arquivo de token '$TOKEN_FILE' não encontrado."
    echo "Por favor, execute o script 'login_success.sh' primeiro."
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
    echo ""
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

if [ -z "$TOKEN" ]; then
    echo "ERRO: Token não encontrado ou vazio no arquivo '$TOKEN_FILE'."
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
    echo ""
    exit 1
fi

echo "Tentando acessar rota protegida com o token de '$TOKEN_FILE'."
echo "Token (início): ${TOKEN:0:15}..."
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

PROTECTED_URL="http://localhost:3000/protected"

run_test "Acesso à Rota /protected com Token Salvo" -X GET "$PROTECTED_URL" -H "Authorization: Bearer $TOKEN"

echo "====== FIM DO SCRIPT 03 ======"
echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo ""