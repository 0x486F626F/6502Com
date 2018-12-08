#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <string>

#include <memory.h>

uint8_t header[16];
std::vector <uint8_t> prg_rom, chr_rom;

void output_header(std::ofstream &fout) {
    memset(header, 0, sizeof(header));
    std::cerr << "PRG ROM size: " << prg_rom.size();
    while (prg_rom.size() % 16384) prg_rom.push_back(0);
    std::cerr << " blocks: " << prg_rom.size() / 16384 << std::endl;
    while (chr_rom.size() % 8192) chr_rom.push_back(0);

    header[0] = 0x4e;
    header[1] = 0x45;
    header[2] = 0x53;
    header[3] = 0x1a;
    header[4] = prg_rom.size() / 16384;
    header[5] = chr_rom.size() / 8192;
    for (int i = 0; i < 16; i ++)
        fout << header[i];
}

void output_rom(std::ofstream &fout) {
    *(prg_rom.end() - 1) = 0xc0;
    *(prg_rom.end() - 2) = 0x00;
    *(prg_rom.end() - 3) = 0xc0;
    *(prg_rom.end() - 4) = 0x00;
    *(prg_rom.end() - 5) = 0xc5;
    *(prg_rom.end() - 6) = 0xaf;
    for (size_t i = 0; i < prg_rom.size(); i ++)
        fout << prg_rom[i];
    //for (size_t i = 0; i < chr_rom.size(); i ++)
    //    fout << chr_rom[i];
}

void input_rom(std::ifstream &fin) {
    std::string line;
    int byte;
    while (std::getline(fin, line)) {
        std::cerr << line << std::endl;
        std::istringstream sin(line);
        while (sin >> std::hex >> byte)
            prg_rom.push_back(byte);
    }
}

int main(int argc, char* argv[]) {
    if (argc != 3) return 0;
    std::ifstream fin(argv[1]);
    std::ofstream fout(argv[2]);

    input_rom(fin);

    output_header(fout);
    output_rom(fout);

    fout.close();
    fin.close();
    return 0;
}
