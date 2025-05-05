#!/bin/bash
echo "❌ Tentando login com e-mail incorreto..."
curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"invalid-email","password":"StrongPass123"}' | jq
echo "✅ ❌ Tentando login com e-mail incorreto Finalizado."
