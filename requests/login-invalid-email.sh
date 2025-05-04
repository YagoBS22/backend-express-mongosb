curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "naoexiste@example.com", "password": "senha123"}'