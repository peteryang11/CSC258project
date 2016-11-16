// Part 2 skeleton

module makeboxmove
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
    
    
    wire ld_x, ld_y, clock, change_color;
    wire [3:0] counter;
	 wire [7:0] xcoord;
	 wire [6:0] ycoord;
	 
	 X_counter x0(.clock(clock),.reset_n(resetn),.x_coord(xcoord));
	 Y_counter y0(.clock(clock),.reset_n(resetn),.y_coord(ycoord));
	 
	 ratedivider r0 (.Clock_50(CLOCK_50),.reset_n(resetn), .clock(clock));
    // Instansiate datapath
    datapath d0(.clock(clock), .reset_n(resetn), .x_coord(xcoord), .y_coord(ycoord), .counter(counter), .ld_x(ld_x), .ld_y(ld_y), .color_in(SW[9:7]), .change_color(change_color),.x(x), .y(y), .color_out(colour));

    // Instansiate FSM control
    control c0(.clk(CLOCK_50), .reset_n(resetn), .counter(counter), .ld_x(ld_x), .ld_y(ld_y), .plot(writeEn), .change_color(change_color));
    
endmodule

// NOV 5
module ratedivider(input Clock_50, input reset_n, output reg clock);

reg[24:0] delaycounter;

always @(posedge Clock_50)
begin
      if(reset_n == 1'b0)
		begin
		    clock <= 0;
			 delaycounter <= 25'd3;
		end
		else if(delaycounter == 25'd0) 
		begin
			 delaycounter <= 25'd3;
			 clock <= 1;
		end
		else
		begin
		    delaycounter <= delaycounter - 1'b1;
			 clock <= 0;
		end
end

endmodule
// NOV 5
//create a new coord for x. 
module X_counter(input clock, input reset_n, output reg [7:0] x_coord);

always @(posedge clock)
begin
    if(!reset_n)
	     x_coord <= 8'd0;
	 else
	     x_coord <= x_coord + 8'd4;
end

endmodule

module Y_counter(input clock, input reset_n, output reg [6:0] y_coord);

always @(posedge clock)
begin
    if(!reset_n)
	     y_coord <= 8'd0;
	 else
	     y_coord <= y_coord;
end

endmodule

module control(input clk, input reset_n, output reg [3:0] counter, output reg ld_x, output reg ld_y, output reg plot, output reg change_color);

reg Enable;
reg [5:0] current_state, next_state;


localparam      S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y        = 3'd2,
                S_LOAD_Y_WAIT   = 3'd3,
                S_CYCLE_0       = 3'd4,
					 S_CYCLE_0_WAIT  = 3'd5,
                S_CYCLE_1       = 3'd6,
					 S_CYCLE_2       = 3'd7;
		
always@(*)
begin: state_table 
    case (current_state)
	S_LOAD_X: next_state = S_LOAD_X_WAIT; // Loop in current state until value is input
	S_LOAD_X_WAIT: next_state = S_LOAD_Y ; // Loop in current state until go signal goes low
	S_LOAD_Y: next_state = S_LOAD_Y_WAIT ; // Loop in current state until value is input
	S_LOAD_Y_WAIT: next_state = S_CYCLE_0; // Loop in current state until go signal goes low
	S_CYCLE_0: next_state = (counter == 4'b1110) ? S_CYCLE_0_WAIT : S_CYCLE_0;
	S_CYCLE_0_WAIT: next_state = S_CYCLE_1;
	S_CYCLE_1: next_state = (counter == 4'b1110) ? S_CYCLE_2 : S_CYCLE_1;//this state used to draw black
	S_CYCLE_2: next_state = S_LOAD_X;
	default:     next_state = S_LOAD_X;
    endcase
end // state_table
		

always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
        Enable = 1'b0;
        plot = 1'b0; 
		  change_color = 1'b0;
		   
        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
            S_CYCLE_0: begin
                Enable = 1'b1;
		          plot = 1'b1;
                end
				S_CYCLE_0_WAIT: begin
                change_color = 1'b1;
					 Enable = 1'b1;
		          plot = 1'b1;
                end
            S_CYCLE_1: begin
				    Enable = 1'b1; 
					 plot = 1'b1;
                end
				S_CYCLE_2: begin
                Enable = 1'b0;
					 plot = 1'b1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
    
    
    always@(posedge clk)
    begin
        if(!reset_n)
            counter <= 4'd0;
        else if (Enable == 1'b1)
            counter <= counter + 1'b1;
    end // state_FFS
        
    
    always@(posedge clk)
    begin: state_FFs
        if(!reset_n)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
   
	




module datapath(input clock, input reset_n, input [6:0] y_coord, input [7:0] x_coord, input [3:0] counter, input ld_x, input ld_y, input[2:0] color_in, input change_color, output reg [7:0] x, output reg [6:0] y, output reg[2:0] color_out);

reg [7:0] o_x;
reg [6:0] o_y;
//assign color_out = color_in;
//use a mux to choose chich colour to use


always @(*)
begin
    if (reset_n == 0)
	     color_out = color_in;
	 else if(change_color == 1'b1)
	     color_out = 000;
end

always @(posedge clock)//the delayed clock for changeing x,y coord.
begin
    if (reset_n == 0)
    begin
         o_x <= 8'b0;
			o_y <= 7'b0;
    end
    else 
    begin
    if(ld_x)
        o_x <= x_coord;
    if(ld_y)
        o_y <= y_coord;
    end

end

// ALU
always @(*)
begin: ALU

	 if (reset_n == 0)
		begin
		x = 8'b0;
		y = 7'b0;
		end
    else
		begin
		x = o_x + counter[1:0];
		y = o_y + counter[3:2];
		end
end
endmodule
