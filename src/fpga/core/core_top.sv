//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
assign cart_tran_pin31 = 1'bz;      // input
assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign dram_a = 'h0;
assign dram_ba = 'h0;
assign dram_dq = {16{1'bZ}};
assign dram_dqm = 'h0;
assign dram_clk = 'h0;
assign dram_cke = 'h0;
assign dram_ras_n = 'h1;
assign dram_cas_n = 'h1;
assign dram_we_n = 'h1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
    if (bridge_addr[31:28] == 4'h2) begin
      bridge_rd_data <= sd_read_data;
    end
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q ),

);


///////////////////////////////////////////////
// Core Settings
///////////////////////////////////////////////

// Board type defines
parameter [2:0] BOARD_TYPE_DRUAGA=3'b0;
parameter [2:0] BOARD_TYPE_SUPERPAC=3'd5;
parameter [2:0] BOARD_TYPE_GROBDA=3'd6;

// Game type defines
parameter [2:0] GAME_ID_DRUAGA=3'd1;
parameter [2:0] GAME_ID_MAPPY=3'd2;
parameter [2:0] GAME_ID_DIGDUG2=3'd3;
parameter [2:0] GAME_ID_MOTOS=3'd4;
parameter [2:0] GAME_ID_SUPERPAC=3'd5;
parameter [2:0] GAME_ID_GROBDA=3'd6;

reg [2:0] game_id;
reg [2:0] board_model; 
reg [31:0] game_settings;

always @(posedge clk_74a) begin
  if(bridge_wr) begin
    casex(bridge_addr)
      32'h80000000: begin 
			game_id		 	<= bridge_wr_data[2:0];  
		end
		32'h90000000: begin 
			game_settings 	<= bridge_wr_data[31:0];
		end
    endcase
  end
end


always @(posedge clk_74a) begin
	if (game_id == GAME_ID_GROBDA) begin
		board_model <= BOARD_TYPE_GROBDA;
	end
	else if (game_id == GAME_ID_SUPERPAC) begin
		board_model <= BOARD_TYPE_SUPERPAC;
	end
	else begin
		board_model <= BOARD_TYPE_DRUAGA;
	end
end
 

///////////////////////////////////////////////
// System
///////////////////////////////////////////////

wire osnotify_inmenu_s;

synch_3 OSD_S (osnotify_inmenu, osnotify_inmenu_s, clk_sys);

///////////////////////////////////////////////
// ROM
///////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
reg   [7:0] ioctl_index = 0;

always @(posedge clk_74a) begin
    if (dataslot_requestwrite)     ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

data_loader #(
    .ADDRESS_MASK_UPPER_4(4'h1),
    .ADDRESS_SIZE(25)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_dout)
);

//
// Coin Pulse
//

wire m_coin_pulse;
shortpulse coin_pulse(
	.clk(clk_sys),
	.inp(m_coin),
	.pulse(m_coin_pulse)
);
	

wire m_coin2_pulse;
shortpulse coin_pulse_2(
	.clk(clk_sys),
	.inp(m_coin2),
	.pulse(m_coin2_pulse)
);
	

///////////////////////////////////////////////
// High Score
///////////////////////////////////////////////

wire [31:0] sd_read_data;

wire sd_rd;
wire sd_wr;

wire [15:0] sd_buff_addr = sd_wr ? sd_buff_addr_in : sd_buff_addr_out;
wire [15:0] sd_buff_addr_in;
wire [15:0] sd_buff_addr_out;
wire [7:0]  sd_buff_din;
wire [7:0]  sd_buff_dout;

data_unloader #(
	.ADDRESS_MASK_UPPER_4(4'h2),
	.ADDRESS_SIZE(16)
) save_data_unloader (
	.clk_74a(clk_74a),
	.clk_memory(clk_sys),

	.bridge_rd(bridge_rd),
	.bridge_endian_little(bridge_endian_little),
	.bridge_addr(bridge_addr),
	.bridge_rd_data(sd_read_data),

	.read_en  (sd_rd),
	.read_addr(sd_buff_addr_out),
	.read_data(sd_buff_din)
);

data_loader #(
	.ADDRESS_MASK_UPPER_4(4'h2),
	.ADDRESS_SIZE(16)
) save_data_loader (
	.clk_74a(clk_74a),
	.clk_memory(clk_sys),

	.bridge_wr(bridge_wr),
	.bridge_endian_little(bridge_endian_little),
	.bridge_addr(bridge_addr),
	.bridge_wr_data(bridge_wr_data),

	.write_en  (sd_wr),
	.write_addr(sd_buff_addr_in),
	.write_data(sd_buff_dout)
);

reg [ 2:0] datatable_div = 0;
reg [31:0] rom_file_size = 0;

always @(posedge clk_74a or negedge pll_core_locked) begin
	if (~pll_core_locked) begin
		datatable_addr <= 0;
		datatable_data <= 0;
		datatable_wren <= 0;
	end else begin
		if (datatable_div > 4) begin
			// Write sram size half of the time
			datatable_wren <= 1;
			// sram_size is the size of the config value in the ROM. Convert to actual size
			datatable_data <= 32'd65536;
			// Data slot index 1, not id 1
			datatable_addr <= 1 * 2 + 1;
		end else begin
			datatable_wren <= 0;
			// Read ROM size rest of the time
			datatable_addr <= 1;
			if (datatable_div == 4) begin
				rom_file_size <= datatable_q;
			end
		end
		datatable_div <= datatable_div + 1;
	end
end


///////////////////////////////////////////////
// Video
///////////////////////////////////////////////

wire hblank_core, vblank_core;
wire hs_core_n, vs_core_n;
wire hs_core, vs_core;
wire [3:0] r;
wire [3:0] g;
wire [3:0] b;

reg video_de_reg;
reg video_hs_reg;
reg video_vs_reg;
reg [23:0] video_rgb_reg;

reg hs_prev;
reg vs_prev;

assign video_rgb_clock = clk_core_6;
assign video_rgb_clock_90 = clk_core_6_90deg;

assign video_de = video_de_reg;
assign video_hs = video_hs_reg;
assign video_vs = video_vs_reg;
assign video_rgb = video_rgb_reg;
assign video_skip = 0;

always @(posedge clk_core_6) begin
    video_de_reg <= 0;
	 video_rgb_reg <= 24'd0;
	 
    if (~(vblank_core || hblank_core)) begin
        video_de_reg <= 1;
        video_rgb_reg[23:16] <= {2{r}};
        video_rgb_reg[15:8] <= {2{g}};
        video_rgb_reg[7:0]   <= {2{b}};
    end
    video_hs_reg <= ~hs_prev && hs_core;
    video_vs_reg <= ~vs_prev && vs_core;
    hs_prev <= hs_core;
    vs_prev <= vs_core;
end


///////////////////////////////////////////////
// Audio
///////////////////////////////////////////////

wire [7:0] audio;

sound_i2s #(
    .CHANNEL_WIDTH(8),
    .SIGNED_INPUT (0)
) sound_i2s (
    .clk_74a(clk_74a),
    .clk_audio(clk_sys),
    
    .audio_l(audio),
    .audio_r(audio),

    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_dac(audio_dac)
);

///////////////////////////////////////////////
// Control
///////////////////////////////////////////////

wire [15:0] joy;
wire [15:0] joy2;

synch_3 #(
    .WIDTH(16)
) cont1_key_s (
    cont1_key,
    joy,
    clk_sys
);

synch_3 #(
    .WIDTH(16)
) cont2_key_s (
    cont2_key,
    joy2,
    clk_sys
);

wire m_up_2     = joy2[0];
wire m_down_2   = joy2[1];
wire m_left_2   = joy2[2];
wire m_right_2  = joy2[3];
wire m_fire_2   = joy2[4];

wire m_up_1     = joy[0];
wire m_down_1   = joy[1];
wire m_left_1   = joy[2];
wire m_right_1  = joy[3];
wire m_fire_1   = joy[4];

wire m_start_1 =  joy[15];
wire m_start_2 =  joy2[15];
wire m_coin   =  joy[14];
wire m_coin2  =  joy2[14];
wire m_pause   = joy[8] | joy2[8];

wire [1:0] LIFE = game_settings[1:0];
wire [1:0] COIA = game_settings[3:2];
wire DEMO = game_settings[4];
wire [1:0] COIB = game_settings[5:4];
wire SERV = game_settings[6];
wire [2:0] DIFF = game_settings[9:7];
wire ADVN = game_settings[10];
wire [2:0] EXTD = game_settings[13:11];
wire CABI = game_settings[14];

wire  [7:0] DSW0 = {LIFE,COIA,DEMO,1'b0,COIB};
wire  [7:0] DSW1 = {SERV,DIFF,ADVN,EXTD};
wire  [7:0] DSW2 = {6'h0,~SERV,~CABI};

wire  [4:0]	INP0 = { m_fire_1, m_left_1, m_down_1, m_right_1, m_up_1 };
wire  [4:0]	INP1 = { m_fire_2, m_left_2, m_down_2, m_right_2, m_up_2 };
wire  [2:0] INP2 = { (m_coin_pulse|m_coin2_pulse), m_start_2, m_start_1 };

///////////////////////////////////////////////
// Instance
///////////////////////////////////////////////

wire reset = ~reset_n | ioctl_download;
wire [11:0] POUT;

wire  [8:0] HPOS,VPOS;
wire PCLK;

HVGEN hvgen
(
	.HPOS(HPOS),
	.VPOS(VPOS),
	.PCLK(PCLK),
	.iRGB(POUT),
	.oRGB({b,g,r}),
	.HBLK(hblank_core),
	.VBLK(vblank_core),
	.HSYN(hs_core),
	.VSYN(vs_core)
);

FPGA_GAPLUS gaplus_dut ( 
	.RESET(reset),  // RESET
    .MCLK(clk_sys),       // MasterClock: 49.125MHz

    .PH(HPOS),     // Screen H
    .PV(VPOS),     // Screen V
    .PCLK(PCLK),       // Pixel Clock -- output
    .POUT(POUT),       // Pixel Color -- output

    .SOUT(audio),        // Sound Out
                               // Sticks and Buttons (Active Logic)
    .INP0(INP0),           // 1P {B2,B1,L,D,R,U}
    .INP1(INP1),           // 2P {B2,B1,L,D,R,U}
    .INP2(INP2),            // {Coin,Start2P,Start1P}

    .DSW0(DSW0),       // DIPSWs (Active Logic)
    .DSW1(DSW1),
    .DSW2(DSW2),

    .ROMCL(clk_sys),  // Downloaded ROM image
    .ROMAD(ioctl_addr),
    .ROMDT(ioctl_dout),
    .ROMEN(ioctl_wr),
);

///////////////////////////////////////////////
// Clocks
///////////////////////////////////////////////

wire    clk_core_6;
wire    clk_core_6_90deg;
wire    clk_sys;

wire    pll_core_locked; 

mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),

    .outclk_0       ( clk_sys ),
    .outclk_1       ( clk_core_6 ),
    .outclk_2       ( clk_core_6_90deg ),

    .locked         ( pll_core_locked )
);



endmodule

///////////// Video Timing Generator

module HVGEN
(
	output  [8:0]		HPOS,
	output  [8:0]		VPOS,
	input 				PCLK,
	input	 [11:0]		iRGB,

	output reg [11:0]	oRGB,
	output reg			HBLK = 1,
	output reg			VBLK = 1,
	output reg			HSYN = 1,
	output reg			VSYN = 1
);

reg [8:0] hcnt = 0;
reg [8:0] vcnt = 0;

assign HPOS = hcnt;
assign VPOS = vcnt;

always @(posedge PCLK) begin
	case (hcnt)
		  1: begin HBLK <= 0; hcnt <= hcnt+1; end
		290: begin HBLK <= 1; hcnt <= hcnt+1; end
		311: begin HSYN <= 0; hcnt <= hcnt+1; end
		342: begin HSYN <= 1; hcnt <= 471;    end
		511: begin hcnt <= 0;
			case (vcnt)
				223: begin VBLK <= 1; vcnt <= vcnt+1; end
				234: begin VSYN <= 0; vcnt <= vcnt+1; end
				241: begin VSYN <= 1; vcnt <= 492;    end
				511: begin VBLK <= 0; vcnt <= 0;	     end
				default: vcnt <= vcnt+1;
			endcase
		end
		default: hcnt <= hcnt+1;
	endcase
	oRGB <= (HBLK|VBLK) ? 12'h0 : iRGB;
end

endmodule


module shortpulse
(
   input    clk,
   input    inp,
   output   pulse
);

reg        out;
reg [19:0] pulse_cnt = 0;

always_ff @(posedge clk) begin

   reg old_inp;
   out <= 1'b0;

   if (|pulse_cnt) begin
      pulse_cnt <= pulse_cnt - 1'b1;
      out <= 1'b1;
   end else begin
      old_inp <= inp;
      if (old_inp && !inp) pulse_cnt <= 20'hFFFFF;
   end

end

assign pulse = out;

endmodule