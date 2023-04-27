git clone https://github.com/feipeas/Pratti_Meyer
cd Pratti_Meyer/sim
rlwrap tclsh
source ../Scripts/StartUp.tcl
build ../osvvm
analyze ../alu.vhd
analyze ../alu_tb.vhd
