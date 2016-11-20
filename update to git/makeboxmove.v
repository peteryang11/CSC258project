
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
		VGA_B,   						//	VGA Blue[9:0]
		LEDR
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
	output	[9:0] LEDR;
	
	
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;//the wire connect datapath and VGA
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	assign LEDR[7:0] = x[7:0];

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
			

    wire ld_x, ld_y, updateenable;
    wire [3:0] drawcounter;
	 wire [2:0] colour_in;

    // Instansiate datapath
    datapath d0(.clock(CLOCK_50), .reset_n(resetn), .drawcounter(drawcounter), .ld_x(ld_x), .ld_y(ld_y), .color_in(colour_in), .updateenable(updateenable),.x(x), .y(y), .color_out(colour));

    // Instansiate FSM control
    control c0(.clk(CLOCK_50), .reset_n(resetn), .drawcounter(drawcounter), .ld_x(ld_x), .ld_y(ld_y), .plot(writeEn), .colour_in(colour_in),.updateenable(updateenable));
endmodule    

module control(input clk, input reset_n, output reg [3:0] drawcounter, output reg ld_x, output reg ld_y, output reg plot, output reg[2:0] colour_in, output reg updateenable);

reg drawenable, delayenable, framenable;
reg [5:0] current_state, next_state;
reg [19:0] delaycounter;
reg [5:0] framcounter;


localparam      S_LOAD_XY        = 3'd0,
                S_LOAD_XY_WAIT   = 3'd1,
                S_CYCLE_0        = 3'd2,
                S_CYCLE_0_WAIT   = 3'd3,
                S_CYCLE_1        = 3'd4,
					 S_CYCLE_1_WAIT   = 3'd5,
                XY_UPDATE        = 3'd6;
					     
		
always @(*)
begin: state_table 
    case (current_state)
	S_LOAD_XY: next_state = S_LOAD_XY_WAIT; 
	S_LOAD_XY_WAIT: next_state = S_CYCLE_0; 
	
	S_CYCLE_0: next_state = (drawcounter == 4'b1111) ? S_CYCLE_0_WAIT : S_CYCLE_0;// draw box with colour1
	S_CYCLE_0_WAIT: next_state = (delaycounter == 20'd4 )? S_CYCLE_1:S_CYCLE_0_WAIT;
	//S_CYCLE_0_WAIT: next_state = (delaycounter == 20'd833333 )? S_CYCLE_1:S_CYCLE_0_WAIT;
	S_CYCLE_1: next_state = (drawcounter == 4'b1111) ? S_CYCLE_1_WAIT : S_CYCLE_1;//draw box with colour2(erase)
	S_CYCLE_1_WAIT: next_state = (framcounter == 5'd4) ? XY_UPDATE: S_CYCLE_1_WAIT; //speed:4pixel/second, control the moving speed of box
	XY_UPDATE: next_state = S_LOAD_XY;
	default:     next_state = S_LOAD_XY;
    endcase
end // state_table
		

always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
        drawenable = 1'b0;
		  delayenable = 1'b0; // enable to count 50M/60
		  framenable = 1'b0 ; // enable to count speed X 50M/60
		  updateenable = 1'b0; //enable to change coord of X Y
        plot = 1'b0; 
		
        case (current_state)
            S_LOAD_XY: begin
                ld_x = 1'b1;
					 ld_y = 1'b1;
		          updateenable = 1'b0;
					
                end
            S_LOAD_XY_WAIT: begin
                ld_y = 1'b0;
					 ld_x = 1'b0;
                end
            S_CYCLE_0: begin
				    
                drawenable = 1'b1;
					 colour_in = 3'b111;
		          plot = 1'b1;
                end
				S_CYCLE_0_WAIT: begin
				    drawenable = 1'b0;
					 delayenable = 1'b1;
		          plot = 1'b0;
                end
            S_CYCLE_1: begin
				    drawenable = 1'b1;
				    delayenable = 1'b0;
					 colour_in = 3'b000;//erase with black
					 updateenable = 1'b1;
					 plot = 1'b1;
                end
				S_CYCLE_1_WAIT: begin
				    delayenable = 1'b1;
                framenable = 1'b1 ;
					 drawenable = 1'b0;
					 plot = 1'b10;
                end
					 
				XY_UPDATE: begin
				    updateenable = 1'b1;
				    delayenable = 1'b0;
		          framenable = 1'b0; 
					 end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
    
    
    always@(posedge clk)
    begin
        if(!reset_n)
            drawcounter <= 4'd0;
        else if (drawenable == 1'b1)
            drawcounter <= drawcounter + 1'b1;
    end // state_FFS
        
    
	 always@(posedge clk)
    begin
        if(!reset_n)
            delaycounter <= 20'd0;
        else 
	begin
	if (delayenable == 1'b1)
            delaycounter <= delaycounter + 1'b1;
	if (delaycounter == 20'd4)
	//(delaycounter == 20'd833333)
	    delaycounter <= 20'd0;
	if (delayenable == 1'b0)
	    delaycounter <= 20'd0;
	end
    end // state_FFS
	 
	 always@(posedge clk)
    begin
        if(!reset_n)
            framcounter <= 5'd0;
        else 
		  begin
		  if (framenable == 1'b1 & delaycounter == 20'd4)
		  //(framenable == 1'b1 & delaycounter == 20'd833333)
            framcounter <= framcounter + 1'b1;
		  if (framenable == 1'b0)
		      framcounter <= 5'd0;
			end
    end // state_FFS
        
    always@(posedge clk)
    begin: state_FFs
        if(!reset_n)
            current_state <= S_LOAD_XY;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
   

module datapath(
input clock, 
input reset_n, 
input [3:0] drawcounter, 
input ld_x, 
input ld_y, 
input[2:0] color_in, 
input updateenable, 
output reg [7:0] x, 
output reg [6:0] y, 
output [2:0] color_out);

reg [7:0] o_x;
reg [6:0] o_y;
reg [6:0] y_coord; 
reg [7:0] x_coord; 

assign color_out = color_in;
//use a mux to choose chich colour to use


//always @(*)
//begin
//    if (reset_n == 0)
//	     color_out = color_in;
////	 else begin 
////	 if(change_color == 1'b1)
////	     color_out = 3'b100;
////	 else
////		  color_out = 3'b111;
////	 end
//end


// update x,y coord 
//always @(posedge clock)
//begin
    //if(!reset_n) begin
	     //x_coord <= 8'd0;
	 //end
	 //else if (updateenable == 1) 
	     //x_coord <= x_coord + 8'd4;

//end


//always @(posedge clock)
//begin
    //if(!reset_n) begin
	     //y_coord <= 8'd50;
	 //end
	 //else if (updateenable == 1) 
	     //y_coord <= y_coord ;
//end

// direction update
always @(posedge clock)
begin
    if (reset_n == 0)
    begin
         x_coord <= 8'b0;
	 y_coord <= 7'd50;
    end
    else if(updateenable == 1)
    begin
         x_coord <= x_coord + 1'b1;
         y_coord <= y_coord ;
    end
end

//如果是用key控制
//x_coord <= x_coord + dir_x;

//reg dir_x, dir_y;
//always @(*)
//begin
//case(KEY[2:0])

//KEY[2]: dir_y = 1'b1;
//KEY[1]: dir_x = 1'b1;
//KEY[3]: dir_x = -1;
//endcase
//end

always @(posedge clock)
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
		x = o_x + drawcounter[1:0];
		y = o_y + drawcounter[3:2];
		end
end
endmodule
