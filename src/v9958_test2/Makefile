all: firmware

firmware: test.o
	ld65 -vm -C firmware.cfg -o firmware test.o

test.o: test.s
	ca65 --cpu 65c02 -t none -g -l test.lst --feature labels_without_colons -o test.o test.s

clean:
	$(RM) *.o *.lst *.map *.bin firmware