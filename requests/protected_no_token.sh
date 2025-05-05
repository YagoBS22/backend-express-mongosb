#!/bin/bash
echo "🔒 Tentando acessar rota protegida SEM token..."
curl -s -X GET https://backend-express-mongosb.vercel.app/api/protected \
   | jq
echo "✅ 🔒 Tentando acessar rota protegida SEM token Finalizado."
