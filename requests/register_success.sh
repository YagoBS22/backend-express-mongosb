#!/bin/bash
echo "🔄 Registrando usuário válido..."
curl -s -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"test","email":"test@example.com","password":"StrongPass123"}' | jq
echo "✅ 🔄 Registrando usuário válido Finalizado."