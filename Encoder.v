module ENCODER 
(
input wire clk,rst,
//input [3:0] modulation_type,
output wire [15:0] din,
output reg start_mapper,
output reg [4:0] address_A,address_B,address_C,address_D,
input wire [7:0] ram_output_B,
input wire wea_Encoder_1
//output reg [15:0] ram_output
//output  wire[31:0] IQ
//output wire done,done_mapper
);
reg wea_Encoder;
assign wea_Encoder_1=wea_Encoder;
//wire [4:0] address_D;
reg [3:0] modulation_type;


localparam [1:0] Idle=2'b00 , Fetch=2'b01, Encoding=2'b10, Done_encoding=2'b11;  
//encoder registers
reg start=1;
reg [1:0] state0=0;
reg [7:0] input_bits;
reg done,done_mapper;
//reg [15:0] encoded_bits;
reg [15:0] RAM_in,encoded_bits;
reg address=0;
//reg [4:0] address_A,address_B=0,address_C=0,address=0;
reg [5:0] shift_reg=0;
reg [4:0] N=0,M=0;
//wire [7:0] ram_output_B;
reg encoder_ready;

assign din= RAM_in;

/*Mapper Mapper_instant(
.clk(clk),
 .rst(rst),
.modulation_type(modulation_type),
.ram_output(ram_output),
.address_D(address_D),
.start_mapper(start_mapper),
.done(done),
.done_mapper(done_mapper),
.IQ(IQ)
);*/


/*Received_Bits your_RAM0 (
  .clka(clk), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(address_A), // input [3 : 0] addra
  .dina(dina), // input [7 : 0] dina
  .clkb(clk), // input clkb
  .addrb(address_B), // input [3 : 0] addrb
  .doutb(ram_output_B) // output [7 : 0] doutb
);

Encoded_Bits your_RAM1 (
  .clka(clk), // input clka
   .wea(wea_Encoder), // input [0 : 0] wea
  .addra(address_C), // input [3 : 0] addra
  .dina(RAM_in), // input [15 : 0] dina
  .clkb(clk), // input clkb
  .addrb(address_D), // input [3 : 0] addrb
  .doutb(ram_output) // output [15 : 0] doutb
);
*/


always @(posedge clk)
begin
	if(rst==1)
		begin
			N<=0;
			M=0;
			address_A<=0;
			address_B<=0;
			address_C<=0;
			address<=0;
			start_mapper<=0;
			encoder_ready<=0;
			wea_Encoder<=0;
			state0<=Idle;
		end
	else

case(state0)

Idle: //idle
	begin
		if (start==1)
			begin
				state0<=Fetch;
				wea_Encoder<=1;
			end
		else 
			state0<=Idle;
	end


Fetch: //fetch
	begin
		input_bits<=ram_output_B;
		address_B<=address_B+1;
		address_C<=address;
		N<=0;
		M=0;
		encoded_bits=0;
		state0<=Encoding;
	end


Encoding: //Encoding
	begin
		encoded_bits[M]= ((((input_bits[N]~^shift_reg[4])~^(shift_reg[3]))~^(shift_reg[1]))~^(shift_reg[0]));
		M=M+1;
		encoded_bits[M]= ((((input_bits[N]~^shift_reg[5])~^(shift_reg[4]))~^(shift_reg[3]))~^(shift_reg[0]));
		shift_reg={input_bits[N],shift_reg[5:1]};
		M=M+1;
		N<=N+1;
		
		if(N==7)
			begin
				RAM_in<=encoded_bits;
				address<=address+1;
				if(address_B==15)
					begin
					state0<=Done_encoding;
					end 
					else
						begin
							state0<=Fetch;
						end
			end
			else
				begin
					state0<=Encoding;
				end
end


Done_encoding:
	begin
		wea_Encoder<=0;
		start_mapper<=1;
		encoder_ready<=1;
	end
endcase
end
endmodule
