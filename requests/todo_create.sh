#!/bin/bash

echo "====== SCRIPT CRIAR NOVA TAREFA ======"
echo ""

VERCEL_APP_URL="https://backend-express-mongosb.vercel.app"

if ! command -v jq &> /dev/null; then FORMAT_JSON=false; echo "AVISO: 'jq' não encontrado. JSON não será formatado."; else FORMAT_JSON=true; fi

# --- INÍCIO DA SEÇÃO DE LOGIN ---
CREDENTIALS_FILE="temp_credentials.txt"; TOKEN="";
echo "Tentando obter token JWT via login...";
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "ERRO: Arquivo de credenciais '$CREDENTIALS_FILE' não encontrado."
  echo "Por favor, execute '01_register_and_save_credentials.sh' (ou o nome correto do seu script de registro) primeiro."
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
# --- FIM DA SEÇÃO DE LOGIN ---

TODO_ID_FILE="temp_last_todo_id.txt"

# Helper function para a operação de To-Do
run_todo_test() {
  local test_title="$1"; shift; local curl_args=("$@");
  echo ""; echo "--- INÍCIO DO TESTE DE TO-DO: $test_title ---";
  curl_output=$(curl -s "${curl_args[@]}" -H "Authorization: Bearer $TOKEN" -w "\nHTTP_STATUS_CODE:%{http_code}");
  response_body=$(echo "$curl_output" | sed '$d'); status_code=$(echo "$curl_output" | tail -n1 | sed 's/HTTP_STATUS_CODE://');
  echo "--- Resposta do Servidor para '$test_title' ---";
  if [[ -n "$response_body" ]]; then
    if $FORMAT_JSON && [[ ("$response_body" == \{*\} || "$response_body" == \[*\]) ]]; then
      echo "Corpo (JSON formatado):"; echo "$response_body" | jq .;
      # Condição para salvar o ID da tarefa criada
      if [ "$status_code" -eq 201 ] && [ "$test_title" == "Criar Tarefa" ]; then # <<< TÍTULO ALTERADO AQUI
        CREATED_TODO_ID=$(echo "$response_body" | jq -r ._id)
        if [ -n "$CREATED_TODO_ID" ] && [ "$CREATED_TODO_ID" != "null" ]; then
          echo "$CREATED_TODO_ID" > "$TODO_ID_FILE"
          echo ""; echo ">>> ID DA TAREFA CRIADA ($CREATED_TODO_ID) SALVO EM: $TODO_ID_FILE <<<";
        fi
      fi
    else echo "Corpo (texto simples/não-JSON):"; echo "$response_body"; fi;
  else echo "Corpo: (vazio)"; fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE DE TO-DO: $test_title ---"; echo "";
}
# --- Fim da Helper Function ---

BASE_URL_TODOS="$VERCEL_APP_URL/todos"
TIMESTAMP=$(date +%s)
TODO_TITLE="Tarefa Vercel ${TIMESTAMP}" # O título da tarefa em si pode continuar com "Vercel"
TODO_DESCRIPTION="Descrição da tarefa via Vercel ${TIMESTAMP}"
DATA_CREATE_TODO="{\"title\":\"$TODO_TITLE\",\"description\":\"$TODO_DESCRIPTION\"}"

echo "Criando nova tarefa via Vercel: $TODO_TITLE"
# Chamada da função com o título alterado para "Criar Tarefa"
run_todo_test "Criar Tarefa" -X POST "$BASE_URL_TODOS" -H "Content-Type: application/json" -d "$DATA_CREATE_TODO" # <<< TÍTULO ALTERADO AQUI

echo "====== FIM DO SCRIPT CRIAR NOVA TAREFA (Vercel) ======"
read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo ""