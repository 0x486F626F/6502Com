#include "Vcom.h"

#include <verilated.h>

int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);
    Vcom *com = new Vcom("com 6502");

    while (!Verilated::gotFinish()) {
        com->cpu_clock = 0; com->eval();
        com->cpu_clock = 1; com->eval();
        sleep(1);
    }

    delete com;
}
