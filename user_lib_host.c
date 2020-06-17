#include "gen/user_lib_u.h"


int do_something(sgx_enclave_id_t enclave, int a, int b)
{
    // do some stuff.
    // Make ecall
    int c = 0;
    add(enclave, &c, a, b);
    return c;
}

