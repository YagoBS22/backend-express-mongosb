#!/bin/bash

echo "====== TESTES CONSOLIDADOS DE ERROS DE REGISTRO (Vercel) ======"
echo ""

VERCEL_APP_URL="https://backend-express-mongosb.vercel.app"

if ! command -v jq &> /dev/null; then FORMAT_JSON=false; echo "AVISO: 'jq' não."; else FORMAT_JSON=true; fi

run_test() {
  local test_title="$1"; shift; local curl_args=("$@");
  echo ""; echo "--- INÍCIO DO TESTE: $test_title ---";
  curl_output=$(curl -s "${curl_args[@]}" -w "\nHTTP_STATUS_CODE:%{http_code}");
  response_body=$(echo "$curl_output" | sed '$d'); status_code=$(echo "$curl_output" | tail -n1 | sed 's/HTTP_STATUS_CODE://');
  echo "--- Resposta do Servidor para '$test_title' ---";
  if [[ -n "$response_body" ]]; then
    if $FORMAT_JSON && [[ ("$response_body" == \{*\} || "$response_body" == \[*\]) ]]; then
      echo "Corpo (JSON formatado):"; echo "$response_body" | jq .;
    else echo "Corpo (texto simples/não-JSON):"; echo "$response_body"; fi;
  else echo "Corpo: (vazio)"; fi;
  echo "Status Code: $status_code"; echo "--- FIM DO TESTE: $test_title ---"; echo ""; sleep 2;
}

BASE_URL_REGISTER="$VERCEL_APP_URL/auth/register"
TIMESTAMP=$(date +%s)

TITLE_MISSING_FIELD="Registro (Vercel): Campo 'password' faltando"
DATA_MISSING_FIELD="{\"name\":\"Usuário Sem Senha\",\"email\":\"semsenha${TIMESTAMP}v@exemplo.com\"}"
run_test "$TITLE_MISSING_FIELD" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_MISSING_FIELD"

TITLE_EMAIL_REPEATED="Registro (Vercel): E-mail repetido"
REPEATED_EMAIL="repetidovercel${TIMESTAMP}@exemplo.com"
DATA_REPEATED_1="{\"name\":\"Usuário Original Vercel\",\"email\":\"$REPEATED_EMAIL\",\"password\":\"password123\"}"
DATA_REPEATED_2="{\"name\":\"Outro Usuário Vercel\",\"email\":\"$REPEATED_EMAIL\",\"password\":\"password456\"}"
echo "Registrando usuário base para teste de e-mail repetido ($REPEATED_EMAIL) via Vercel..."
curl -s -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_REPEATED_1" > /dev/null
run_test "$TITLE_EMAIL_REPEATED" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_REPEATED_2"

TITLE_PASSWORD_SHORT="Registro (Vercel): Senha inválida (curta demais)"
DATA_PASSWORD_SHORT="{\"name\":\"Usuário Senha Curta Vercel\",\"email\":\"curtav${TIMESTAMP}@exemplo.com\",\"password\":\"123\"}"
run_test "$TITLE_PASSWORD_SHORT" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_PASSWORD_SHORT"

TITLE_EMAIL_INVALID_FORMAT="Registro (Vercel): E-mail com formato inválido"
DATA_EMAIL_INVALID_FORMAT="{\"name\":\"Usuário Email Ruim Vercel\",\"email\":\"emailsemformatov\",\"password\":\"password123\"}"
run_test "$TITLE_EMAIL_INVALID_FORMAT" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_EMAIL_INVALID_FORMAT"

TITLE_MALFORMED_JSON="Registro (Vercel): JSON mal formado na requisição"
DATA_MALFORMED_JSON='{"name":"Teste Malformado Vercel", "email":"malformadov@exemplo.com", "password":"password123"'
run_test "$TITLE_MALFORMED_JSON" -X POST "$BASE_URL_REGISTER" -H "Content-Type: application/json" -d "$DATA_MALFORMED_JSON"

echo "====== FIM DOS TESTES DE ERROS DE REGISTRO (Vercel) ======"
read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo ""