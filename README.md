# 6502 Homebrew - the adventure begins

## Goals
* Learn/Design/Build a 6502 based computer with Video, Sound, Storage and simple I/O (Serial, Keyboard)
* Design and build a Multi-tasking os with memory protection using memory bank switching per task
* Possible multi-cpu design in the future

## Plans
* Using Perf board to get the initial hardware running
* Get minimal software running to validate the hardware design
* Prototype PCB to lockdown the Hardware design
* Full OS work using lockdown hardware

---
*11/11/2019* Ordered lots of ICs from AliExpress on single day discounts.  6502, 6522, SRAM, EEPROM and tools.  These parts are for prototyping.

---
*15/11/2019* [TL866ii+ Universal Programmer](http://www.xgecu.com) ($53.12) arrived from AliExpress
![tl866ii+](images/tl866iiPlus_0.png)

Ordered bunch of *real* parts from Mouser
* W65C02S6TPG-14
* W65C22S6TPG-14
* W65C51N6TPG-14
* Various Clock Oscillators - 1Mhz, 2Mhz, 4Mhz, 8Mhz, 10Mhz

these parts have static core design which will allow very slow clock signal.

Downloaded and build/install [minipro](https://gitlab.com/DavidGriffith/minipro/).   
An open source EEPROM programming software.  Built it on my linux desktop.  With minipro installed, look like the fireware on the TL866ii+ needs to be updated.

![](images/tl866iiPlus_1.png)

Looks like I need to install the Windows Software to get access to the new Firmware.

---
*15/11/2019* First order from AliExpress arrived today.  

* 2 x 6502 ($0.77 each) - need testing
* 4 x 6522 ($0.76 each) - need testing
* 3 x Perf Board with Power Adaptor ($4.26 each)
* 5 x 62256 32KB SRAM ($1.12 each)
* 5 x AT28C256-15PU 32KB EEPROM ($3.20 each)
* 10 x 74LS00P NAND Gates ($1.12 for 10) 

![](images/order1_0.png)
![](images/order1_1.png)
![](images/order1_2.png)
![](images/order1_3.png)
![](images/order1_4.png)


Testing EEPROM using the TL866ii+ by reading and writing to the EEPROM with zero.  Looks like all the chips are used with content on them.

![](images/test_eeprom.png)
![](test_eeprom1.png)

---
