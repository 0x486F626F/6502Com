verilator_flags=-Wno-CASEX -Wno-WIDTH -Wno-UNOPTFLAT -Wno-CASEINCOMPLETE -Wno-PINMISSING -Wno-CASEOVERLAP

all: com

com: com_verilator
	make -j -C obj_dir -f Vcom.mk Vcom

com_verilator: com.v cpu.v rom_00.v memory.v
	verilator --cc $^ --exe sim_main.cc $(verilator_flags)

.PHONY: clean

clean:
	rm -rf obj_dir
