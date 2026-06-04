#ifndef CORE_COMPONENT_H
#define CORE_COMPONENT_H

/* Status and Error Codes */
#define VERSION_SUCCESS                0
#define VERSION_ERR_INSUFFICIENT_BUF  -1

#include <stdio.h>

int generar_saludo(const char* texto_entrada, int entero_entrada, char* buffer_salida, int tamano_buffer);
/**
 * Gets the version in X.Y.Z format.
 * * @param out_version Pointer to the buffer where the version string will be stored.
 * @param max_len     Maximum size of the buffer.
 * @return            0 if successful, or -1 if the buffer is too small.
 */
int getVersion(char *out_version, size_t max_len);
#endif /* CORE_COMPONENT_H */
