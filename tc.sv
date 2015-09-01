`timescale 1ns/10ps

module tc(tci.tc timer);

const reg [7:0] A_tccra=8'h24; //f
const reg [7:0] A_tccra1=8'h44; //f
const reg [7:0] A_tccrb=8'h25; // a
const reg [7:0] A_tccrb1=8'h45; //a
const reg [7:0] A_ocra=8'h27;//b
const reg [7:0] A_ocra1=8'h47;//b
const reg [7:0] A_ocrb=8'h28; //c
const reg [7:0] A_ocrb1=8'h48; //c
const reg [7:0] A_tcnt=8'h26; //d
const reg [7:0] A_tcnt1=8'h46;//d
const reg [7:0] A_timsk=8'h6e;
const reg [7:0] A_tifr=8'h15; //e
const reg [7:0] A_tifr1=8'h35; //e

reg[7:0]tccra,tccra1,tccrb,tccrb1,ocra,ocra1,ocrb,ocrb1,tcnt,tcnt1,timsk,tifr,tifr1,rdata,rdata_tmp;

reg clk8,clk64,clk256,clk1024,sysclk;
reg[2:0]f_cnt8;
reg[5:0]f_cnt64;
reg[7:0]f_cnt256;
reg[9:0]f_cnt1024;

assign timer.rdata=rdata_tmp;
assign tccrb1 = tccrb;
// assign ocra1=ocra;
assign ocrb1=ocrb;
assign tcnt1=tcnt;
assign tifr1=tifr;
assign tccra1=tccra;

 

always @(posedge timer.clk or posedge timer.rst)
begin
  if(timer.rst)
  begin
  tccra<= 0;
  tccrb<= 0;
//  tccrb1<=#1 0;
  ocra<= 0;
//  ocra1<=#1 0;
  ocrb<= 0;
//  ocrb1<=#1 0;
 // tcnt<=0;
 // tcnt1<=#1 0;
  timsk<= 0;
  tifr<=0;
 // tifr1<=#1 0;
  rdata<= 0;  
  f_cnt8<=0;
  f_cnt64<=0;
  f_cnt256<=0;
  f_cnt1024<=0;
  clk8<=0;
  clk64<=0;
  clk256<=0;
  clk1024<=0;
  end
  else
    begin
      if(timer.write)
	begin
	  case(timer.addr)
	   A_tccra:tccra<= timer.wdata;
	   A_tccrb:tccrb<= timer.wdata;
	   A_ocra:begin ocra<= timer.wdata; ocra1<=timer.wdata;end
	   A_ocra1:begin ocra1<= timer.wdata;ocra<=timer.wdata;end
	   A_ocrb:ocrb<= timer.wdata;
	   A_timsk:timsk<= timer.wdata;
	   endcase
	 end  
	
	
	if(timer.interrupt_executed)
	timer.interrupt_request<=0;

	
	 f_cnt8<=f_cnt8+1;
	 if(f_cnt8 == 7)  clk8<=1;
	 else clk8<=0;
	 
	 f_cnt64<=f_cnt64+1;
	 if(f_cnt64 == 63)  clk64<=1;
	 else clk64<=0;
	
	 f_cnt256<=f_cnt256+1;
	 if(f_cnt64 == 255)  clk256<=1;
	 else clk256<=0;
	 
	 f_cnt1024<=f_cnt1024+1;
	 if(f_cnt1024 == 63)  clk1024<=1;
	 else clk1024<=0;
	 
  
    end
    
end

always @(*)
begin
  if(timer.rst)
    begin
    rdata_tmp=0;
    sysclk=0;
    end
    
  else
    begin
      if(timer.read)
	begin
	  case(timer.addr)
	  A_tccra:rdata_tmp=tccra;
	  A_tccra1:rdata_tmp=tccra1;
	  A_tccrb:rdata_tmp=tccrb;
	  A_tccrb1:rdata_tmp=tccrb1;
	  A_ocra:rdata_tmp=ocra;
	  A_ocra1:rdata_tmp=ocra1;
	  A_ocrb:rdata_tmp=ocrb;
	  A_ocrb1:rdata_tmp=ocrb1;
	  A_tcnt:rdata_tmp=tcnt;
	  A_tcnt1:rdata_tmp=tcnt1;
	  A_timsk:rdata_tmp=timsk;
	  A_tifr:rdata_tmp=tifr;
	  A_tifr1:rdata_tmp=tifr1;
	  endcase
	end
	else
	begin
	end
	
	 case(tccrb[2:0])
	  3'b000:sysclk=0;
	  3'b001:sysclk=timer.clk;
	  3'b010:sysclk=clk8;
	  3'b011:sysclk=clk64;
	  3'b100:sysclk=clk256;
	  3'b101:sysclk=clk1024;
	  3'b110:sysclk=timer.t0;
	  3'b111:sysclk=~timer.t0;
	  endcase
	  
	
    end

end

 always @ (posedge sysclk or posedge timer.rst)
 begin
  if(timer.rst)
  begin
     tcnt<=0;
  end
    else
      begin
	case(tccra)
	00:begin 
	      tcnt <=tcnt + 1;
	      if((tcnt== 255)) 
	      begin
	      tcnt<= 0;
	      tifr[0]<=1;
	      end

	    end
	02:begin
	        tcnt <=tcnt+1;
		if(ocra == tcnt) 
		begin
		tcnt <= 0;
		tifr[1:0]<=2'b11;
		timer.interrupt_request <= 1;
		end
		if(ocrb == tcnt) 
		begin
		tifr[2]<=1;
		tifr[0]<=1;
		timer.interrupt_request <= 1;
		end
		
	
	     
	   end
	   
	endcase



      end
 end

endmodule