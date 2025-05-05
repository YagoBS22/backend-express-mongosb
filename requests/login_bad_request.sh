#!/bin/bash
echo "🚫 Tentando login com requisição mal formatada..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"invalidField":"oops"}' | jq
echo "✅ 🚫 Tentando login com requisição mal formatada Finalizado."
sleep 10000
