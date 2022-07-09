
module demapper
(
	//input wire signed [15:0] Yi,Yq,
	input wire signed [31:0] data_in,
	//input [8:0] mod_type,
	input  wire clk,
	input  wire reset,
	input  wire start,
	output reg start_decoder,
	output reg [7:0] demapped_out
 );
        reg [15:0] Yi,Yq;
		reg [3:0] mod_type;
		reg [7:0] output_bits; //demapper_output_bits
      wire [5:0] addr_F; 
      reg[31:0] Yi_Yq;
      
assign data_in=Yi_Yq;
//assign Yi=Yi_Yq[31:16];
//assign Yq=Yi_Yq[15:0];

/*Viterbi_Decoder decoder_instants(
.clk(clk),
.reset(reset),
.start_decoder(start_decoder),
.demapped_out(demapped_out),
.addr_F(addr_F)
);
*/
localparam [2:0] Idle_demapper=3'b000 , Fetch_data=3'b001 , Process0=3'b010,
					  Process1=3'b011, Clearing_tail=3'b100, Demapping=3'b101,
					  Storing=3'b110,Done_demapping=3'b111;
 



//	REGISTERS AND WIRES USED IN DEMAPPER

	//State
		reg [3:0]state;
	//Modulation registers
		reg [9:0]mod_type_reg,mod_type_reg1,mod_type_reg2;
	//Wires for taking output from ram/rom
		wire [15:0] Xi,Xq;
		wire [7:0]binary_mapping;
		wire [15:0]I,Q;
	//	wire [7:0]demapped_out;

	//Counters
		reg [8:0] counter=0,BM_counter=0,M_counter=0;
	//For Calculation 
		reg signed [15:0] Yi_reg,Yq_reg,Xi_reg,Xq_reg;
		reg signed [7:0] binary_mapping_reg,binary_mapping_reg1,binary_mapping_reg2,binary_mapping_reg3 ;
		reg signed [31:0] Sqr_i,Sqr_q;
		reg signed [32:0] new_value=0;
		reg signed [16:0] Sub_Yi_Xi,Sub_Yq_Xq;
		reg signed [33:0] diff_new_old_0,diff_new_old_1,diff_new_old_2,diff_new_old_3,diff_new_old_4,diff_new_old_5,diff_new_old_6,diff_new_old_7;
		reg signed [32:0] reg_1_0, reg_0_0,reg_1_1, reg_0_1,reg_1_2, reg_0_2,reg_1_3, reg_0_3,reg_1_4, reg_0_4,reg_1_5, reg_0_5,reg_1_6, reg_0_6,reg_1_7, reg_0_7;
		reg signed [33:0] LLR_0,LLR_1,LLR_2,LLR_3,LLR_4,LLR_5,LLR_6,LLR_7;
	//Addresses
		reg [13:0]address;
		reg [4:0] mod_counter=0;
		reg [5:0] address_E=0; //address for storing demapped bits into ram 
      reg [8:0]address_IQ=0 ; 
	//Data_in in ram
		reg [7:0] demapped_in;

   //Demapper output bits for some I and Q
     reg [7:0] demapped_bits=0;

	//Enabling pins	
		reg wea_demapped_bits=1;
		reg wea,web; //enabler for storing Hamming distance in ram
		reg sin;





//RAM AND ROM


/*Mapped_I your_I (
  .clka(clk), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(addra), // input [4 : 0] addra
  .dina(dina), // input [15 : 0] dina
  .clkb(clk), // input clkb
  .addrb(address_IQ), // input [4 : 0] addrb
  .doutb(I) // output [15 : 0] doutb
);


Mapped_Q your_Q (
.clka(clk), // input clka
.wea(we), // input [0 : 0] wea
.addra(addra), // input [4 : 0] addra
.dina(dina), // input [15 : 0] dina
  .clkb(clk), // input clkb
  .addrb(address_IQ), // input [4 : 0] addrb
  .doutb(Q) // output [15 : 0] doutb
);


XI your_Xi (
  .clka(clk), // input clka
  .addra(address), // input [8 : 0] addra
  .douta(Xi) // output [15 : 0] douta
);

XQ our_xq (
  .clka(clk), // input clka
  .addra(address), // input [8 : 0] addra
  .douta(Xq) // output [15 : 0] douta
);

Binary_Mapping our_binary_mapping (
  .clka(clk), // input clka
  .addra(address), // input [8 : 0] addra
  .douta(binary_mapping) // output [15 : 0] douta
);


Demapped_bits your_demapped_bits (
  .clka(clk), // input clka
  .wea(wea_demapped_bits), // input [0 : 0] wea
  .addra(address_E), // input [4 : 0] addra
  .dina(demapped_in), // input [7 : 0] dina
  .clkb(clk), // input clkb
  .addrb(addr_F), // input [4 : 0] addrb
  .doutb(demapped_out) // output [7 : 0] doutb
);
*/

//DEMAPPER CODE

always @(posedge clk)
	begin
		if(reset)
			begin
			//address<=0;
			counter<=0;
			binary_mapping_reg<=0;
			state<=Idle_demapper;
			end
		else
			state<=Idle_demapper;
		begin

case (state) 	

Idle_demapper: begin   
	if(start)
		begin
			reg_1_0=33'hFFFFFFFF;
			reg_0_0=33'hFFFFFFFF;
			reg_1_1=33'hFFFFFFFF;
			reg_0_1=33'hFFFFFFFF;
			reg_1_2=33'hFFFFFFFF;
			reg_0_2=33'hFFFFFFFF;
			reg_1_3=33'hFFFFFFFF;
			reg_0_3=33'hFFFFFFFF;
			reg_1_4=33'hFFFFFFFF;
			reg_0_4=33'hFFFFFFFF;
			reg_1_5=33'hFFFFFFFF;
			reg_0_5=33'hFFFFFFFF;
			reg_1_6=33'hFFFFFFFF;
			reg_0_6=33'hFFFFFFFF;
			reg_1_7=33'hFFFFFFFF;
			reg_0_7=33'hFFFFFFFF;
			address<=0;
			counter<=0;
			BM_counter=0;
			M_counter=0;
			mod_type_reg<=mod_type;
			state<=Fetch_data;
		end end
	  	
		
Fetch_data: begin //Fetch data state
	if(mod_type_reg==1)
		begin 
		address<=0;
      mod_type_reg2<=2; 
		end 
	else 
	if(mod_type_reg==2)
		begin 
		address<=2;
      mod_type_reg2<=6;
		end 
	else
	if(mod_type_reg==3)
		begin
			address<=6;
			mod_type_reg2<=14; 
		end 
	else
	if(mod_type_reg==4)
		begin
		address<=14;
      mod_type_reg2<=30;
		end
	else
	if(mod_type_reg==5)
		begin
		address<=30;
      mod_type_reg2<=62;
		end 
	else 
	if(mod_type_reg==6)
		begin
		address<=62;
      mod_type_reg2<=126; 
		end 
	else
	if(mod_type_reg==7)
		begin 
		address<=126;
      mod_type_reg2<=254; 
		end
	else
	if(mod_type_reg==8)
		begin
		address<=254;
      mod_type_reg2<=509; 
		end 
		
	address_IQ<=address_IQ+1;
	Yi_reg<=I;
	Yq_reg<=Q;
	state <= Process0;
	end 


	
Process0: begin  //Process state


	if (address<=mod_type_reg2)
		begin
		BM_counter=0;
		Xi_reg<=Xi;
		Xq_reg<=Xq;
		binary_mapping_reg<=binary_mapping;
	
		Sub_Yq_Xq<=Yq_reg-Xq_reg;
		Sub_Yi_Xi<=Yi_reg-Xi_reg;	
		binary_mapping_reg1<=binary_mapping_reg;
	
		Sqr_i<=Sub_Yi_Xi*Sub_Yi_Xi;
		Sqr_q<=Sub_Yq_Xq*Sub_Yq_Xq;
		binary_mapping_reg2<=binary_mapping_reg1;
	
		new_value<= Sqr_i + Sqr_q;
		binary_mapping_reg3<=binary_mapping_reg2;	

		state<=Process1;
		end 
	else
		state<=Clearing_tail;
	end
	
	
Process1:	begin

	if(BM_counter<mod_type_reg)
		begin
		BM_counter=BM_counter+1;
			if(binary_mapping_reg3[0])
				begin
				diff_new_old_0 = new_value - reg_1_0; 
				end
			else
				diff_new_old_0  = new_value - reg_0_0;
	 // updating required reg with small value if small 
	  if(binary_mapping_reg3[0]&diff_new_old_0[33])
	   reg_1_0 = new_value;
	  else
		if (~binary_mapping_reg3[0]&diff_new_old_0[33])
			begin    reg_0_0 = new_value;
			end  end
     

	if(BM_counter<mod_type_reg)
		begin BM_counter=BM_counter+1;
			if(binary_mapping_reg3[1])
				begin 
				diff_new_old_1 = new_value - reg_1_1;
				end
				else
				diff_new_old_1 = new_value - reg_0_1;
		// updating required reg with small value if small 
		if(binary_mapping_reg3[1]&diff_new_old_1[33])
			reg_1_1 = new_value;
		else
		if (~binary_mapping_reg3[1]&diff_new_old_1[33])
			begin
			reg_0_1 = new_value;
			end end
    
	 
	 
	 if(BM_counter<mod_type_reg)
		begin
		BM_counter=BM_counter+1;
			if(binary_mapping_reg3[2])
			begin diff_new_old_2 = new_value - reg_1_2;
			end
			else
			diff_new_old_2 = new_value - reg_0_2;
	 // updating required reg with small value if small 
	  if(binary_mapping_reg3[2]&diff_new_old_2[33])
	   reg_1_2 = new_value;
     else
	  if (~binary_mapping_reg3[2]&diff_new_old_2[33])
		begin
		reg_0_2 = new_value;
		end end
	 
	 
	 if(BM_counter<mod_type_reg)
		begin BM_counter=BM_counter+1; 
			if(binary_mapping_reg3[3])
			begin diff_new_old_3 = new_value - reg_1_3; 
			end
    else
		diff_new_old_3 = new_value - reg_0_3;
	 // updating required reg with small value if small 
	 if(binary_mapping_reg3[3]&diff_new_old_3[33])
	   reg_1_3 = new_value;
	 else
	 if (~binary_mapping_reg3[3]&diff_new_old_3[33])
		begin
		reg_0_3 = new_value;
		end end
	 

	 if(BM_counter<mod_type_reg)
		begin BM_counter=BM_counter+1;
		if(binary_mapping_reg3[4])
		begin 
		diff_new_old_4 = new_value - reg_1_4;
		end
		else
		diff_new_old_4 = new_value - reg_0_4;
	 // updating required reg with small value if small 
	 if(binary_mapping_reg3[4]&diff_new_old_4[33])
	   reg_1_4 = new_value;
	 else
	 if (~binary_mapping_reg3[4]&diff_new_old_4[33])
		begin 
		reg_0_4 = new_value;
		end end
	 
	 
	 if(BM_counter<mod_type_reg)
		begin BM_counter=BM_counter+1; 
		if(binary_mapping_reg3[5])
			begin
			diff_new_old_5 = new_value - reg_1_5;	 
			end
			else
			diff_new_old_5 = new_value - reg_0_5;
	 // updating required reg with small value if small 
	  if(binary_mapping_reg3[5]&diff_new_old_5[33])
	   reg_1_5 = new_value;
	  else
	  if (~binary_mapping_reg3[5]&diff_new_old_5[33])
		begin
		reg_0_5 = new_value;
		end end
	 
	 
	 if(BM_counter<mod_type_reg)
		begin	
		BM_counter=BM_counter+1; 
		if(binary_mapping_reg3[6])
		begin 
		diff_new_old_6 = new_value - reg_1_6;
		end
		else
		diff_new_old_6 = new_value - reg_0_6;
	 // updating required reg with small value if small 
	 if(binary_mapping_reg3[6]&diff_new_old_6[33])
	   reg_1_6 = new_value;
	 else
	 if (~binary_mapping_reg3[6]&diff_new_old_6[33])
		begin
		reg_0_6 = new_value;
		end end 
	 
	 
	 if(BM_counter<mod_type_reg)
		begin BM_counter=BM_counter+1; 
		if(binary_mapping_reg3[7])
			begin
			diff_new_old_7 = new_value - reg_1_7;
			end
		else
			diff_new_old_7 = new_value - reg_0_7; 
	 // updating required reg with small value if small 
	  if(binary_mapping_reg3[7] &diff_new_old_7[33])
		begin
		reg_1_7 = new_value;
		end
	  else
	  if (~binary_mapping_reg3[7]&diff_new_old_7[33])
		begin 
		reg_0_7 = new_value; 
		end end





	if (address<=mod_type_reg2)
		begin
		address<=address+1;
		state<=Process0;
		end   
	else 
	if (counter<4)
		state<=Clearing_tail;	
	else 
		state<=Demapping;
		end
		
		

Clearing_tail:   begin

	if (counter<4)
		begin
		counter<=counter+1;
		BM_counter=0;
		Sub_Yq_Xq<=Yq_reg-Xq_reg;
		Sub_Yi_Xi<=Yi_reg-Xi_reg;	
		binary_mapping_reg1<=binary_mapping_reg;
	
		Sqr_i<=Sub_Yi_Xi*Sub_Yi_Xi;
		Sqr_q<=Sub_Yq_Xq*Sub_Yq_Xq;
		binary_mapping_reg2<=binary_mapping_reg1;
	
		new_value<= Sqr_i + Sqr_q;
		binary_mapping_reg3<=binary_mapping_reg2;
		
		state<=Process1;
		end 
	else 	
		state<=Demapping;
	end
	
Demapping:   begin

	if(M_counter<mod_type_reg)
		begin
		Yi_Yq<={Yi,Yq};
		M_counter=M_counter+1; 
		LLR_0=reg_0_0-reg_1_0;
			if(LLR_0 [33])
			output_bits[0]<=0;
			else if(~LLR_0 [33])
			begin
			output_bits[0]<=1;
			end  end


	if(M_counter<mod_type_reg)
		begin
		M_counter=M_counter+1; 
		LLR_1=reg_0_1-reg_1_1;
			if(LLR_1 [33])
			output_bits[1]<=0;
			else if(~LLR_1 [33])
			output_bits[1]<=1;  end
	 



	if(M_counter<mod_type_reg)
		begin M_counter=M_counter+1; 
		LLR_2=reg_0_2-reg_1_2;
		if(LLR_2 [33])
		output_bits[2]<=0;
		else if(~LLR_2 [33])
		output_bits[2]<=1;
		end
	


	if(M_counter<mod_type_reg)
		begin M_counter=M_counter+1; 
		LLR_3=reg_0_3-reg_1_3;
		if(LLR_3 [33])
		output_bits[3]<=0;
		else if(~LLR_3 [33])
		output_bits[3]<=1;
		end
	
	


	if(M_counter<mod_type_reg)
		begin M_counter=M_counter+1; 
		LLR_4=reg_0_4-reg_1_4;
		if(LLR_4 [33])
		output_bits[4]<=0;
		else if(~LLR_4 [33])
		output_bits[4]<=1;
		end



	if(M_counter<mod_type_reg)
		begin M_counter=M_counter+1; 
		LLR_5=reg_0_5-reg_1_5;
		if(LLR_5 [33])
		output_bits[5]<=0;
		else if(~LLR_5 [33])
		output_bits[5]<=1;
		end



	if(M_counter<mod_type_reg)
		begin M_counter=M_counter+1; 
		LLR_6=reg_0_6-reg_1_6;
		if(LLR_6 [33])
		output_bits[6]<=0;
		else if(~LLR_6 [33])
		output_bits[6]<=1;
		end
	
	
	if(M_counter<mod_type_reg)
     begin M_counter=M_counter+1; 
	  LLR_7=reg_0_7-reg_1_7;
	  if(LLR_7 [33])
	  output_bits[7]<=0;
	  else if(~LLR_7 [33])
	  begin output_bits[7]<=1;
     end end
	    
	 state<=Storing;
	  end
	
	
Storing: begin
	
	output_bits<={sin,output_bits[7:1]};
	demapped_bits={demapped_bits[6:0],output_bits[0]};
	mod_counter<=mod_counter+1;
	 
   if (mod_counter==mod_type)
	 begin
	   if(address_E==30)
			begin
			state<=Done_demapping;
			end
			else 
			begin
	      state<=Idle_demapper;
	      mod_counter<=0;
         end end
	 else
      begin
	   state<=Storing;
      end
    
	 if(mod_counter==7)
	    begin
	    demapped_in=demapped_bits;
	    demapped_bits=0;
	    address_E<=address_E+1;
	    end end
	
	
Done_demapping: begin
	
	wea_demapped_bits=0;
	start_decoder=1;
	state<=Done_demapping;
	end
	
	endcase
	end end
endmodule

 

