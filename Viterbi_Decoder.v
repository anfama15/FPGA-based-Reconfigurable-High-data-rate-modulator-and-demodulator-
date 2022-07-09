`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:44:36 02/09/2021 
// Design Name: 
// Module Name:    Viterbi_Decoder 
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
module Viterbi_Decoder
(
	//input signed [15:0] Yi,Yq,
	input wire clk,
	input wire reset,
	input wire start_decoder,
	input wire signed [7:0] demapped_out,
   output reg [5:0] addr_F,
	output reg [119:0] d_bits   //decoded_bits
);


localparam [2:0] Idle_decoder=3'b000 , Addressing_trellis=3'b001 , Hamming_calculation=3'b010,
					  Start_backward=3'b011, Delay=3'b100, Backward_process=3'b101,
					  Done_decoder=3'b110;

reg [7:0] NOB=120;//no of bits to decode

//DECODER REGISTERS AND WIRES
		reg [7:0] bits;
		reg [25:0] dina;//for storing hamming distance and state number in RAM1

	//Ram and Rom output wires
		wire [11:0] douta;//output of rom0
		wire [23:0]ram0_out0,ram0_out1;//output of ram0
		wire [31:0] ROM1_OUT;//output of rom1

	//Counters
		reg [6:0] K,L;// for ram1 
		reg [6:0] T,N=2; // T is counter for every time instant ,N counter is use in increment of received bits
	//states
		reg [3:0]substate, state1;

	//hamming distance registers 
		reg [7:0] D_cal0,D_cal1; //distance _calculator 0,1 is use to take difference from input bits and rom0 trells bits
		reg [7:0] rev_dis0,rev_dis1;//these register use in reverse or back process, reverse distace 0,1 compare 2 distance,state checker check state

	//RAM1
		reg [7:0] ram1[0:63]; //this ram is use for comparing 2 old distance
 
	//registers for calculation
		reg p=0; //wea for write enable and register p for taking and. 
		reg [11:0] r_data;
		reg [15:0] psdata=0; //previous state hamming data
		reg [7:0] s_checker; //checking state in forward and reverse process
	//addresses
		reg [13:0]address1=0;
		reg [7:0] addra;//for rom0
		reg [15:0] addr_A,addr_B=0;//ram0
		reg [5:0] addr_C;//rom1
     
	  
	   reg wea,web;
		//wire [7:0]demapped_out;



/*Hamming_Distance your_Ram0 (
  .clka(clk), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(addr_A), // input [15 : 0] addra
  .dina(dina), // input [25 : 0] dina
  .douta(ram0_out0), // output [25 : 0] douta
  .clkb(clk), // input clkb
  .web(web), // input [0 : 0] web
  .addrb(addr_B), // input [15 : 0] addrb
  .dinb(dinb), // input [25 : 0] dinb
  .doutb(ram0_out1) // output [25 : 0] doutb
);

Trellis_bits your_trellis_bits (
  .clka(clk), // input clka
  .addra(addra), // input [5 : 0] addra
  .douta(douta) // output [11 : 0] douta 
  );

Back_Address your_backward_addresses (
  .clka(clk), // input clka
  .addra(addr_C), // input [5 : 0] addra
  .douta(ROM1_OUT) // output [31 : 0] douta
);

*/




always @(posedge clk)
	begin  
	if (reset)
	begin
	T<=0;
	addra<=0;
	addr_F<=1;
	addr_B=0;
	K=0;
	state1<=Idle_decoder;
	
	end
	else 
	begin
	 state1<=Idle_decoder;

case(state1)

Idle_decoder: begin

	if(start_decoder)
		begin
		addra<=0;
		addr_F<=1;
		addr_A=1;
		addr_B=0;
		address1=0;
		T<=0;
		N=2;
		wea=1;
		web=0;
		ram1[K]=8'b11111;
		dina=0;
		p=0;
		psdata=0;
		substate<=0;
		state1<=Addressing_trellis;
	   end
	else
		begin
		state1<=Idle_decoder;
		end end

Addressing_trellis:
	begin
   K=0;//setting counters to zero
	L=0;
	addra<=addra+1;
	state1<=Hamming_calculation;
	end

Hamming_calculation: begin
	
	bits=demapped_out;
	r_data=douta;//moving rom0 trellis diagram bits to register
	psdata=ram0_out1[15:0];//previous hamming distance

	
	if(p==0)// this is for shifting. 
		begin
		psdata={8'd0,psdata[15:8]};
		end
	else
		begin
		addr_B=addr_B+1;
		end
		p=~p; 

	if(psdata[7:0]>ram1[K]) //now camparing 2 previous distance and taking smaller to get next state hamming distance.
		begin 
		D_cal0=ram1[K]+ ((bits[N-2])^(r_data[0]))+((bits[N-1])^(r_data[1]));    
		D_cal1=ram1[K]+((bits[N-2])^(r_data[2]))+((bits[N-1])^(r_data[3]));
		end
	else                           
		begin 
		D_cal0=psdata[7:0]+((bits[N-2])^(r_data[0]))+((bits[N-1])^(r_data[1]));    
		D_cal1=psdata[7:0]+((bits[N-2])^(r_data[2]))+((bits[N-1])^(r_data[3]));
		end    
		
	addr_A=address1;
	dina={(r_data[11:4]),(D_cal1),(D_cal0)};// storing distance in ram.
	s_checker=r_data[11:4];
   address1=address1+1;


	if(K>31)//storing odd hamming distance,which is from 32-63
		begin
		ram1[L]=D_cal0;
		L=L+1;  
		ram1[L]=D_cal1;
		L=L+1;
		end
		else
		begin
		//ram1[K]=8'b11111111;
		end
   K=K+1;
	

//now we have substates.all states will open when t>6
	case(substate)//for 2 hamming distance

	4'b0000:
		begin
		T<=T+1;
		N=N+2;
		addra<=0;
		addr_B=0;
		address1=address1+63;
		ram1[K]=8'b11111111;
		state1<=Addressing_trellis;
		substate<=4'b0001;
		end

	4'b0001://for 4 hamming distance
		begin
		if(addra==2)
			begin
			T<=T+1;
			N=N+2;
			addra<=0;
			addr_B=addr_B+63;
			address1=address1+62;
			state1<=Addressing_trellis;
			substate<=4'b0010;
			end
		else
			begin
			addra<=addra+1;
			ram1[K]=8'b11111111;
			state1<=Hamming_calculation;
			end end

	4'b0010://for 8 hamming distance
		begin
		if(addra==4)
			begin
			T<=T+1;
			N=N+2;
			addra<=0;
			addr_B=addr_B+62;
			address1=address1+60;
			state1<=Addressing_trellis;
			substate<=4'b0011;end
		else
			begin
			addra<=addra+1;
			ram1[K]=8'b11111111;
			state1<=Hamming_calculation;
			end end


	4'b0011://for 16 hamming distance
		begin
		if(addra==8)
			begin
			T<=T+1;
			N=2;
			addra<=0;
			addr_F<=addr_F+1;	
			address1=address1+56;
			addr_B=addr_B+60;
			state1<=Addressing_trellis;                   
			substate<=4'b0100;
			end
		else
			begin
			addra<=addra+1;   
			ram1[K]=8'b11111111;
			state1<=Hamming_calculation;                        
			end end


	4'b0100://for 32 hamming distance
		begin
		if(addra==16)
			begin
			T<=T+1;
			N=N+2;
			addra<=0;
			address1=address1+48;
			addr_B=addr_B+56;
			state1<=Addressing_trellis;  
			substate<=4'b0101;end
		else
			begin
			addra<=addra+1;
			ram1[K]=8'b11111111;
			state1<=Hamming_calculation;
			end end


	4'b0101: //for 64 hamming distance
		begin
		if(addra==32)
			begin
			T<=T+1;
			N=N+2;
			addra<=0;
			address1=address1+32;
			addr_B=addr_B+48;
			state1<=Addressing_trellis;
			substate<=4'b0110;
			end
		else
			begin
			addra<=addra+1;
			ram1[K]=8'b11111111;
			state1<=Hamming_calculation;
			end end 


	4'b0110://for 128 hamming distance
		begin
		if(addra==64)//At some time instant all state hamming distance is calculated.than it sets to zero for next time instant 
			begin
			if(T>(NOB-2)) // if no of bits to decode is less than time T
				begin
				N=N+2;//a counter for increment in received bits
				addr_B=addr_A;
				state1<=Start_backward;
				end
			else
				begin
				T<=T+1; 
				N=N+2;//a counter for increment in received bits
				addra<=0;
				addr_B=addr_B+32;
				state1<=Addressing_trellis;
				end	end
		else
			begin
			addra<=addra+1;
			state1<=Hamming_calculation;
			end	end

		endcase

	if(N==10)
		begin 
		N=2;
		addr_F<=addr_F+1;
		end end



Start_backward://for giving start of backward process
	begin
	wea=0;
	addr_A=addr_A-63;
	addr_B=addr_A+32;
	addr_C=0;
	state1<=Delay;
	end  

Delay://this state for wait to get ram data
	begin
	state1<=Backward_process;
	end


Backward_process:
	begin
	//s_checker=addr_C;
	if (addr_C>31)//we stored 2 distance at one ram address ,selecting one .if states is less than 32 our decoded bit will be zero.
		begin
		rev_dis0=ram0_out0[15:8];
		rev_dis1=ram0_out1[15:8];
		d_bits[T]=1'b1;
		end 
	else
		begin
		d_bits[T]=1'b0;
		rev_dis0=ram0_out0[7:0];
		rev_dis1=ram0_out1[7:0];
		end
 
	if(rev_dis1<rev_dis0)//for setting ram distance 
		begin
		addr_C=ram0_out1[23:16];
		addr_A=addr_B-ROM1_OUT[23:16];
		addr_B=addr_B-ROM1_OUT[31:24];
		end
	else 
		begin 
		addr_C=ram0_out0[23:16];
		addr_B=addr_A-ROM1_OUT[15:8];
		addr_A=addr_A-ROM1_OUT[7:0];
		end

	s_checker=addr_C;
	if(T==0) //if time t is zero than all bits is decoded.
		begin
		state1<=Done_decoder;
		end
	else 
		begin
		T<=T-1;
		state1<=Delay;
		end end

Done_decoder:
	begin
	state1<=Done_decoder;
	end


endcase 
end
end
endmodule

