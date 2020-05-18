all: pckybd

pckybd: pckybd.o
	ld65 -vm -C pckybd.cfg -o pckybd pckybd.o

pckybd.o: pckybd.s
	ca65 --cpu 65C02 -t none -g -l pckybd.lst --feature labels_without_colons -o pckybd.o pckybd.s

clean:
	$(RM) *.o *.lst *.map *.bin pckybd