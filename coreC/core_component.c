#include "core_component.h"
#include <stdio.h>

/**
 * Gets the version in X.Y.Z format.
 * * @param out_version Pointer to the buffer where the version string will be stored.
 * @param max_len     Maximum size of the buffer.
 * @return            0 if successful, or -1 if the buffer is too small.
 */
int getVersion(char *out_version, size_t max_len) {
    /* Simulated version numbers */
    int major = 1;
    int minor = 4;
    int patch = 12;
    
    /* Safely format the string and prevent buffer overflows */
    int written = snprintf(out_version, max_len, "%d.%d.%d", major, minor, patch);

    /* Check if the string was truncated or if an encoding error occurred */
    if (written < 0 || (size_t)written >= max_len) {
        return VERSION_ERR_INSUFFICIENT_BUF; 
    }

    return VERSION_SUCCESS; 
}
