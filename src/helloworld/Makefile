all: hello

hello: hello.o
	ld65 -vm -C hello.cfg -o hello hello.o

hello.o: hello.s
	ca65 --cpu 65c02 -t none -g -l hello.lst --feature labels_without_colons -o hello.o hello.s

clean:
	$(RM) *.o *.lst *.map *.bin hello