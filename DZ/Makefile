build: 
	fasm queue.asm
	gcc -no-pie main.c queue.o -o main

clean:
	rm -f *.o

check_size:
	gcc check_size.c
	./a.out
	rm -f a.out
