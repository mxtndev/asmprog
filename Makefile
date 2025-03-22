AS = nasm
CC = gcc

# Цель по умолчанию
all: asm-prog

# Сборка объектного файла
main.o: main.asm
    $(AS) -felf64 $^ -o $@

# Компоновка исполняемого файла
asm-prog: main.o
    $(CC) -no-pie $^ -o $@

# Очистка временных файлов
clean:
    rm -f asm-prog main.o

.PHONY: clean