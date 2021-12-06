`timescale 1ns/100ps
module pixel_digital_scan #(
	parameter ROW_LENGTH    = 32,
	parameter COLUMN_LENGTH = 8
)(
	input  wire                     clock_i,
	input  wire                     reset_i,
	input  wire                     start_i,
	input  wire                     speak_i,
	output wire                     marker_o,
	output wire [ROW_LENGTH-1:0]    rowSel_o,
	output wire [COLUMN_LENGTH-1:0] columnSel_o
);

localparam RowIndex    = $clog2(ROW_LENGTH) ;    
localparam ColumnIndex = $clog2(COLUMN_LENGTH); 

reg                      start_delay;
reg                      started;
reg [ROW_LENGTH-1:0]     row_selection_buf;
reg [COLUMN_LENGTH-1:0]  column_selection_buf;         
reg [ColumnIndex:0]      col_cunt;
reg [RowIndex:0]         row_cunt;

always @ (posedge clock_i or posedge reset_i) begin
	if(reset_i) begin
		col_cunt   <=  0;
		row_cunt   <=  0;
		started    <=  0;
		start_delay<=  0;
	end	else begin
		start_delay <= start_i;
		if((!start_delay) & start_i) begin
			started  <= 1;
			col_cunt <= 0;
			row_cunt <= 0;
		end else if (speak_i & started) begin
			col_cunt <= (col_cunt==COLUMN_LENGTH-1) ? 0 : col_cunt + 1;
			row_cunt <= (row_cunt==ROW_LENGTH-1) ? 0 : 
					    (col_cunt==COLUMN_LENGTH-1) ? row_cunt + 1:
						row_cunt;
		end		
	end
end

always @ (posedge clock_i or posedge reset_i) begin
	if(reset_i) begin
		column_selection_buf<=0;
	end	else begin
		if(col_cunt==0) begin
			column_selection_buf<=1;
		end else if (speak_i) begin
			column_selection_buf<={column_selection_buf[COLUMN_LENGTH-2:0],column_selection_buf[COLUMN_LENGTH-1]};
		end
	end
end

always @ (posedge clock_i or posedge reset_i) begin
	if(reset_i) begin
		row_selection_buf <= 0;
	end	else begin
		if(row_cunt==0) begin
			row_selection_buf <= 1;
		end else if (speak_i & (col_cunt==0)) begin
			row_selection_buf <= {row_selection_buf[ROW_LENGTH-2:0],row_selection_buf[ROW_LENGTH-1]};
		end
	end
end

assign marker_o    = ((col_cunt==1) & (row_cunt==0))? 1'b1 : 1'b0;
assign rowSel_o    = row_selection_buf;
assign columnSel_o = column_selection_buf;

endmodule
