# Compilar módulos (primero los que no dependen de nadie)
gfortran -O3 -Wall -Jbin -c ../src/mod_cs_params.f90 -o ./mod_cs_params.o
gfortran -O3 -Wall -Jbin -c ../src/mod_cs_gating.f90 -o ./mod_cs_gating.o
gfortran -O3 -Wall -Jbin -c ../src/mod_cs_deriv.f90  -o ./mod_cs_deriv.o
gfortran -O3 -Wall -Jbin -c ../src/mod_rk4.f90       -o ./mod_rk4.o

# Compilar programas principales
gfortran -O3 -Wall -Jbin -o ./q1a ../src/q1a_main.f90 ./mod_cs_params.o ./mod_cs_gating.o
gfortran -O3 -Wall -Jbin -o ./q1b ../src/q1b_main.f90 bin/mod_cs_params.o ./mod_cs_gating.o \
                                                ./mod_cs_deriv.o  ./mod_rk4.o
