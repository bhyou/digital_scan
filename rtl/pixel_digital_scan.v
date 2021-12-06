`timescale 1ns/100ps
module pixel_digital_scan (clk_s,rst_s,start_s,speak_s,marker_a,rowSel,columnSel);

parameter ROW = 400;
parameter COLUMN = 32;
localparam RowCntWid = $clog2(ROW) ;    
localparam ColCntWid = $clog2(COLUMN); 

input                   clk_s;
input                   rst_s;
input                   start_s;
input                   speak_s;
output                  marker_a;
output [ROW-1:0]        rowSel;
output [COLUMN-1:0]     columnSel;


reg                      start_delay;
reg                      started;
reg [ROW-1:0]            row_selection_buf;
reg [COLUMN-1:0]         column_selection_buf;
reg [ColCntWid:0]        col_cnt;
reg [RowCntWid:0]        row_cnt;

always @ (posedge clk_s or posedge rst_s) begin
	if(rst_s) begin
		col_cnt<=0;
		row_cnt<=0;
		started<=0;
		start_delay<=0;
	end
	else begin
		start_delay<=start_s;
		if((!start_delay)&start_s) begin
			started<=1'b1;
			col_cnt<=0;
			row_cnt<=0;
		end
		else if (speak_s&started) begin
			if (col_cnt==COLUMN-1) begin
				col_cnt<=0;				
			  if (row_cnt==ROW-1) begin
					row_cnt<=0;
				end
				else begin
					row_cnt<=row_cnt+1;
				end
			end
			else begin
				col_cnt<=col_cnt+1;
			end	
		end		
	end
end

always @ (posedge clk_s or posedge rst_s)
begin
	if(rst_s) begin
		column_selection_buf<=0;
	end
	else begin
		if(col_cnt==0) begin
			column_selection_buf<=1;
		end
		else if (speak_s) begin
			column_selection_buf<={column_selection_buf[COLUMN-2:0],column_selection_buf[COLUMN-1]};
		end
	end
end

always @ (posedge clk_s or posedge rst_s)
begin
	if(rst_s) begin
		row_selection_buf <= 0;
	end
	else begin
		if(row_cnt==0) begin
			row_selection_buf <= 1;
		end
		else if (speak_s & (col_cnt==0)) begin
			row_selection_buf <= {row_selection_buf[ROW-2:0],row_selection_buf[ROW-1]};
		end
	end
end

assign rowSel    = row_selection_buf;

generate 
   genvar i,j;
   for(j=0; j<1; j=j+1) begin:group
     for(i=0; i< COLUMN; i=i+1) begin:colSel
       assign columnSel[j*COLUMN+i] = {column_selection_buf[i]};
     end
   end
endgenerate

assign marker_a=((col_cnt==1)&(row_cnt==0))? 1'b1 : 1'b0;

endmodule
