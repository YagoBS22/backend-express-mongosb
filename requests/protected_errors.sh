#!/bin/bash

echo "====== TESTES CONSOLIDADOS DE ERROS NA ROTA PROTEGIDA (/protected) ======"
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

PROTECTED_URL="http://localhost:3000/protected"

# Teste 1: Tentativa de acesso sem token
TITLE_NO_TOKEN="Rota /protected: Acesso sem token"
run_test "$TITLE_NO_TOKEN" -X GET "$PROTECTED_URL"

# Teste 2: Tentativa de acesso com token inválido (malformado)
TITLE_INVALID_TOKEN="Rota /protected: Acesso com token inválido/malformado"
INVALID_TOKEN="um.token.claramente.invalido"
run_test "$TITLE_INVALID_TOKEN" -X GET "$PROTECTED_URL" -H "Authorization: Bearer $INVALID_TOKEN"

# Teste 3: Tentativa de acesso com token expirado
TITLE_EXPIRED_TOKEN="Rota /protected: Acesso com token expirado"
# SUBSTITUA O VALOR ABAIXO POR UM TOKEN JWT EXPIRADO
# Se não for um token expirado, este teste irá se comportar como "token inválido".
EXPIRED_TOKEN_VALUE="COLOQUE_SEU_TOKEN_EXPIRADO_AQUI_EXEMPLO.eyJleHAiOjE2MDk0NTkyMDB9.SIGNATURE"
if [[ "$EXPIRED_TOKEN_VALUE" == "COLOQUE_SEU_TOKEN_EXPIRADO_AQUI_EXEMPLO.eyJleHAiOjE2MDk0NTkyMDB9.SIGNATURE" ]]; then
  echo "AVISO: Teste de token expirado está usando um placeholder. Para testar corretamente, substitua EXPIRED_TOKEN_VALUE."
fi
run_test "$TITLE_EXPIRED_TOKEN" -X GET "$PROTECTED_URL" -H "Authorization: Bearer $EXPIRED_TOKEN_VALUE"

echo "====== FIM DOS TESTES DE ERROS NA ROTA PROTEGIDA ======"

echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo "" 