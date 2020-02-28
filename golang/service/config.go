package service

import (
	"math/rand"
)

const numBytes = "1234567890"

func randStringBytes(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = numBytes[rand.Intn(len(numBytes))]
	}
	return string(b)
}
