#!/bin/bash
echo "🚫 Tentando login com requisição mal formatada..."
curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"invalidField":"oops"}' | jq
echo "✅ 🚫 Tentando login com requisição mal formatada Finalizado."
