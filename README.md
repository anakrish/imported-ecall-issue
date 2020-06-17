# imported-ecall-issue
Demonstrate issue with imported ecall function id conflict

## Reproduction steps

Clone the repository, cd to the repo folder and execute.
```bash
source /opt/intel/sgxsdk/environment
./build_and_test.sh
```

This will produce the following output:
```bash
...
Running test...

Loaded enclave_a.signed.so
Loaded enclave_b.signed.so


Calling add function on both enclaves via host wrappers
add(enclave_a, 5, 6) = 11
enclave_b_add(enclave_b, 5, 6) = 11
Values matched

Testing imported ecall via user library
do_something(enclave_a, 5, 6) = 11
do_something(enclave_b, 5, 6) = -1
Values mismatch!!!!!!!!!
do_something(enclave_b, 5, 6) dispatched to subtract(5, 6) due to wrong function index

Destroyed enclave_a
Destroyed enclave_b
...

