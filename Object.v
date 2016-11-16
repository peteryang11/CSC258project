// This is the module that will allow us to create a single object.

module datapath(refresh, clock_50, resetn, x, y, color);
input clock_50;
input resetn;
reg [2:0] clr;
output [2:0] color;

localparam	TestObject1_X = 8'd0,
		TestObject1_Y = 7'd0,
		TestObject1_C = 3'b111,
		TestObject2_X = 8'd160,
		TestObject2_Y = 7'd120,
		TestObject2_C = 3'b111,
		PlayerObject_X = 8'd79,
		PlayerObject_Y = 7'd110,
		PlayerObject_C = 3'b100,
		Initial = 13'd0;
		T_end = 13'd8192,
		P_end = 9'd512;

reg [7:0] 	T1_X = TestObject1_X;
reg [7:0] 	T2_X = TestObject2_X;
reg [7:0] 	P_X = PlayerObject_X;
reg [8:0] 	T1_Y = TestObject1_Y;
reg [8:0] 	T2_Y = TestObject2_Y;
reg [8:0] 	P_Y = PlayerObject_Y;

reg [12:0] 	size;
reg [12:0] 	size_end;	//Along with paint_state to store corresponding counter.
reg [3:0] 	paint_state; 	//Record the paint state. 
				//Just in case we want to paint all 
				//the object on the screen.

output reg [7:0] x;
output reg [6:0] y;

always @(posedge clock_50)
begin
    	if(!reset_n) begin
		x <= T1_X;
		y <= T1_y;
		paint_state <= 4'b0;
		size <= Initial;
		size_end <= T_end;
	end
	else begin
		if(paint_state != 2) begin// 2 is the state that we need to paint the Player.
			if(size != size_end) begin
				x <= x_init + size[7:0];
				y <= y_init + size[10:8];
				clr <= color;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial;
				paint_state <= paint_state + 1;
			end
		end
		else
			
			
	end
end
endmodule

module AutoControl(clock, resetn, direction);
