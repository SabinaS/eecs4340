CC = gcc
CFLAGS = -g

libaesdecrypt.a: aes.o aes_decrypt.o
	ar rcs $@ $^

clean:
	rm -rf libaesdecrypt.a aes.o aes_decrypt.o
