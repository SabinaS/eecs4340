SRCS=aes-main.c hwlink.c aes.c aes_decrypt.c rdist.c
OBJS=$(SRCS:.c=.o)
CC=gcc

CFLAGS=-Wmissing-prototypes

all:: Makefile.dep $(OBJS)
	$(CC) -o main $(OBJS)

%.o: %.c %.h
	$(CC) -c -o $@ $< $(CFLAGS)
	
Makefile.dep:
	gcc -MM $(SRCS) > Makefile.dep

clean:
	rm -f main $(OBJS) Makefile.dep

-include Makefile.dep
	
