#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <set>

std::vector <std::vector <std::string> > instr_table;

void load_instr() {
    std::ifstream fin("6502.txt");
    for (int i = 0; i < 16; i ++) {
        std::vector <std::string> line;
        for (int j = 0; j < 16; j ++) {
            std::string instr;
            fin >> instr;
            line.push_back(instr);
            while(instr.length()<12) instr += " ";
        }
        instr_table.push_back(line);
    }
}

bool match4b(std::string hex, int bit) {
    for (int i = 0; i < 4; i ++) {
        if (hex[3-i] == '0' && ((bit >> i) & 1) == 1) return false;
        if (hex[3-i] == '1' && ((bit >> i) & 1) == 0) return false;
    }
    return true;
}

std::vector <int> grep_instr(std::string mask) {
    std::vector <int> idx;
    for (int i = 0; i < 16; i ++)
        for (int j = 0; j < 16; j ++)
            if (match4b(mask.substr(0, 4), i) && match4b(mask.substr(4, 4), j)) {
                idx.push_back(i*16+j);
            }
    return idx;
}

int main(int argc, char* argv[]) {
    if (argc < 2) return 0;
    load_instr();
    std::set <int> all;
    for (int i = 1; i < argc; i ++) {
        std::string mask = argv[i];
        std::vector <int> idx = grep_instr(mask);
        for (size_t j = 0; j < idx.size(); j ++)
            all.insert(idx[j]);
    }
    for (auto i = all.begin(); i != all.end(); i ++) {
        int x = *i / 16, y = *i % 16;
        if (instr_table[x][y] != "-------")
            std::cout << instr_table[x][y] << std::endl;
    }
}
