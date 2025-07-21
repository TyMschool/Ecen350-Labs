# Makefile for compiling benchmark.c

CC = gcc
SRC = benchmark.c
TARGET = benchmark

# Default target
all: noopt opt


# Compile with no optimization
noopt:
	$(CC) -O0 -g -o $(TARGET)_O0 $(SRC)

# Compile with high optimization
opt:
	$(CC) -O3 -g -o $(TARGET)_O3 $(SRC)

# Clean build artifacts
clean:
	rm -f $(TARGET)_O0 $(TARGET)_O3
