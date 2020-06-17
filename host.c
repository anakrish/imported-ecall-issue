#include <stdio.h>
#include "sgx_urts.h"
#include "gen/enclave_a_u.h"
#include "gen/enclave_b_u.h"

// library function declaration.
int do_something(sgx_enclave_id_t enclave, int a, int b);

int main()
{
    sgx_status_t ret = SGX_ERROR_UNEXPECTED;
    sgx_enclave_id_t enclave_a = 0;
    sgx_enclave_id_t enclave_b = 0;
    

    printf("\n\n\nRunning test...\n\n");
    ret = sgx_create_enclave("./build/enclave_a.signed.so", SGX_DEBUG_FLAG, NULL, NULL, &enclave_a, NULL);
    if (ret != SGX_SUCCESS) {
	printf("Failed to create enclave_a\n");
        return -1;
    }
    printf("Loaded enclave_a.signed.so\n");

    ret = sgx_create_enclave("./build/enclave_b.signed.so", SGX_DEBUG_FLAG, NULL, NULL, &enclave_b, NULL);
    if (ret != SGX_SUCCESS) {
	printf("Failed to create enclave_b\n");
        return -1;
    }
    printf("Loaded enclave_b.signed.so\n");

    {
	printf("\n\nCalling add function on both enclaves via host wrappers\n");
	int c_a = 0;
	add(enclave_a, &c_a, 5, 6);
	printf("add(enclave_a, 5, 6) = %d\n", c_a);

	int c_b = 0;
	enclave_b_add(enclave_b, &c_b, 5, 6);
	printf("enclave_b_add(enclave_a, 5, 6) = %d\n", c_b);

	if (c_a != c_b)
	    printf("Values mismatch!!!!!!!!!\n\n");
	else
	    printf("Values matched\n\n");
	    
    }

    {
	printf("Testing imported ecall via user library\n");
	int c_a = do_something(enclave_a, 5, 6);
	printf("do_something(enclave_a, 5, 6) = %d\n", c_a);


	int c_b = do_something(enclave_b, 5, 6);
	printf("do_something(enclave_b, 5, 6) = %d\n", c_b);

	if (c_a != c_b)
	{
	    printf("Values mismatch!!!!!!!!!\n");
	    printf("do_something(enclave_b, 5, 6) dispatched to subtract(5, 6)"
		   " due to wrong function index\n\n");
	}
	else
	    printf("Values matched\n\n");
    }

    if (sgx_destroy_enclave(enclave_a) != SGX_SUCCESS)
    {
	printf("Failed to destroy enclave_a");
	return -1;
    }
    printf("Destroyed enclave_a\n");

    if (sgx_destroy_enclave(enclave_b) != SGX_SUCCESS)
    {
	printf("Failed to destroy enclave_b");
	return -1;
    }
    printf("Destroyed enclave_b\n");
}
