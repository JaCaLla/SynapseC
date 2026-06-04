cmake_minimum_required(VERSION 3.10)

# Nombre de nuestro proyecto de pruebas
project(TestComponenteC C)

# Indicar qué archivos fuentes componen nuestro programa ejecutable
add_executable(programa_test main.c core_component.c core_component.h)
