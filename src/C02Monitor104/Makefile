all: firmware

firmware: c02monitor.o
	ld65 -vm -C firmware.cfg -o firmware c02monitor.o

c02monitor.o: c02monitor.s
	ca65 --cpu 65c02 -t none -g -l c02monitor.lst --feature labels_without_colons -o c02monitor.o c02monitor.s

clean:
	$(RM) *.o *.lst *.map *.bin firmware