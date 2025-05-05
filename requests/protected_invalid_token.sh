#!/bin/bash
echo "🔒 Tentando acessar rota protegida com token inválido..."
curl -s -X GET http://localhost:3000/api/protected \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid.token.here" | jq
echo "✅ 🔒 Tentando acessar rota protegida com token inválido Finalizado."