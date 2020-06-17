#!/bin/sh

mkdir -p ./gen
mkdir -p ./build

#######################################################################
# Build the library that different enclaves can reuse.
sgx_edger8r user_lib.edl --header-only --trusted-dir gen --untrusted-dir gen

# make host lib
gcc -c -g -fPIC user_lib_host.c -o build/user_lib_host.o -I${SGX_SDK}/include
ar q build/user_lib_host.a build/user_lib_host.o

# make enclave lib
gcc -c -g -fPIC user_lib_enc.c -o build/user_lib_enc.o -I${SGX_SDK}/include
ar q build/user_lib_enc.a build/user_lib_enc.o


#######################################################################
# Build enclave a
sgx_edger8r enclave_a.edl  --trusted-dir gen --untrusted-dir gen

gcc -c -g -fpie -ffunction-sections -nostdinc -fdata-sections enclave_a.c -o build/enclave_a.o -I${SGX_SDK}/include
gcc -c -g -fpie -ffunction-sections -nostdinc -fdata-sections gen/enclave_a_t.c -o build/enclave_a_t.o -I${SGX_SDK}/include -I${SGX_SDK}/include/tlibc

gcc -o build/enclave_a.so build/enclave_a.o build/enclave_a_t.o build/user_lib_enc.a -Wl,--no-undefined -nostdlib -nodefaultlibs -nostartfiles -L${SGX_SDK}/lib64	-Wl,--whole-archive -lsgx_trts -Wl,--no-whole-archive -lsgx_tcrypto -lsgx_tservice \
	-Wl,--start-group -lsgx_tstdc -Wl,--end-group \
	-Wl,-Bstatic -Wl,-Bsymbolic -Wl,--no-undefined \
	-Wl,-pie,-eenclave_entry -Wl,--export-dynamic  \
	-Wl,--defsym,__ImageBase=0 -Wl,--gc-sections   \
	-Wl,--version-script=Enclave_a.lds

sgx_sign sign -key ./private_test.pem -enclave build/enclave_a.so  -out build/enclave_a.signed.so -config ./Enclave.config.xml

#######################################################################
# Build enclave b
sgx_edger8r enclave_b.edl --use-prefix --trusted-dir gen --untrusted-dir gen

gcc -c -g -fpie -ffunction-sections -nostdinc -fdata-sections enclave_b.c -o build/enclave_b.o -I${SGX_SDK}/include
gcc -c -g -fpie -ffunction-sections -nostdinc -fdata-sections gen/enclave_b_t.c -o build/enclave_b_t.o -I${SGX_SDK}/include -I${SGX_SDK}/include/tlibc

gcc -o build/enclave_b.so build/enclave_b.o build/enclave_b_t.o build/user_lib_enc.a -Wl,--no-undefined -nostdlib -nodefaultlibs -nostartfiles -L${SGX_SDK}/lib64	-Wl,--whole-archive -lsgx_trts -Wl,--no-whole-archive -lsgx_tcrypto -lsgx_tservice \
	-Wl,--start-group -lsgx_tstdc -Wl,--end-group \
	-Wl,-Bstatic -Wl,-Bsymbolic -Wl,--no-undefined \
	-Wl,-pie,-eenclave_entry -Wl,--export-dynamic  \
	-Wl,--defsym,__ImageBase=0 -Wl,--gc-sections   \
	-Wl,--version-script=Enclave_b.lds

sgx_sign sign -key ./private_test.pem -enclave build/enclave_b.so  -out build/enclave_b.signed.so -config ./Enclave.config.xml

#######################################################################
# Build host
gcc -c -g -fpie host.c -o build/host.o -I${SGX_SDK}/include

gcc -c -g -fpie gen/enclave_a_u.c -o build/enclave_a_u.o -I${SGX_SDK}/include 
gcc -c -g -fpie gen/enclave_b_u.c -o build/enclave_b_u.o -I${SGX_SDK}/include 

gcc -o build/host build/host.o build/enclave_a_u.o build/enclave_b_u.o build/user_lib_host.a -L${SGX_SDK}/lib64 -lsgx_urts -lpthread

#######################################################################
# Run test
build/host
