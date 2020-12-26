-makelib ies_lib/xpm -sv \
  "F:/Vivado/Vivado/2020.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "F:/Vivado/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/sys_clk/sys_clk_clk_wiz.v" \
  "../../../ip/sys_clk/sys_clk.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

