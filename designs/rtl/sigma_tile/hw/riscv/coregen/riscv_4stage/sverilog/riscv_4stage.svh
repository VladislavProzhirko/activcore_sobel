// ===========================================================
// RTL generated by ActiveCore framework
// Date: 2020-10-25
// Copyright Alexander Antonov <antonov.alex.alex@gmail.com>
// ===========================================================

`ifndef __riscv_4stage_h_
`define __riscv_4stage_h_

typedef struct packed {
	logic unsigned [31:0] addr;
	logic unsigned [3:0] be;
	logic unsigned [31:0] wdata;
} riscv_4stage_busreq_mem_struct;

typedef struct packed {
	logic unsigned [0:0] we;
	riscv_4stage_busreq_mem_struct wdata;
} genpmodule_riscv_4stage_genmcopipe_instr_mem_genstruct_fifo_wdata;

typedef struct packed {
	logic unsigned [0:0] we;
	riscv_4stage_busreq_mem_struct wdata;
} genpmodule_riscv_4stage_genmcopipe_data_mem_genstruct_fifo_wdata;

`endif
