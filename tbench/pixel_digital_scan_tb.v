`timescale 1ns / 100ps
module pixel_digital_sca_tb;
   parameter period = 40;
   parameter row = 32;
   parameter col = 16;

   reg            clock ;
   reg            reset  ;
   reg            start  ;
   reg            speak  ;
   wire           marker ;
   wire [row-1:0] row_sel;
   wire [col-1:0] col_sel;

   pixel_digital_scan #(
    .ROW_LENGTH(row), 
  	 .COLUMN_LENGTH(col)
  	) dut(
      .clock_i          (clock ),
      .reset_i          (reset  ),
      .start_i          (start  ),
      .speak_i          (speak  ),
      .marker_o         (marker ),
      .rowSel_o         (row_sel),
      .columnSel_o      (col_sel)
  	);

   initial begin
   	clock = 1'b1;
     forever #(period/2) clock = ~ clock;
   end



   //  start: soft-reset, posedge active
   //  speak: run / stop, level active
   //  reset: hard-reset, level active
   initial begin
      // hard-reset process
      reset = 1'b1;
      start = 1'b0;
      speak = 1'b0;
      repeat(4) @(negedge clock);

      // setup process
      reset = 1'b0;
      start = 1'b1;
      speak = 1'b1;
      repeat(50) @(negedge clock);

      // stop scan process
      reset = 1'b0;
      start = 1'b1;
      speak = 1'b0;
      repeat(1) @(negedge clock);

      // go-on scan process
      reset = 1'b0;
      start = 1'b1;
      speak = 1'b1;
      repeat(10) @(negedge clock);

      // soft-reset process
      reset = 1'b0;
      start = 1'b0;
      speak = 1'b1;
      repeat(1) @(negedge clock);
      reset = 1'b0;
      start = 1'b1;
      speak = 1'b1;
      repeat(1) @(negedge clock);

      // go-on scan process
      reset = 1'b0;
      start = 1'b0;
      speak = 1'b1;
      repeat(20) @(negedge clock);




      repeat(100)  @(posedge clock);	 
   	 $stop();
   end

endmodule
