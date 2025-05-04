CC = gcc
CFLAGS = -Wall -Wextra
LDFLAGS = 
OPTIMIZE = -O2

all: parent child

parent: parent.o math_functions.o
	$(CC) $(LDFLAGS) -o $@ $^

child: child.o math_functions.o
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) $(OPTIMIZE) -c -o $@ $<

clean:
	rm -f *.o parent child

.PHONY: all clean