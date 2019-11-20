package main

import (
	"bufio"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"log"
	"os"
)

/*
							FROM ADDR						TO ADDR						CHIP SELECT VALUE		ACTIVE
0000-7EFF		RAM			0000 0000 0000 000	0000		0111 1110 1111 111	3F7F		0000 0001				0		$01
7F00-7FFF		I/O
	7F00-7F0F	VIA1		0111 1111 0000 000	3F80		0111 1111 0000 111	3F87		1100 0000				01		$C0
	7F10-7F1F	VIA2		0111 1111 0001 000	3F88		0111 1111 0001 111	3F8F		0011 0000				01		$30
8000-FFFF		ROM			1000 0000 0000 000	4000		1111 1111 1111 111	7FFF		0000 0010				0		$02

*/
func main() {

	var a []byte
	a = make([]byte, 32768)

	setArea(a, "0000", "3F7F", '\x01')
	setArea(a, "3F80", "3F87", '\xC0')
	setArea(a, "3F88", "3F8F", '\x30')
	setArea(a, "4000", "7FFF", '\x02')

	writeMap(a)
}

func setArea(a []byte, start, end string, value byte) {
	s := hex2i(start)
	e := hex2i(end)
	for i := s; i <= e; i++ {
		a[i] = value
	}
}

func writeMap(a []byte) {
	file, err := os.Create("decode.bin")
	if err != nil {
		log.Fatalf("Failed to create decode.bin file: %s", err)
	}
	w := bufio.NewWriter(file)
	if _, err := w.Write(a); err != nil {
		log.Fatal(err)
	}
	if err := w.Flush(); err != nil {
		log.Fatal(err)
	}
	if err := file.Close(); err != nil {
		log.Fatal(err)
	}
	fmt.Println("done")
}

func hex2i(s string) uint16 {
	if b, err := hex.DecodeString(s); err != nil {
		return 0
	} else {
		v := binary.BigEndian.Uint16(b)
		//fmt.Println(v)
		return v
	}
}
