# Oitava Lista — Introdução à Neurociência Computacional

Projeto em Python + Fortran + shell, organizado por questão/inciso. O modelo usa Hodgkin–Huxley reduzido para E, Wang–Buzsáki para I e OLM para O, com sinapses AMPA/GABA e RK4 (Δt=0,01 ms).

## Estrutura
- `src/python/solve_lista8.py`: implementação das simulações e geração de CSV/PNG.
- `src/fortran/hh_single.f90`: implementação Fortran RK4 de um neurônio E/I isolado com pulso; gera `results/hh_single.csv`.
- `scripts/run_all.sh`: executa o conjunto Python.
- `scripts/run_fortran.sh`: compila e executa o exemplo Fortran.
- `plots/q1/...`, `plots/q2/...`, `plots/q3/...`: figuras separadas por questão e inciso.
- `data/`: séries temporais e estatísticas CSV.
- `results/`: saídas do Fortran e notas.

## Executar
```bash
python3 -m pip install numpy matplotlib
./scripts/run_all.sh
./scripts/run_fortran.sh  # requer gfortran
```

## Observações importantes para validar antes da entrega
1. A integração principal é RK4 com passo 0,01 ms. Para os sistemas de rede, o código Python é a implementação de referência.
2. Os valores de J0 usados nos itens 1(a,b) são palpites iniciais e precisam ser confirmados por varredura de corrente para garantir exatamente um disparo pré-sináptico; ajuste-os se necessário.
3. No item 3(b), o script calcula variações de período ao alterar JE e gIE; a variação de τd,I ainda requer propagar o parâmetro τd personalizado para a dinâmica sináptica. Não use esse resultado específico sem completar essa alteração.
4. A frequência é estimada a partir dos intervalos entre disparos detectados por cruzamento ascendente de 0 mV. As estimativas podem depender da janela de análise.
5. As figuras e CSVs incluídos são saídas geradas até onde a execução terminou; para gerar o conjunto completo, execute `./scripts/run_all.sh`. Verifique os avisos acima antes de usar números no relatório.
