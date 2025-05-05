#!/bin/bash
echo "🔒 Tentando acessar rota protegida SEM token..."
curl -s -X GET http://localhost:3000/api/protected \
   | jq
echo "✅ 🔒 Tentando acessar rota protegida SEM token Finalizado."
