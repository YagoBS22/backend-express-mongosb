#!/bin/bash
echo "🔐 Fazendo login com credenciais válidas..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"StrongPass123"}' | jq
echo "✅ 🔐 Fazendo login com credenciais válidas Finalizado."