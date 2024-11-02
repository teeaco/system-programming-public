asm: test.asm
		fasm dz.asm

c: asm dz.c
		gcc dz.c dz.o -o myprog

run: c myprog
		./myprog

clean:
		rm -f *.o