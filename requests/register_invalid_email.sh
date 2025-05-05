#!/bin/bash
echo "❌ Tentando registrar com e-mail inválido..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"test","email":"invalid-email","password":"StrongPass123"}' | jq
echo "✅ ❌ Tentando registrar com e-mail inválido Finalizado."