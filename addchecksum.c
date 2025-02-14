#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <rom_file>\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "rb+");
    if (!f) {
        perror("Cannot open file");
        return 1;
    }

    // Получаем размер файла
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    rewind(f);

    // Читаем данные
    uint8_t *data = malloc(size);
    if (fread(data, 1, size, f) != size) {
        perror("Read error");
        fclose(f);
        free(data);
        return 1;
    }

    // Вычисляем контрольную сумму
    uint8_t checksum = 0;
    for (long i = 0; i < size - 1; i++) {
        checksum += data[i];
    }
    checksum = -checksum;  // Инвертируем для получения нулевой суммы

    // Записываем контрольную сумму в последний байт
    fseek(f, size - 1, SEEK_SET);
    fwrite(&checksum, 1, 1, f);

    fclose(f);
    free(data);
    printf("Checksum calculated and written: 0x%02X\n", checksum);
    return 0;
}
