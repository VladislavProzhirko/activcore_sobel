/*
 * sigma.sv
 *
 *  Created on: 24.09.2017
 *      Author: Alexander Antonov <antonov.alex.alex@gmail.com>
 *     License: See LICENSE file for details
 */


`include "sigma_tile.svh"

module sigma
#(
	parameter CPU = "none",
	parameter UDM_BUS_TIMEOUT = (1024*1024*100),
	parameter UDM_RTX_EXTERNAL_OVERRIDE = "NO",
	parameter delay_test_flag = 0,
	parameter mem_init="YES",
	parameter mem_type="elf",
	parameter mem_data = "data.hex",
	parameter mem_size = 1024
)
(
	input clk_i
	, input arst_i
	, input irq_btn_i
	, input rx_i
	, output tx_o
	, input [31:0] gpio_bi
	, output [31:0] gpio_bo
);

wire srst;
reset_sync reset_sync
(
	.clk_i(clk_i),
	.arst_i(arst_i),
	.srst_o(srst)
);

wire udm_reset;
wire cpu_reset;
reg start;
assign cpu_reset = srst | udm_reset;

wire irq_btn_debounced;
debouncer debouncer
(
	.clk_i(clk_i)
	, .rst_i(srst)
	, .in(irq_btn_i)
	, .out(irq_btn_debounced)
);

MemSplit32 hif();
MemSplit32 xif();

sigma_tile #(
	.corenum(0)
	, .mem_init(mem_init)
	, .mem_type(mem_type)
	, .mem_data(mem_data)
	, .mem_size(mem_size)
	, .CPU(CPU)
	, .PATH_THROUGH("YES")
) sigma_tile (
	.clk_i(clk_i)
	, .rst_i(cpu_reset)

	, .irq_debounced_bi({0, irq_btn_debounced, 3'h0})
	
	, .hif(hif)
	, .xif(xif)
);
	
udm #(
    .BUS_TIMEOUT(UDM_BUS_TIMEOUT)
    , .RTX_EXTERNAL_OVERRIDE(UDM_RTX_EXTERNAL_OVERRIDE)
) udm (
	.clk_i(clk_i)
	, .rst_i(srst)

	, .rx_i(rx_i)
	, .tx_o(tx_o)

	, .rst_o(udm_reset)
	
	, .bus_req_o(hif.req)
	, .bus_we_o(hif.we)
	, .bus_addr_bo(hif.addr)
	, .bus_be_bo(hif.be)
	, .bus_wdata_bo(hif.wdata)
	, .bus_ack_i(hif.ack)
	, .bus_resp_i(hif.resp)
	, .bus_rdata_bi(hif.rdata)
);


localparam CSR_LED_ADDR         = 32'h80000000;
localparam CSR_SW_ADDR          = 32'h80000004;

localparam TESTMEM_ADDR 	    = 32'h80000000;
localparam TESTMEM_ADDR_OUT     = 32'h90000000;
localparam START_ADDR           = 32'h80000ffc;



localparam TESTMEM_WSIZE	= 1024;

wire testmem_xif_enb;
assign testmem_xif_enb = (!(xif.addr < TESTMEM_ADDR) && (xif.addr < (TESTMEM_ADDR + (TESTMEM_WSIZE*4))));

wire testmem_xif_enb_out;
assign testmem_xif_enb_out = (!(xif.addr < TESTMEM_ADDR_OUT) && (xif.addr < (TESTMEM_ADDR_OUT + (TESTMEM_WSIZE*4))));

reg testmem_xif_we,testmem_xif1_we;
reg [31:0] testmem_xif_addr, testmem_xif_wdata, testmem_xif1_wdata;
reg [4:0] testmem_xif1_addr;
wire [31:0] testmem_xif_rdata, testmem_xif1_rdata;

reg testmem_xif_we_out,testmem_xif1_we_out;
reg [31:0]  testmem_xif_wdata_out,testmem_xif1_addr_out, testmem_xif1_wdata_out;
reg [4:0] testmem_xif_addr_out;
wire [31:0] testmem_xif_rdata_out,testmem_xif1_rdata_out;


logic [31:0] gpio_bo_reg;
assign gpio_bo = gpio_bo_reg;
logic [31:0] gpio_bi_reg;
always @(posedge clk_i) gpio_bi_reg <= gpio_bi;

assign xif.ack = xif.req;   // xif always ready to accept request
logic csr_resp, testmem_resp_dly, testmem_resp, testmem_resp_dly_out, testmem_resp_out;
logic [31:0] csr_rdata;



/////////////////////////IN////////////////////////////
ram_dual #(
    .mem_init("NO")
    , .mem_data("nodata.hex")
    , .dat_width(32)
    , .adr_width(20)
    , .mem_size(1024)
) testmem (
    .clk(clk_i)

    , .dat0_i(testmem_xif_wdata)
    , .adr0_i(testmem_xif_addr)
    , .we0_i(testmem_xif_we)
    , .dat0_o(testmem_xif_rdata)

    , .dat1_i(testmem_xif1_wdata)
    , .adr1_i({15'h0, testmem_xif1_addr})
    , .we1_i(testmem_xif1_we)
    , .dat1_o(testmem_xif1_rdata)
);
/////////////////////////IN///////////////////////////////


/////////////////////////OUT//////////////////////////////
ram_dual #(
    .mem_init("NO")
    , .mem_data("nodata_out.hex")
    , .dat_width(32)
    , .adr_width(20)
    , .mem_size(1024)
) testmem_out (
    .clk(clk_i)

    , .dat0_i(testmem_xif_wdata_out)
    , .adr0_i({15'h0, testmem_xif_addr_out})
    , .we0_i(testmem_xif_we_out)
    , .dat0_o(testmem_xif_rdata_out)

    , .dat1_i(testmem_xif1_wdata_out)
    , .adr1_i({32'h0, testmem_xif1_addr_out})
    , .we1_i(testmem_xif1_we_out)
    , .dat1_o(testmem_xif1_rdata_out)
);
///////////////////OUT///////////////////////////////////


// bus request
always @(posedge clk_i)
    begin
    
    //testmem_udm_we <= 1'b0;
    //testmem_udm_addr <= 0;
    //testmem_udm_wdata <= 0;
    
    //testmem_xif1_we_out <= 1'b0;
    //testmem_xif1_addr_out <= 0;
    //testmem_xif1_wdata_out <= 0;
    
    start <= 0;
    
    csr_resp <= 1'b0;
    
    testmem_resp_dly <= 1'b0;
    testmem_resp <= testmem_resp_dly;
    
    testmem_resp_dly_out <= 1'b0;
    testmem_resp_out <= testmem_resp_dly_out;
    
    if (xif.req && xif.ack)
        begin
        
        if (xif.we)     // writing
            begin
            if (xif.addr == CSR_LED_ADDR) gpio_bo_reg <= xif.wdata;
            if (xif.addr == START_ADDR) 
            begin 
                start <= 1'b1;
            end
             if (testmem_xif_enb)
                begin
                testmem_xif_we <= 1'b1;
                testmem_xif_addr <= xif.addr[22:2];     // 4-byte aligned access only
                testmem_xif_wdata <= xif.wdata;
                end
                
            if (testmem_xif_enb_out)
                begin
                testmem_xif_we_out <= 1'b1;
                testmem_xif_addr_out <= xif.addr[31:2];     // 4-byte aligned access only
                testmem_xif_wdata_out <= xif.wdata;
                end
            if (xif.addr == START_ADDR) begin 
                start <= 1'b1;
            end
            end
        
        else            // reading
            begin
            if (xif.addr == CSR_LED_ADDR)
                begin
                csr_resp <= 1'b1;
                csr_rdata <= gpio_bo_reg;
                end
            if (xif.addr == CSR_SW_ADDR)
                begin
                csr_resp <= 1'b1;
                csr_rdata <= gpio_bi_reg;
                end
                if (testmem_xif_enb)
                begin
                testmem_xif_we <= 1'b0;
                testmem_xif_addr <= xif.addr[31:2];     // 4-byte aligned access only
                testmem_xif_wdata <= xif.wdata;
                testmem_resp_dly <= 1'b1;
                end
            if (testmem_xif_enb_out)
                begin
                testmem_xif_we_out <= 1'b0;
                testmem_xif_addr_out <= xif.addr[31:2];     // 4-byte aligned access only
                testmem_xif_wdata_out <= xif.wdata;
                testmem_resp_dly <= 1'b1;
                end
            end
        end
    end

// bus response
always @*
    begin
    xif.resp = csr_resp | testmem_resp | testmem_resp_out;
    xif.rdata = 0;
    if (csr_resp) xif.rdata = csr_rdata;
        else
            if (testmem_resp)
            begin
                xif.rdata = testmem_xif_rdata;
            end
            else
            if (testmem_resp_out)
            begin
                xif.rdata = testmem_xif_rdata_out;
            end
    end


Sobel Sobel_my (
        .image_in_address0(testmem_xif1_addr),    
        .image_in_q0(testmem_xif1_rdata),      
        .image_out_address0(testmem_xif_addr_out),     
        .image_out_d0(testmem_xif_wdata_out),
        .image_out_q0(testmem_xif_rdata_out),
        .image_out_we0(testmem_xif_we_out),
        .ap_clk(clk_i),
        .ap_rst(srst),
        .ap_start(start),
        .ap_done(done),
        .ap_ready(ready),
        .ap_idle(idle)
);


endmodule
