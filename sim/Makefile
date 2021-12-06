##########################################################################
# Copyright (C) 2021 Sangfor Ltd. All rights reserved.
# File Name   : Makefile
# Author      : bhyou
# mail        : bhyou@foxmail.com
# Created Time: Mon 06 Dec 2021 10:58:58 AM CST
#########################################################################

.PHONY:clean file com mixed sim 
clean:
	@rm -fr simv* csrc* ucli* 64 AN* DVE* *.vpd  *.log


#The following compile option is used for coverage.
coverOpt += -cm line+cond+tgl+fsm+branch+assert

comOpt += -full64 -sverilog +v2k 
comOpt += -override_timescale=1ns/1ps
logOpt += -l vcs_run.log

wavefile ?= vpd
ifeq ($(wavefile),vpd)
	macroOpt += +define+VPD
	comOpt += -debug_pp
else
	comOpt += -lca -kdb -fsdb
endif

#macroOpt += +define+Tcycle=200
#macroOpt += +incdir+../rtl/include

simOpt += -l tb_sim.log 

FILES += ../rtl/pixel_digital_scan.v
FILES += ../tbench/pixel_digital_scan_tb.v

all: com sim
com:
	vcs $(comOpt) $(logOpt) $(macroOpt) $(FILES)
sim:
	@./simv $(simOpt) -gui & 

cov:
	@./simv $(simOpt) $(coverOpt) 


verdi:
	@./simv $(simOpt) -gui=verdi & 

view:
	dve -full64 -covdir simv.vdb 
# view fsdb cmd: verdi -nologo -ssf *.fsdb 
# view coverage report cmd: dve -full64 -cov -dir simv.vpd


#The following three steps are used for vhdl-verilog mixed simulation.
#The first two steps is used to analyse hdl coding.
#The third step is used to elaborate the coding.
mixed:filelist
	vhdlan -fulll64 -nc vhdlist.f
	vlogan -full64 +v2k -sverilog +define+syn_off vloglist.f 
	vcs -full64 -debug_pp -top $(top) -l elab.log $(comOpt)

