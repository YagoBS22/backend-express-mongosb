#!/bin/bash

echo "====== TESTES CONSOLIDADOS DE ERROS DE REGISTRO ======"
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

BASE_URL="http://localhost:3000/auth/register"
TIMESTAMP=$(date +%s)

# Teste 1: Campo faltando (ex: senha)
TITLE_MISSING_FIELD="Registro: Campo 'password' faltando"
DATA_MISSING_FIELD="{\"name\":\"Usuário Sem Senha\",\"email\":\"semsenha${TIMESTAMP}@exemplo.com\"}"
run_test "$TITLE_MISSING_FIELD" -X POST "$BASE_URL" -H "Content-Type: application/json" -d "$DATA_MISSING_FIELD"

# Teste 2: E-mail repetido
TITLE_EMAIL_REPEATED="Registro: E-mail repetido"
REPEATED_EMAIL="repetido${TIMESTAMP}@exemplo.com"
DATA_REPEATED_1="{\"name\":\"Usuário Original\",\"email\":\"$REPEATED_EMAIL\",\"password\":\"password123\"}"
DATA_REPEATED_2="{\"name\":\"Outro Usuário\",\"email\":\"$REPEATED_EMAIL\",\"password\":\"password456\"}"
echo "Registrando usuário base para teste de e-mail repetido ($REPEATED_EMAIL)..."
curl -s -X POST "$BASE_URL" -H "Content-Type: application/json" -d "$DATA_REPEATED_1" > /dev/null # Registra o primeiro
run_test "$TITLE_EMAIL_REPEATED" -X POST "$BASE_URL" -H "Content-Type: application/json" -d "$DATA_REPEATED_2"

# Teste 3: Senha inválida (curta)
TITLE_PASSWORD_SHORT="Registro: Senha inválida (curta demais)"
DATA_PASSWORD_SHORT="{\"name\":\"Usuário Senha Curta\",\"email\":\"curta${TIMESTAMP}@exemplo.com\",\"password\":\"123\"}"
run_test "$TITLE_PASSWORD_SHORT" -X POST "$BASE_URL" -H "Content-Type: application/json" -d "$DATA_PASSWORD_SHORT"

# Teste 4: E-mail inválido (formato)
TITLE_EMAIL_INVALID_FORMAT="Registro: E-mail com formato inválido"
DATA_EMAIL_INVALID_FORMAT="{\"name\":\"Usuário Email Ruim\",\"email\":\"emailsemformato\",\"password\":\"password123\"}"
run_test "$TITLE_EMAIL_INVALID_FORMAT" -X POST "$BASE_URL" -H "Content-Type: application/json" -d "$DATA_EMAIL_INVALID_FORMAT"

# Teste 5: Requisição mal formatada (JSON inválido)
TITLE_MALFORMED_JSON="Registro: JSON mal formado na requisição"
DATA_MALFORMED_JSON='{"name":"Teste Malformado", "email":"malformado@exemplo.com", "password":"password123"' # Falta '}'
run_test "$TITLE_MALFORMED_JSON" -X POST "$BASE_URL" -H "Content-Type: application/json" -d "$DATA_MALFORMED_JSON"

echo "====== FIM DOS TESTES DE ERROS DE REGISTRO ======"

echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para sair..."
echo "" 