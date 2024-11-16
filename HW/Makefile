asm: first.asm
	fasm first.asm

c: asm firsta.c
	gcc firsta.c first.o -o myprog

run: c myprog
	./myprog

clean:
	rm -f *.o