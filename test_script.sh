#!/bin/bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}' | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/sessions/1/questions | jq
