`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:51:13 02/10/2021 
// Design Name: 
// Module Name:    Mapper 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Mapper(
input wire clk,start_mapper,rst,
//input wire [3:0] modulation_type, 
input wire [15:0] ram_output,
output reg [8:0] rom_adress,
//output [15:0] I,Q,
//output reg [31:0] IQ,
output reg done=0,done_mapper=0
    );
 

localparam [2:0] idle_state=3'b000 , data_fetch=3'b001 , processing=3'b010,mapping=3'b011,data_ready=3'b100,Done_mapping=3'b101;


//mapper registers
reg [15:0] I,Q; 
reg [4:0] address_D=0;
reg [3:0] modulation_type;
reg [7:0] modulation_bits;
reg [7:0 ]mod_reg=0;
reg [15:0] ram_reg;
reg sin=0;
reg [3:0]adress = 4'd0;
reg [4:0]bit_counter=0;
reg [2:0]state=0;
reg [3:0] mod_counter=0;
//wire [15:0] ram_output;
//reg  [8:0] rom_adress;
reg enable_ifft=0;



always @( posedge clk, posedge rst) begin
if( rst ) begin
state <= idle_state;
bit_counter=0;
mod_reg<=0;
mod_counter=0;
rom_adress<=0;
address_D<=0;
done<=0;
end
else
begin
case( state )
 
idle_state:
	begin  //idle
		if(start_mapper==1 )  
			begin
			state <= data_fetch;
			ram_reg<=0;
			end
	end
	
data_fetch:
	begin  //fetch
		bit_counter=0;
		ram_reg <=ram_output;
		address_D <= address_D+1;	
		state <= processing;	 
	end
 			
processing:
	begin
		ram_reg<= { sin , ram_reg[15:1]};
		mod_reg<={mod_reg[6:0],ram_reg[0]};
		bit_counter=bit_counter+1;
		mod_counter=mod_counter+1; 
			if( bit_counter==16)
				begin
					if (mod_counter==modulation_type) 
					state <= mapping;
					else
						state <= data_fetch;
				end
			else
				begin
					if (mod_counter==modulation_type)
						begin
							state<=mapping;
							mod_counter=0;
						end
						else
						state<=processing;
						end 
						end
	
mapping:
	begin
	   done<=1;
	  // IQ<={I,Q};
		modulation_bits=mod_reg;
		mod_reg<=0;
		mod_counter=0;
		state<=data_ready;
		
case(modulation_type)
4'b001:
begin
rom_adress<=modulation_bits;
end
4'b0010: begin
rom_adress<=modulation_bits+2;   end
4'b0011: begin
rom_adress<=modulation_bits+6;   end
4'b0100: begin
rom_adress<=modulation_bits+14;  end
4'b0101: begin
rom_adress<=modulation_bits+30;  end
4'b0110: begin
rom_adress<=modulation_bits+62;  end
4'b0111: begin
rom_adress<=modulation_bits+126; end
4'b1000: begin
rom_adress<=modulation_bits+254; end
endcase end
	 
data_ready:
	begin
		done<=0;
		if( bit_counter==16)
			begin
				if(address_D==15)
					begin
					state <= data_ready;
					done_mapper<=1;
					end
					else
					state <= data_fetch;
			end
		else
			state <= processing;
		end
 default: 
    begin
          state <= idle_state;
    end
    endcase
    end
	 end


/*XI your_ROM_I (
  .clka(clk), // input clka
  .addra(rom_adress), // input [8 : 0] addra
  .douta(I) // output [15 : 0] douta
);

XQ your_ROM_Q (
  .clka(clk), // input clka
  .addra(rom_adress), // input [8 : 0] addra
  .douta(Q) // output [15 : 0] douta
);
*/

endmodule
