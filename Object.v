// Part 2 skeleton

module testmove
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        	KEY,
        	SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:7]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = ".mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    	datepath d0(
	.refresh_clock(KEY[0]), 
	.clock_50(CLOCK_50), 
	.resetn(KEY[1]), 
	.x(x), 
	.y(y), 
	.color(colour)
	);
    
    
    
endmodule

module datapath(refresh_clock, clock_50, resetn, x, y, color);
input clock_50;
input resetn;
input refresh_clock;
output reg [2:0] color;

localparam	TestObject1_X = 8'd0,
		TestObject1_Y = 7'd0,
		TestObject2_X = 8'd160,
		TestObject2_Y = 7'd120,
		TestObject_C = 3'b111,
		PlayerObject_X = 8'd79,
		PlayerObject_Y = 7'd110,
		PlayerObject_C = 3'b100,
		Initial = 13'd0,
		T_end = 13'd4096,
		P_end = 9'd256;

reg [7:0] 	T1_X = TestObject1_X;
reg [6:0] 	T1_Y = TestObject1_Y;
reg [7:0]	T2_X = TestObject2_X;
reg [6:0]	T2_Y = TestObject2_Y;
reg [2:0] 	T_C = TestObject_C;
reg [7:0] 	P_X = PlayerObject_X;
reg [6:0] 	P_Y = PlayerObject_Y;
reg [2:0] 	P_C = PlayerObject_C;

reg [12:0] 	size = Initial;
reg [12:0] 	size_end = T_end;
reg [3:0] 	paint_state; 
				

output reg [7:0] x;
output reg [6:0] y;

// Paint all the object.
always @(posedge clock_50)
begin
    	if(!resetn) begin
		x <= T1_X;
		y <= T1_Y;
		paint_state <= 4'b0;
		size <= Initial;
		size_end <= T_end;
	end
	else begin
		if(paint_state == 4'd0 ) begin	// Paint TestObject_X.
			if(size != size_end) begin
				x <= T1_X + size[7:0];
				y <= T1_Y + size[11:8];
				color <= T_C;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial;
				size_end <= T_end;
				paint_state <= paint_state + 1'b1;
			end
		end
		else if(paint_state == 4'd1) begin // The default state is the state to paint the player.
			if(size != size_end) begin
				x <= T2_X + size[7:0];
				y <= T2_Y + size[11:8];
				color <= T_C;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial;
				size_end <= P_end;
				paint_state <= paint_state + 1'b1;
			end
		end
		else begin // The default state is the state to paint the player.
			if(size != size_end) begin
				x <= P_X + size[3:0];
				y <= P_Y + size[7:4];
				color <= P_C;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial; //This may need to be changed.
				size_end <= T_end;
				paint_state <= 1'b0;
			end
		end
	end
end
always @(posedge refresh_clock)
begin
	T_C <= 3'b000;
	P_C <= 3'b000;
end

	
always @(negedge refresh_clock)
begin
	T1_X <= T1_X + 4'd4;
	T2_X <= T2_X - 4'd4;
	T_C <= TestObject_C;
	P_C <= PlayerObject_C;
end

endmodule

