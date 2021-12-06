`timescale 1ns / 100ps
module pixel_digital_sca_tb;

`define Topmetal_verilog
parameter period = 40;
parameter row = 400;
parameter col = 32;
parameter row_width = $clog2(row);    
parameter col_width = $clog2(col); 

reg            clk_tb ;
reg            reset  ;
reg            start  ;
reg            speak  ;
wire           marker ;
wire [row-1:0] row_sel;
wire [col*32-1:0] col_sel;

`ifdef Topmetal_verilog
   pixel_digital_scan #(
    .ROW(row), 
  	 .COLUMN(col),
  	 .ROW_CNT_WIDTH(row_width),
  	 .COL_CNT_WIDTH(row_width)) dut(
      .clk_s            (clk_tb ),
      .rst_s            (reset  ),
      .start_s          (start  ),
      .speak_s          (speak  ),
      .marker_a         (marker ),
      .rowSel           (row_sel),
      .columnSel        (col_sel)
  		);
`else
top_metal_digital_scan #(
   .ROW_LENGTH(row), 
	 .ANALOG_COLUMN_LENGTH(col),
	 .ROW_CNT_WIDTH(row_width),
	 .COL_CNT_WIDTH(row_width))
	 dut_vhdl (
    .clk_s            (clk_tb ),
    .rst_s            (reset  ),
    .start_s          (start  ),
    .speak_s          (speak  ),
    .marker_a         (marker ),
    .ROW_SELECTION    (row_sel),
    .COLUMN_SELECTION (col_sel)
		);
`endif


  initial begin
   `ifdef PRE
       $sdf_annotate("../syn/output/pixel_digital_scan_DC.sdf",pixel_digital_sca_tb.dut);
   `endif
   
   `ifdef POST
       $sdf_annotate("../tbench/pixel_digital_scan_tt.sdf",pixel_digital_sca_tb.dut);
   `endif
   
   `ifdef POST_FF
       $sdf_annotate("../tbench/pixel_digital_scan_tt.sdf",pixel_digital_sca_tb.dut);
   `endif
  end



initial begin
	clk_tb = 1'b1;
	repeat(700)  #period clk_tb = ~ clk_tb;
   #(period*3);
  forever #period clk_tb = ~ clk_tb;
   
end



initial begin
   fork
      resetPluse(50);
      startPluse(60);
      speakPluse(70);
   join
   repeat(1000)  @(posedge clk_tb);	 
	 $stop();
end
   task resetPluse(integer xcycle);
	   #0 reset = 1'b1;
	   #(period*2+10) reset = 1'b0;
      repeat(xcycle) @(posedge clk_tb);
      reset = 1'b1;
	   #(period*2+10) reset = 1'b0;
   endtask

   task startPluse(integer xcycle);
	   #0 start = 1'b0;
      repeat(2) @(posedge clk_tb);
	   start = #6 1'b1;
      repeat(1) @(posedge clk_tb);
      start = #6 0;
      repeat(xcycle) @(posedge clk_tb);
      start = #6 1;
      repeat(1) @(posedge clk_tb);
      start = #6 0;
   endtask

   task speakPluse(integer xcycle);
		#0 speak = 1'b0;
      repeat(4) @(posedge clk_tb);
	   speak = #6 1'b1;
      repeat(xcycle) @(posedge clk_tb);
      speak = #6 1'b0;
      @(posedge clk_tb);
      speak = #6 1'b1;
   endtask

endmodule
