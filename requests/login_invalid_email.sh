#!/bin/bash
echo "❌ Tentando login com e-mail incorreto..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"invalid-email","password":"StrongPass123"}' | jq
echo "✅ ❌ Tentando login com e-mail incorreto Finalizado."
