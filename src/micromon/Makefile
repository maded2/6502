all: firmware

firmware: micromon.o
	ld65 -vm -C firmware.cfg -o firmware micromon.o

micromon.o: micromon.s
	ca65 --cpu 65c02 -t none -g -l micromon.lst -o micromon.o micromon.s

clean:
	$(RM) *.o *.lst *.map *.bin firmware