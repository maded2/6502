package main

import (
	"bufio"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"log"
	"os"
)

func main() {
	file, err := os.Create("decode.bin")
	if err != nil {
		log.Fatalf("Failed to create decode.bin file: %s", err)
	}

	var a []byte
	a = make([]byte, 32768)
	w := bufio.NewWriter(file)
	for i := 0; i < 32768; i++ {
		a[i] = '\xEA'
	}
	a[hex2i("7ffc")] = '\x00'
	a[hex2i("7ffd")] = '\x80'

	if _, err := w.Write(a); err != nil {
		log.Fatal(err)
	}
	if err := w.Flush(); err != nil {
		log.Fatal(err)
	}
	if err := file.Close(); err != nil {
		log.Fatal(err)
	}
	fmt.Println("hello world")
}

func hex2i(s string) uint16 {
	if b, err := hex.DecodeString(s); err != nil {
		return 0
	} else {
		v := binary.BigEndian.Uint16(b)
		fmt.Println(v)
		return v
	}
}
