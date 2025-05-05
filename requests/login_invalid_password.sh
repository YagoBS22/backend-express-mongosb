#!/bin/bash
echo "❌ Tentando login com senha incorreta..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123"}' | jq
echo "✅ ❌ Tentando login com senha incorreta Finalizado."