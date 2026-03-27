CXX = g++
ASM = nasm

CXXFLAGS = -Wall -g 
ASMFLAGS = -f elf64 -g -F dwarf

TARGET = test.out

CXX_SRCS = tests/test_programm.cpp
ASM_SRCS = src/my_printf.asm
OBJS = $(CXX_SRCS:.cpp=.o) $(ASM_SRCS:.asm=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $^ -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean