module MineSweeper1(clock,reset,switch,switch1,switch2,buttons,seven0,seven1,seven2,seven3,seven4,seven5,led,keypadRow,keypadCol,DMAXRow,DMAXCol0,DMAXCol1);
//SHARED
input clock,reset,switch,switch1,switch2;
reg gameover;
reg [2:0] area;
reg [6:0] index, index1;
reg [127:0] dotImg;
reg [127:0] psbImg;
reg [127:0] mineImg = ~128'heeee_eeee_8848_8e4e_8e4e_8248_eeee_eeee;

//BUTTON
input [3:0]buttons;
reg flagButton;
reg [24:0]delayButton;	
always@(posedge clock)
begin
	if(!reset || (!switch && gameover))
	begin
		area = 3'd0;
		flagButton = 1'b0;
		delayButton = 25'd0;
	end
	else if(switch && !gameover)
	begin
		if((buttons != 4'b1111)&&(!flagButton)) flagButton = 1'b1;
		else if(flagButton)
		begin
			delayButton = delayButton + 1'b1;
			if(delayButton == 25'b1010000000000000000000000)
			begin
				flagButton = 1'b0;
				delayButton = 25'd0;
				case(buttons)
					4'b1110:	if(area%4!=3) area = area+3'd1;
					4'b1101:	if(area%4!=0) area = area-3'd1;
					4'b1011:	if(area/4==0) area = area+3'd4;
					4'b0111:	if(area/4==1) area = area-3'd4;
					default: ;
				endcase
			end
		end
	end
end

//KeyPad
input [3:0] keypadCol;
output[3:0] keypadRow;	
reg 	[3:0] keypadRow;
reg 	[24:0]keypadDelay;
always@(posedge clock)
begin
	if(!reset || (!switch && gameover))
	begin
		gameover = 0;
		keypadRow = 4'b1110;
		keypadDelay = 25'd0;
		dotImg = 128'b0;
		psbImg = 128'b0;
	end
	else if(gameover)	dotImg = ((dotImg ^ mineImg)==~128'b0)? dotImg: ~(128'b0);
	else if(switch)
	begin
		if(keypadDelay == 25'd1000000)
		begin
			keypadDelay = 25'd0;
			case({keypadRow, keypadCol})
				8'b1110_1110 : index1 = index-7'd51;
				8'b1110_1101 : index1 = index-7'd50;
				8'b1110_1011 : index1 = index-7'd49;
				8'b1110_0111 : index1 = index-7'd48;
				8'b1101_1110 : index1 = index-7'd35;
				8'b1101_1101 : index1 = index-7'd34;
				8'b1101_1011 : index1 = index-7'd33;
				8'b1101_0111 : index1 = index-7'd32;
				8'b1011_1110 : index1 = index-7'd19;
				8'b1011_1101 : index1 = index-7'd18;
				8'b1011_1011 : index1 = index-7'd17;
				8'b1011_0111 : index1 = index-7'd16;
				8'b0111_1110 : index1 = index-7'd03;
				8'b0111_1101 : index1 = index-7'd02;
				8'b0111_1011 : index1 = index-7'd01;
				8'b0111_0111 : index1 = index-7'd00;
				default : ;					
			endcase
			if(keypadCol<4'b1111)
				if(switch1) psbImg[index1]<=1;	
				else if(switch2 || !psbImg[index1]) dotImg[index1]<=1;
			case(keypadRow)
				4'b1110 : keypadRow = 4'b1101;
				4'b1101 : keypadRow = 4'b1011;
				4'b1011 : keypadRow = 4'b0111;
				4'b0111 : keypadRow = 4'b1110;
				default: keypadRow = 4'b1110;
			endcase
		end
		else	keypadDelay = keypadDelay + 1'b1;
		if((mineImg & dotImg)!=128'd0 || (mineImg ^ dotImg)==~128'd0)	gameover<=1;
	end
end

//TIMER
output[6:0] seven0,seven1,seven2,seven3,seven4,seven5;
reg 	[31:0]count, elapsedTime;
reg 	[3:0] seven[5:0];
Sevensegment segment1(.in(seven[0]),.out(seven0));
Sevensegment segment2(.in(seven[1]),.out(seven1));
Sevensegment segment3(.in(seven[2]),.out(seven2));
Sevensegment segment4(.in(seven[3]),.out(seven3));
Sevensegment segment5(.in(seven[4]),.out(seven4));
Sevensegment segment6(.in(seven[5]),.out(seven5));
always@(posedge clock)
begin
	if(!reset || (!switch && gameover))
	begin
		count <= 32'd0;
		elapsedTime <= 32'd0;
		seven[5]=0; seven[4]=0; seven[3]=0; seven[2]=0; seven[1]=0; seven[0]=0;
	end
	else
	begin
		if(gameover && (mineImg ^ dotImg)!=~128'd0)
		begin
			seven[5]=8; seven[4]=8; seven[3]=8; seven[2]=8; seven[1]=8; seven[0]=8;
		end
		else if(switch && !gameover)
		begin
			if(count == 32'd50000000)
			begin
				count <= 32'd0;
				elapsedTime <= elapsedTime + 32'd1;
				seven[0] = elapsedTime%10;
				seven[1] = elapsedTime%60/10;
				seven[2] = elapsedTime/60%10;
				seven[3] = elapsedTime/60%60/10;
				seven[4] = elapsedTime/3600%10;
				seven[5] = elapsedTime/3600%100/10;
			end
			else count = count + 32'd1;
		end
	end
end

//DotMatrix
output[7:0]DMAXCol0, DMAXCol1, DMAXRow;
reg 	[7:0]DMAXCol0, DMAXCol1, DMAXRow;	
reg 	[24:0] DMAXDelay;
always@(posedge clock)
begin
	if(!reset)
	begin
		DMAXRow = 8'b1111_1111;
		DMAXCol0 = 8'b0000_0000;
		DMAXCol1 = 8'b0000_0000;
		DMAXDelay = 25'd0;
	end
	else
	begin
		if(DMAXDelay == 25'd1000)
		begin
			DMAXDelay = 25'd0;
			case(DMAXRow)
				8'b1111_1110:DMAXRow = 8'b1111_1101;
				8'b1111_1101:DMAXRow = 8'b1111_1011;
				8'b1111_1011:DMAXRow = 8'b1111_0111;
				8'b1111_0111:DMAXRow = 8'b1110_1111;
				8'b1110_1111:DMAXRow = 8'b1101_1111;
				8'b1101_1111:DMAXRow = 8'b1011_1111;
				8'b1011_1111:DMAXRow = 8'b0111_1111;
				8'b0111_1111:DMAXRow = 8'b1111_1110;
				default: DMAXRow = 8'b1111_1110;
			endcase
			case(DMAXRow)				
				8'b0111_1111:{DMAXCol1,DMAXCol0} = dotImg[127:112];
				8'b1011_1111:{DMAXCol1,DMAXCol0} = dotImg[111:96];
				8'b1101_1111:{DMAXCol1,DMAXCol0} = dotImg[95:80];
				8'b1110_1111:{DMAXCol1,DMAXCol0} = dotImg[79:64];
				8'b1111_0111:{DMAXCol1,DMAXCol0} = dotImg[63:48];
				8'b1111_1011:{DMAXCol1,DMAXCol0} = dotImg[47:32];
				8'b1111_1101:{DMAXCol1,DMAXCol0} = dotImg[31:16];
				8'b1111_1110:{DMAXCol1,DMAXCol0} = dotImg[15:0];
				default: {DMAXCol1,DMAXCol0} = 16'h0000;
			endcase
		end
		else DMAXDelay = DMAXDelay + 1'b1;
	end
end

//LED & index
output [7:0]led;			
reg [7:0]led;
always@(area)
begin
	if(gameover) led = 8'b11111111;
	else
	begin
		case(area)
		3'd0:	begin	led=8'b10000000;	index<=7'd127;	end
		3'd1:	begin	led=8'b01000000;	index<=7'd123;	end
		3'd2:	begin	led=8'b00100000;	index<=7'd119;	end
		3'd3:	begin	led=8'b00010000;	index<=7'd115;	end
		3'd4:	begin	led=8'b00001000;	index<=7'd063;	end
		3'd5:	begin	led=8'b00000100;	index<=7'd059;	end
		3'd6:	begin	led=8'b00000010;	index<=7'd055;	end
		3'd7:	begin	led=8'b00000001;	index<=7'd051;	end
		endcase
	end
end

endmodule

module SevenSegment(in,out);
	input [3:0]in;
	output [6:0]out;
	reg [6:0]out;
	always@(in)
	begin
		case(in)
		4'd0:out <= 7'b1000000;
		4'd1:out <= 7'b1111001;
		4'd2:out <= 7'b0100100;
		4'd3:out <= 7'b0110000;
		4'd4:out <= 7'b0011001;
		4'd5:out <= 7'b0010010;
		4'd6:out <= 7'b0000010;
		4'd7:out <= 7'b1111000;
		4'd8:out <= 7'b0000000;
		4'd9:out <= 7'b0010000;
		default:out <= 7'b1000000;
		endcase
	end
endmodule
