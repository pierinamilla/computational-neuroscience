# Lista 7 — implementação e limites

Executar `bash scripts/run.sh` na raiz do projeto. Dependências: gfortran, Python 3, numpy, matplotlib. O script recompila e gera dados e figuras.

Unidades: ms, mV, pA, pF, nS; 1 nS·mV = 1 pA. Euler explícito dt=0.001 ms. A saída contínua é amostrada a cada 0.1 ms, mas os eventos de disparo e reset são preservados exatamente na malha temporal. As linhas de reset não são soluções do fluxo contínuo.

Q1(a): 3000 ms, pulso de 500 a 2500 ms, 221 pA. Q1(b): 20 correntes igualmente espaçadas 200–500 pA, 5000 ms. f1=1/primeiro ISI; f∞ estimada pela média dos últimos até 5 ISI; NaN indica dados insuficientes. A aproximação f∞ exige checagem de convergência para correntes próximas do limiar.

Q3(a,b,c): os parâmetros são os fornecidos pelo enunciado. Os retratos de fase contêm nulclinas para I=0 e para cada amplitude, raízes reais e autovalores da jacobiana do fluxo contínuo, e reset explícito. Os autovalores são anotados junto aos pontos fixos; parte dos pontos pode estar além da região fisicamente alcançável antes do reset. Em Q3(c) a redefinição de u é nula.

**Q2 implementada:** consultar a seção Q2 abaixo. A implementação de Q1 utiliza exatamente a forma especial da equação da lista, inclusive Vr diferente de VL.

**Atenção numérica:** Euler com limiar discreto possui erro de tempo de disparo O(dt); verificar convergência reduzindo dt. O exponencial AdEx é limitado em argumento para prevenir overflow somente fora da região anterior ao limiar. A comparação de autovalores se refere à dinâmica subsublimiar e não substitui uma análise de estabilidade de órbitas híbridas.

## Q2 — concluída (Gerstner et al., Tabela 6.1)
Executar `bash scripts/run_q2.sh`. Programa independente `src/q2_adex.f90` com Euler dt=0.001 ms; parâmetros dos sete padrões retirados de https://neuronaldynamics.epfl.ch/online/Ch6.S2.html . G=1/R=2 nS (R=500 MΩ), C=G*tau_m=2*tau_m pF; Vr=-70 mV, VL=-50 mV, Delta=2 mV, Vpico=20 mV conforme enunciado. Corrente de 65 pA, exceto delayed=25 pA. Q2(a): pulso de 100 a 600 ms, 700 ms total; curvas em `figuras/Q2a_padroes_7.png`, contagens e ISIs em `datos/Q2_spike_summary.csv`.

Q2(b): padrão initial_burst, pulso de 250 pA de 100 a 103 ms, e degrau alternativo 90 pA de 100 a 450 ms; `Q2b_i_ii_tempos.png` e três planos de fase (`Q2b_i_rest_fase.png`, `Q2b_i_pulse_fase.png`, `Q2b_ii_step_fase.png`). A nulclina V é u=-G(V-Vr)+G*Delta*exp((V-VL)/Delta)+I; nulclina u é u=a(V-Vr). Jacobiana [[(-G+G*exp((V-VL)/Delta))/C,-1/C],[a/tau,-1/tau]]. Autovalores no CSV de texto `datos/Q2_equilibria.txt`. Quando não há raízes reais para um dado I, isso é ausência de equilíbrios do fluxo contínuo, não um erro de cálculo.

**Cuidado:** as sete classes são reproduções numéricas qualitativas com janela de estímulo especificada neste projeto, não cópias pixel a pixel das figuras do livro. O limiar Vpico=20 mV segue a lista, e as figuras de fase interrompem as curvas nos resets; o salto híbrido não é uma trajetória diferencial. A integração de Euler apresenta erro temporal de disparo O(dt); não foi feita extrapolação dt→0.
