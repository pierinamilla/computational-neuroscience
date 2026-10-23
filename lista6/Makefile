# Lista 6 - Introducao a Neurociencia Computacional (FFCLRP-USP)
.PHONY: all run plots clean
FC     = gfortran
FFLAGS = -O2 -Wall -J build/mod -I build/mod
BIN    = build/bin
COMMON = src/common/neuro_mod.f90
PROGS  = q1a_fI_lif q2a_fI_ruido q2b_dt_rugosidade q2c_cv_isi q3a_pulso_adaptacao q3b_fI_adaptacao
# valores de sigma e correntes escolhidos (ver README / relatorio)
SIG1 = 0.5
SIG2 = 1.5
IBAIXO = 400
IACIMA = 800

all: $(addprefix $(BIN)/,$(PROGS))
$(BIN)/q1a_fI_lif:         src/q1/q1a_fI_lif.f90         $(COMMON); $(FC) $(FFLAGS) $(COMMON) $< -o $@
$(BIN)/q2a_fI_ruido:       src/q2/q2a_fI_ruido.f90       $(COMMON); $(FC) $(FFLAGS) $(COMMON) $< -o $@
$(BIN)/q2b_dt_rugosidade:  src/q2/q2b_dt_rugosidade.f90  $(COMMON); $(FC) $(FFLAGS) $(COMMON) $< -o $@
$(BIN)/q2c_cv_isi:         src/q2/q2c_cv_isi.f90         $(COMMON); $(FC) $(FFLAGS) $(COMMON) $< -o $@
$(BIN)/q3a_pulso_adaptacao: src/q3/q3a_pulso_adaptacao.f90 $(COMMON); $(FC) $(FFLAGS) $(COMMON) $< -o $@
$(BIN)/q3b_fI_adaptacao:   src/q3/q3b_fI_adaptacao.f90   $(COMMON); $(FC) $(FFLAGS) $(COMMON) $< -o $@

run: all
	mkdir -p data/q1 data/q2 data/q3
	$(BIN)/q1a_fI_lif
	$(BIN)/q2a_fI_ruido 0 $(SIG1) $(SIG2)
	$(BIN)/q2b_dt_rugosidade $(SIG2)
	$(BIN)/q2c_cv_isi $(SIG2) $(IBAIXO) $(IACIMA)
	$(BIN)/q3a_pulso_adaptacao
	$(BIN)/q3b_fI_adaptacao
plots:
	for s in plots/q1/*.py plots/q2/*.py plots/q3/*.py; do python3 $$s; done
clean:
	rm -rf build/bin/* build/mod/* 
