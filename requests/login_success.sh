#!/bin/bash

echo "====== SCRIPT DE LOGIN (Vercel): OBTER E SALVAR TOKEN JWT ======"
echo ""

# --- URL DO SEU DEPLOY NO VERCEL ---
VERCEL_APP_URL="https://backend-express-mongosb.vercel.app"
# --- FIM DA URL ---

CREDENTIALS_FILE="temp_credentials.txt"
TOKEN_FILE="temp_jwt_token.txt"

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "ERRO: Arquivo de credenciais '$CREDENTIALS_FILE' não encontrado."
    echo "Por favor, execute o script '01_register_and_save_credentials.sh' (versão Vercel) primeiro."
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo ""
    exit 1
fi

USER_EMAIL=$(sed -n '1p' "$CREDENTIALS_FILE")
USER_PASSWORD=$(sed -n '2p' "$CREDENTIALS_FILE")

if [ -z "$USER_EMAIL" ] || [ -z "$USER_PASSWORD" ]; then
    echo "ERRO: Não foi possível ler email ou senha do arquivo '$CREDENTIALS_FILE'."
    read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo ""
    exit 1
fi

echo "Tentando login com as credenciais de '$CREDENTIALS_FILE' via Vercel URL:"
echo "Email Lido: $USER_EMAIL"
echo ""

if ! command -v jq &> /dev/null; then FORMAT_JSON=false; else FORMAT_JSON=true; fi

run_test() {
  local test_title="$1"; shift; local curl_args=("$@");
  echo ""; echo "--- INÍCIO DO TESTE: $test_title ---";
  curl_output=$(curl -s "${curl_args[@]}" -w "\nHTTP_STATUS_CODE:%{http_code}");
  response_body=$(echo "$curl_output" | sed '$d'); status_code=$(echo "$curl_output" | tail -n1 | sed 's/HTTP_STATUS_CODE://');
  echo "--- Resposta do Servidor para '$test_title' ---";
  if [[ -n "$response_body" ]]; then
    if $FORMAT_JSON && [[ ("$response_body" == \{*\} || "$response_body" == \[*\]) ]]; then
      echo "Corpo (JSON formatado):"; echo "$response_body" | jq .;
      if [ "$status_code" -eq 200 ]; then
        TOKEN_FROM_LOGIN=$(echo "$response_body" | jq -r .token)
        if [ -n "$TOKEN_FROM_LOGIN" ] && [ "$TOKEN_FROM_LOGIN" != "null" ]; then
          echo "$TOKEN_FROM_LOGIN" > "$TOKEN_FILE"
          echo ""; echo ">>> TOKEN JWT OBTIDO E SALVO EM: $TOKEN_FILE <<<";
        else echo "ERRO: Token não encontrado na resposta (status 200)."; fi
      else echo "ERRO: Login falhou. Status Code: $status_code.";fi
    else echo "Corpo (texto simples/não-JSON):"; echo "$response_body"; if [ "$status_code" -ne 200 ]; then echo "ERRO: Login falhou. Status Code: $status_code.";fi;fi;
  else echo "Corpo: (vazio)"; echo "ERRO: Login falhou. Nenhuma resposta.";fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE: $test_title ---"; echo "";
}

BASE_URL_LOGIN="$VERCEL_APP_URL/auth/login" # Usa a variável VERCEL_APP_URL
DATA_LOGIN="{\"email\":\"$USER_EMAIL\",\"password\":\"$USER_PASSWORD\"}"

run_test "Login com Credenciais Salvas (Vercel)" -X POST "$BASE_URL_LOGIN" -H "Content-Type: application/json" -d "$DATA_LOGIN"

echo "====== FIM DO SCRIPT DE LOGIN (Vercel) ======"
echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo ""