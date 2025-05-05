#!/bin/bash
echo "🏁 Iniciando testes automáticos..."

for script in *.sh; do
  if [[ "$script" != "run_all.sh" ]]; then
    echo ""
    echo "🚀 Executando: $script"
    bash "$script"
    echo "------------------------------------------------------"
	sleep 3
  fi
done

echo "✅ Todos os testes executados."

sleep 3