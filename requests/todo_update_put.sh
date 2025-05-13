#!/bin/bash

echo "====== SCRIPT ATUALIZAR TAREFA (PUT) ======"
echo ""

VERCEL_APP_URL="https://backend-express-mongosb.vercel.app"

if ! command -v jq &> /dev/null; then FORMAT_JSON=false; echo "AVISO: 'jq' não encontrado. JSON não será formatado."; else FORMAT_JSON=true; fi

CREDENTIALS_FILE="temp_credentials.txt"; TOKEN="";
echo "Tentando obter token JWT via login...";
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "ERRO: Arquivo de credenciais '$CREDENTIALS_FILE' não encontrado."
  echo "Por favor, execute 'register_success.sh' (versão Vercel) primeiro."
  read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo "" && exit 1
fi
USER_EMAIL=$(sed -n '1p' "$CREDENTIALS_FILE"); USER_PASSWORD=$(sed -n '2p' "$CREDENTIALS_FILE");
if [ -z "$USER_EMAIL" ] || [ -z "$USER_PASSWORD" ]; then
  echo "ERRO: Não foi possível ler email/senha de '$CREDENTIALS_FILE'."
  read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo "" && exit 1
fi
echo "Fazendo login com Email: $USER_EMAIL para obter token...";
LOGIN_URL="$VERCEL_APP_URL/auth/login";
LOGIN_DATA="{\"email\":\"$USER_EMAIL\",\"password\":\"$USER_PASSWORD\"}";
login_response_output=$(curl -s -X POST "$LOGIN_URL" -H "Content-Type: application/json" -d "$LOGIN_DATA" -w "\nHTTP_STATUS_CODE:%{http_code}");
login_response_body=$(echo "$login_response_output" | sed '$d');
login_status_code=$(echo "$login_response_output" | tail -n1 | sed 's/HTTP_STATUS_CODE://');

if [ "$login_status_code" -eq 200 ]; then
  if $FORMAT_JSON; then
    TOKEN=$(echo "$login_response_body" | jq -r .token)
  else
    TOKEN=$(echo "$login_response_body" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
  fi
  if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    echo "Login bem-sucedido. Token JWT obtido."
  else
    echo "ERRO: Login SUCESSO (200) mas token não encontrado na resposta."
    if $FORMAT_JSON; then echo "$login_response_body" | jq .; else echo "$login_response_body"; fi;
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo "" && exit 1;
  fi
else
  echo "ERRO: Falha no login para obter token. Status: $login_status_code"
  if $FORMAT_JSON; then echo "$login_response_body" | jq .; else echo "$login_response_body"; fi;
  read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo "" && exit 1;
fi
echo "--- FIM DA SEÇÃO DE LOGIN ---"; echo ""

TODO_ID_FILE="temp_last_todo_id.txt"
if [ ! -f "$TODO_ID_FILE" ]; then
  echo "ERRO: Arquivo de ID da tarefa '$TODO_ID_FILE' não encontrado. Crie uma tarefa primeiro."
  read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo "" && exit 1;
fi
TODO_ID=$(cat "$TODO_ID_FILE")
if [ -z "$TODO_ID" ]; then
  echo "ERRO: ID da tarefa vazio em '$TODO_ID_FILE'."
  read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo "" && exit 1;
fi

run_todo_test() {
  local test_title="$1"; shift; local curl_args=("$@");
  echo ""; echo "--- INÍCIO DO TESTE DE TO-DO: $test_title ---";
  curl_output=$(curl -s "${curl_args[@]}" -H "Authorization: Bearer $TOKEN" -w "\nHTTP_STATUS_CODE:%{http_code}");
  response_body=$(echo "$curl_output" | sed '$d'); status_code=$(echo "$curl_output" | tail -n1 | sed 's/HTTP_STATUS_CODE://');
  echo "--- Resposta do Servidor para '$test_title' ---";
  if [[ -n "$response_body" ]]; then
    if $FORMAT_JSON && [[ ("$response_body" == \{*\} || "$response_body" == \[*\]) ]]; then
      echo "Corpo (JSON formatado):"; echo "$response_body" | jq .;
    else echo "Corpo (texto simples/não-JSON):"; echo "$response_body"; fi;
  else echo "Corpo: (vazio)"; fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE DE TO-DO: $test_title ---"; echo "";
}

BASE_URL_TODOS="$VERCEL_APP_URL/todos"
TIMESTAMP_UPDATE=$(date +%s)
UPDATED_TITLE="Tarefa Completamente Renovada PUT via Vercel ${TIMESTAMP_UPDATE}"
UPDATED_DESCRIPTION="Esta é a nova descrição total da tarefa, atualizada via PUT para Vercel."
UPDATED_COMPLETED=true
DATA_UPDATE_TODO="{\"title\":\"$UPDATED_TITLE\",\"description\":\"$UPDATED_DESCRIPTION\",\"completed\":$UPDATED_COMPLETED}"

echo "Atualizando (PUT) tarefa com ID: $TODO_ID via Vercel URL"
echo "Novos Dados: $DATA_UPDATE_TODO"
run_todo_test "Atualizar Tarefa (PUT Vercel)" -X PUT "$BASE_URL_TODOS/$TODO_ID" \
  -H "Content-Type: application/json" \
  -d "$DATA_UPDATE_TODO"

echo "====== FIM DO SCRIPT TODO 04 (Vercel) ======"
read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo ""