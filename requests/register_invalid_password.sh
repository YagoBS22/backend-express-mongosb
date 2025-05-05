#!/bin/bash
echo "❌ Tentando registrar com senha inválida..."
curl -s -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"test","email":"test@example.com","password":"123"}' | jq
echo "✅ ❌ Tentando registrar com senha inválida Finalizado."
