#!/bin/bash

echo "🔐 Realizando login para obter token válido..."
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"StrongPass123"}' | jq -r '.token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "❌ Falha ao obter token válido. Verifique se o usuário existe e as credenciais estão corretas."
  exit 1
fi

echo "✅ Token obtido com sucesso."

echo "🔓 Acessando rota protegida com token válido..."
curl -s -X GET http://localhost:3000/api/protected \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq

echo "✅ Finalizado acesso à rota protegida com token válido."
