// This is the module that will allow us to create a single object.

module datapath(refresh, clock_50, resetn, x, y, color, direction);
input clock_50;
input resetn;
input [2:0] direction; // This is the input of user. where 0, 1, 2 are corresponding to left, forward, right for the player object.
reg [2:0] clr;
output [2:0] color;

localparam	TestObject1_X = 8'd0,
		TestObject1_Y = 7'd0,
		TestObject2_X = 8'd160,
		TestObject2_Y = 7'd120,
		TestObject_C = 3'b111,
		PlayerObject_X = 8'd79,
		PlayerObject_Y = 7'd110,
		PlayerObject_C = 3'b100,
		Initial = 13'd0;
		T_end = 13'd8192,
		P_end = 9'd512;

reg [7:0] 	T1_X = TestObject1_X;
reg [6:0] 	T1_Y = TestObject1_Y;
reg [7:0]	T2_X = TestObject2_X;
reg [6:0]	T2_Y = TestObject2_Y;
reg [7:0] 	P_X = PlayerObject_X;
reg [6:0] 	P_Y = PlayerObject_Y;

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
				clr <= TestObject_C;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial;
				paint_state <= paint_state + 1;
			end
		end
		else if(paint_state == 4'd1) begin // The default state is the state to paint the player.
			if(size != size_end) begin
				x <= T2_X + size[7:0];
				y <= T2_Y + size[11:8];
				clr <= TestObject_C;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial;
				size_end <= P_end;
				paint_state <= paint_state + 1;
			end
		end
		else begin // The default state is the state to paint the player.
			if(size != size_end) begin
				x <= P_X + size[3:0];
				y <= P_Y + size[7:4];
				clr <= PlayerObject_C;
				size <= size + 1'b1;
			end
			else begin
				size <= Initial; //This may need to be changed.
				size_end <= P_end;
			end
		end
	end
end

always @(direction) // This is just an idea, not gonna work.
begin
	if(!direction[2]) P_Y = P_Y - 4'd4;
	else if(!direction[1]) P_X = P_X + 4'd4;
	else if(!direction[0]) P_Y = P_Y + 4'b4;
end

always @(posedge fresh) // This block is going to repaint the whole screen to black, then assign new value to each X Y of those test objects.
begin

end

endmodule

module AutoControl(clock, resetn, direction);

