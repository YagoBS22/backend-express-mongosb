#!/bin/bash
echo "🔄 Registrando usuário válido..."
curl -s -X POST https://backend-express-mongosb.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"test","email":"test@example.com","password":"StrongPass123"}'
echo "✅ 🔄 Registrando usuário válido Finalizado."
sleep 1000