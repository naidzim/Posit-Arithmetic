GHDL=ghdl
GHDLOPTS=
GTKWAVE=gtkwave

all: run

run: LOD.vhd LZD.vhd barrelShifter.vhd data_extract.vhd arith_shifter_barrel.vhd Posit_mult.vhd
    #modules
	$(GHDL) -a Posit_mult.vhd
	$(GHDL) -a LOD.vhd
	$(GHDL) -a LZD.vhd
	$(GHDL) -a mux2to1Simple.vhd
	$(GHDL) -a barrelShifter.vhd
	$(GHDL) -a encoder.vhd
	$(GHDL) -a data_extract.vhd
	$(GHDL) -a arith_shifter_barrel.vhd
	
	#tb
	$(GHDL) -a data_extract_tb.vhd
	$(GHDL) -e data_extract_tb
	$(GHDL) -r data_extract_tb --stop-time=900ns --vcd=data_extract_tb.vcd
	
	$(GHDL) -a Posit_mult_tb.vhd
	$(GHDL) -e Posit_mult_tb
	$(GHDL) -r Posit_mult_tb  --vcd=Posit_mult_tb.vcd
	#--stop-time=0
#simulation view
view: encoder_tb.vcd
	#$(GTKWAVE) -f data_extract_tb.vcd -a data_extract_tb.sav
	$(GTKWAVE) -f Posit_mult_tb.vcd -a Posit_mult_tb.sav

clean:
	rm -f work*.cf
	rm -f *.o ./data_extract_tb
	rm -f *.o ./Posit_mult_tb
	
	rm -f data_extract_tb.vcd
	rm -f Posit_mult_tb.vcd
	

realclean: clean
	rm -f *~
