#include <stdio.h>
#include "core_component.h"


/**
 * Test Case 1: Verifies that getVersion returns an error 
 * when the provided buffer is too small.
 * * @return 0 if the test passes, 1 if it fails.
 */
int test_getVersion_InsufficientBuffer(void) {
    /* A buffer of 4 bytes is too small for "1.4.12" (needs 7 bytes total) */
    char tiny_buffer[4]; 
    int status = getVersion(tiny_buffer, sizeof(tiny_buffer));

    printf("[TEST] test_getVersion_InsufficientBuffer\n");
    printf("  Expected status: %d\n", VERSION_ERR_INSUFFICIENT_BUF);
    printf("  Actual status  : %d\n", status);

    if (status == VERSION_ERR_INSUFFICIENT_BUF) {
        printf("  RESULT         : PASSED\n\n");
        return 0; /* Test passed */
    } else {
        printf("  RESULT         : FAILED\n\n");
        return 1; /* Test failed */
    }
}

/**
 * Test Case 2: Verifies that getVersion returns success 
 * and the correct string when the buffer is large enough.
 * * @return 0 if the test passes, 1 if it fails.
 */
int test_getVersion_Success(void) {
    char good_buffer[32]; 
    int status = getVersion(good_buffer, sizeof(good_buffer));

    printf("[TEST] test_getVersion_Success\n");
    printf("  Expected status: %d\n", VERSION_SUCCESS);
    printf("  Actual status  : %d\n", status);

    if (status == VERSION_SUCCESS) {
        printf("  Output string  : %s\n", good_buffer);
        printf("  RESULT         : PASSED\n\n");
        return 0; /* Test passed */
    } else {
        printf("  RESULT         : FAILED\n\n");
        return 1; /* Test failed */
    }
}

int main(void) {
    int failed_tests = 0;

    printf("--- STARTING UNIT TEST SUITE ---\n\n");

    /* Run tests and accumulate failures */
    failed_tests += test_getVersion_InsufficientBuffer();
    failed_tests += test_getVersion_Success();

    printf("--- TEST SUITE SUMMARY ---\n");
    if (failed_tests == 0) {
        printf("All tests PASSED successfully.\n");
    } else {
        printf("Suite FAILED. Total test failures: %d\n", failed_tests);
    }

    /* Return 0 to the OS only if all tests pass */
    return failed_tests; 
}
