#!/bin/bash

echo "====== TESTES CONSOLIDADOS DE ERROS NA ROTA PROTEGIDA ======"
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

PROTECTED_URL="$VERCEL_APP_URL/protected"

TITLE_NO_TOKEN="Rota /protected: Acesso sem token"
run_test "$TITLE_NO_TOKEN" -X GET "$PROTECTED_URL"

TITLE_INVALID_TOKEN="Rota /protected: Acesso com token inválido/malformado"
INVALID_TOKEN="um.token.claramente.invalido.vercel"
run_test "$TITLE_INVALID_TOKEN" -X GET "$PROTECTED_URL" -H "Authorization: Bearer $INVALID_TOKEN"

TITLE_EXPIRED_TOKEN="Rota /protected: Acesso com token expirado"
EXPIRED_TOKEN_VALUE="COLOQUE_SEU_TOKEN_EXPIRADO_AQUI.eyJleHAiOjE2MDk0NTkyMDB9.SIG_VERCEL"
if [[ "$EXPIRED_TOKEN_VALUE" == "COLOQUE_SEU_TOKEN_EXPIRADO_AQUI.eyJleHAiOjE2MDk0NTkyMDB9.SIG_VERCEL" ]]; then
  echo "AVISO: Teste de token expirado está usando um placeholder."
fi
run_test "$TITLE_EXPIRED_TOKEN" -X GET "$PROTECTED_URL" -H "Authorization: Bearer $EXPIRED_TOKEN_VALUE"

echo "====== FIM DOS TESTES DE ERROS NA ROTA PROTEGIDA ======"
read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && echo ""