#!/bin/bash
echo "🚫 Tentando registrar com requisição mal formatada..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"invalidField":"oops"}' | jq
echo "✅ 🚫 Tentando registrar com requisição mal formatada Finalizado."