`timescale 1ns / 1ps
//
// WIDTH: bits in register hdata & vdata
// HSIZE: horizontal size of visible field 
// HFP: horizontal front of pulse
// HSP: horizontal stop of pulse
// HMAX: horizontal max size of value
// VSIZE: vertical size of visible field 
// VFP: vertical front of pulse
// VSP: vertical stop of pulse
// VMAX: vertical max size of value
// HSPP: horizontal synchro pulse polarity (0 - negative, 1 - positive)
// VSPP: vertical synchro pulse polarity (0 - negative, 1 - positive)
//
module vga
// 11 800 856 976 1040 600 637 643 666 1 1
// 11 800 784 hsp? hmax? 521 511 vsp? vmax? hspp? vspp?
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    input wire rst,
    output wire hsync,
    output wire vsync,
    // output reg [WIDTH - 1:0] hdata,
    // output reg [WIDTH - 1:0] vdata,
    output wire data_enable,
    output reg[2:0] red,
    output reg[2:0] green,
    output reg[1:0] blue,
    input wire[31:0] taddr,
    input wire[31:0] tdata
);

reg[11:0] hdata;
reg[11:0] vdata;

// init
initial begin
    hdata <= 0;
    vdata <= 0;
end

// hdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1))
        hdata <= 0;
    else
        hdata <= hdata + 1;
end

// vdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1)) 
    begin
        if (vdata == (VMAX - 1))
            vdata <= 0;
        else
            vdata <= vdata + 1;
    end
end

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

wire inH = (hdata < 800);
wire inV = (vdata < 600);
wire inDisplay = inH && inV;

parameter hbp = 144;
parameter hfp = 784;
parameter vbp = 31;
parameter vfp = 511;

reg[31:0] buffer = 31'b0;
reg[31:0] buffer2 = 31'b0;
reg[31:0] buffer3 = 31'b0;
reg[31:0] buffer4 = 31'b0;
reg[31:0] buffer5 = 31'b0;
reg[5:0] cnt = 6'b0;
reg[31:0] height = 31'b0;

always @ (posedge clk)
begin
    if (taddr == 32'h80001000) begin
        buffer <= tdata;
    end
    else if (taddr == 32'h80001004) begin
        buffer2 <= tdata;
    end
    else if (taddr == 32'h80001008) begin
        buffer3 <= tdata;
    end
    else if (taddr == 32'h8000100c) begin
        buffer4 <= tdata;
    end
    else if (taddr == 32'h80001010) begin
        buffer5 <= tdata;
    end
end

    /*
always @ (*) begin
    if (vdata >= vbp & vdata < vfp & hdata >= hbp & hdata < hfp)
    begin
        myTask(buffer[31:28], 150, 150);
        myTask(buffer[27:24], 160, 150);
        myTask(buffer[23:20], 170, 150);
        // BIG BROTHER IS WATCHING U

		char(1, 150, 300);
		char(8, 160, 300);
		char(6, 170, 300);
    end
end
    */


always @ (*)
begin
    if (vdata >= vbp & vdata < vfp & hdata >= hbp & hdata < hfp)
	begin

/*        
        char(7, 150, 150);
        char(4, 160, 150);
		char(11, 170, 150);
		char(11, 180, 150);
		char(14, 190, 150);

		char(12, 210, 150);
		char(8, 230, 150);
		char(15, 300, 150);
		char(18, 270, 150);
        
        
        char(0, 150, 150);
		char(1, 160, 150);
		char(2, 170, 150);
		char(3, 180, 150);
		char(4, 190, 150); // E
		char(5, 200, 150);
		char(6, 210, 150); // G
		char(7, 220, 150); // H
		char(8, 230, 150); // I
		char(9, 240, 150); // J
		char(10, 300, 150); // K
		char(11, 150, 170); // L
		char(12, 160, 170); // M
		char(13, 170, 170); // N
		char(14, 180, 170); // O
		char(15, 190, 170); // P
		char(16, 200, 170); // Q
		char(17, 210, 170); // R
		char(18, 220, 170); // S
		char(19, 230, 170); // T
		char(20, 240, 170); // U
		char(21, 300, 170); // V
		char(22, 150, 190); 
		char(23, 160, 190); // X
		char(24, 170, 190);
		char(25, 180, 190);
		
		char(26, 150, 210);
		char(27, 160, 210);
		char(28, 170, 210);
		char(29, 180, 210);
		char(30, 190, 210);
		char(31, 200, 210);
		char(32, 210, 210);
		char(33, 220, 210);
		char(34, 230, 210);
		char(35, 240, 210);
*/
        myTask(buffer[31:28], 150, 150);
        myTask(buffer[27:24], 160, 150);
        myTask(buffer[23:20], 170, 150);
        myTask(buffer[19:16], 180, 150);
        myTask(buffer[15:12], 190, 150);
        myTask(buffer[11:8], 200, 150);
        myTask(buffer[7:4], 210, 150);
        myTask(buffer[3:0], 220, 150);

        myTask(buffer2[31:28], 150, 170);
        myTask(buffer2[27:24], 160, 170);
        myTask(buffer2[23:20], 170, 170);
        myTask(buffer2[19:16], 180, 170);
        myTask(buffer2[15:12], 190, 170);
        myTask(buffer2[11:8], 200, 170);
        myTask(buffer2[7:4], 210, 170);
        myTask(buffer2[3:0], 220, 170);
        
        myTask(buffer3[31:28], 150, 190);
        myTask(buffer3[27:24], 160, 190);
        myTask(buffer3[23:20], 170, 190);
        myTask(buffer3[19:16], 180, 190);
        myTask(buffer3[15:12], 190, 190);
        myTask(buffer3[11:8], 200, 190);
        myTask(buffer3[7:4], 210, 190);
        myTask(buffer3[3:0], 220, 190);
     
        myTask(buffer4[31:28], 150, 210);
        myTask(buffer4[27:24], 160, 210);
        myTask(buffer4[23:20], 170, 210);
        myTask(buffer4[19:16], 180, 210);
        myTask(buffer4[15:12], 190, 210);
        myTask(buffer4[11:8], 200, 210);
        myTask(buffer4[7:4], 210, 210);
        myTask(buffer4[3:0], 220, 210);
         
        myTask(buffer5[31:28], 150, 230);
        myTask(buffer5[27:24], 160, 230);
        myTask(buffer5[23:20], 170, 230);
        myTask(buffer5[19:16], 180, 230);
        myTask(buffer5[15:12], 190, 230);
        myTask(buffer5[11:8], 200, 230);
        myTask(buffer5[7:4], 210, 230);
        myTask(buffer5[3:0], 220, 230);

        char(1, 100, 300);
		char(8, 110, 300);
		char(6, 120, 300);

        char(1, 140, 300);
        char(17, 150, 300);
        char(14, 160, 300);
        char(19, 170, 300);
        char(7, 180, 300);
        char(4, 190, 300);
        char(17, 200, 300);

        char(8, 220, 300);
        char(18, 230, 300);

        char(22, 250, 300);
        char(0, 260, 300);
        char(19, 270, 300);
        char(2, 280, 300);
        char(7, 290, 300);
        char(8, 300, 300);
        char(13, 310, 300);
        char(6, 320, 300);

        char(20, 340, 300);
        
	end
	if (!inDisplay)
    begin
        red = 0;
        green = 0;
        blue = 0;
    end
end


task myTask;
input [3:0] taskData;
input [31:0] x, y;
begin
    case(taskData)
        4'b0000: begin
            char(35, x, y);
        end
        4'b0001: begin
            char(26, x, y);
        end
        4'b0010: begin
            char(27, x, y);
        end
        4'b0011: begin
            char(28, x, y);
        end
        4'b0100: begin
            char(29, x, y);
        end
        4'b0101: begin
            char(30, x, y);
        end
        4'b0110: begin
            char(31, x, y);
        end
        4'b0111: begin
            char(32, x, y);
        end
        4'b1000: begin
            char(33, x, y);
        end
        4'b1001: begin
            char(34, x, y);
        end
        4'b1010: begin
            char(0, x, y);
        end
        4'b1011: begin
            char(1, x, y);
        end
        4'b1100: begin
            char(2, x, y);
        end
        4'b1101: begin
            char(3, x, y);
        end
        4'b1110: begin
            char(4, x, y);
        end
        4'b1111: begin
            char(5, x, y);
        end
    endcase
end
endtask

/*
* Implemented a function to draw a 8'hFF line whenever vc and hc are
* in the domain of the x-start, y-start and x-end, and y-end coordinates.
*/
task draw;
input [11:0] xStart;
input [11:0] yStart;
input [11:0] xEnd; 
input [11:0] yEnd;
input [7:0] color;
begin
    if (vdata >= (vbp + yStart) && vdata < (vbp + yEnd) && hdata >= (hbp + xStart) && hdata < (hbp + xEnd))
    begin
        red = color[2:0];
        green = color[5:3];
        blue = color[7:6];
    end
    if (!inDisplay)
    begin
        red = 0;
        green = 0;
        blue = 0;
    end
end
endtask

/*
* char function to manually draw each character on a 9x9 pixel block
*/
task char;
input [5:0] charVal;
input [11:0] x, y;
begin
    case(charVal)
        6'b000000: // A
            begin
                draw(x + 2, y, x + 5, y + 1, 8'hFF);
                draw(x + 1, y + 1, x + 6, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 4, x + 5, y + 6, 8'hFF);
                draw(x + 5, y + 2, x + 7, y + 9, 8'hFF);
            end
        6'b000001: // B
            begin
                draw(x, y, x + 5, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 9, 8'hFF);
                draw(x + 5, y + 2, x + 7, y + 4, 8'hFF);
                draw(x + 2, y + 4, x + 5, y + 5, 8'hFF);
                draw(x + 5, y + 5, x + 7, y + 8, 8'hFF);
                draw(x + 2, y + 8, x + 5, y + 9, 8'hFF);
            end
        6'b000010: // C
            begin
                draw(x + 2, y, x + 6, y + 1, 8'hFF);
                draw(x + 1, y + 1, x + 2, y + 2, 8'hFF);
                draw(x + 6, y + 1, x + 7, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
                draw(x + 6, y + 7, x + 7, y + 8, 8'hFF);
            end
        6'b000011: // D
            begin
                draw(x, y, x + 5, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 9, 8'hFF);
                draw(x + 5, y + 1, x + 6, y + 2, 8'hFF);
                draw(x + 6, y + 2, x + 7, y + 7, 8'hFF);
                draw(x + 5, y + 7, x + 6, y + 8, 8'hFF);
                draw(x + 2, y + 8, x + 5, y + 9, 8'hFF);
            end
        6'b000100: // E
            begin
                draw(x, y, x + 7, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 4, x + 5, y + 5, 8'hFF);
                draw(x + 2, y + 8, x + 7, y + 9, 8'hFF);
            end
        6'b000101: // F
            begin
                draw(x, y, x + 7, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 3, x + 5, y + 4, 8'hFF);
            end
        6'b000110: // G
            begin
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 8, 8'hFF);
                draw(x + 6, y + 1, x + 7, y + 2, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
                draw(x + 5, y + 5, x + 7, y + 8, 8'hFF);
                draw(x + 4, y + 5, x + 5, y + 6, 8'hFF);
            end
        6'b000111: // H
            begin
                draw(x, y, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 4, x + 5, y + 5, 8'hFF);
                draw(x + 5, y, x + 7, y + 9, 8'hFF);
            end
        6'b001000: // I
            begin
                draw(x, y, x + 2, y + 9, 8'hFF);
            end
        6'b001001: // J
            begin
                draw(x + 5, y, x + 7, y + 8, 8'hFF);
                draw(x, y + 6, x + 1, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        6'b001010: // K
            begin
                draw(x, y, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 4, x + 5, y + 5, 8'hFF);
                draw(x + 5, y + 3, x + 6, y + 4, 8'hFF);
                draw(x + 5, y + 5, x + 6, y + 6, 8'hFF);
                draw(x + 6, y, x + 7, y + 3, 8'hFF);
                draw(x + 6, y + 6, x + 7, y + 9, 8'hFF);
            end
        6'b001011: // L
            begin
                draw(x, y, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 7, x + 7, y + 9, 8'hFF);
            end
        6'b001100: // M
            begin
                draw(x + 1, y, x + 3, y + 1, 8'hFF);
                draw(x + 4, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 7, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 9, 8'hFF);
                draw(x + 3, y + 2, x + 4, y + 9, 8'hFF);
                draw(x + 5, y + 2, x + 7, y + 9, 8'hFF);
            end
        6'b001101: // N
            begin
                draw(x, y, x + 2, y + 9, 8'hFF);
                draw(x + 2, y + 1, x + 3, y + 2, 8'hFF);
                draw(x + 3, y, x + 6, y + 1, 8'hFF);
                draw(x + 6, y + 1, x + 7, y + 9, 8'hFF);
            end
        6'b001110: // O
            begin
                draw(x, y + 1, x + 2, y + 8, 8'hFF);
                draw(x + 5, y + 1, x + 7, y + 8, 8'hFF);
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        6'b001111: // P
            begin
                draw(x, y, x + 5, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 9, 8'hFF);
                draw(x + 5, y + 1, x + 6, y + 2, 8'hFF);
                draw(x + 6, y + 2, x + 7, y + 4, 8'hFF);
                draw(x + 5, y + 4, x + 6, y + 5, 8'hFF);
                draw(x + 2, y + 5, x + 5, y + 6, 8'hFF);
            end
        6'b010000: // Q
            begin
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 8, 8'hFF);
                draw(x + 5, y + 1, x + 7, y + 7, 8'hFF);
                draw(x + 1, y + 8, x + 7, y + 9, 8'hFF);
                draw(x + 3, y + 6, x + 4, y + 7, 8'hFF);
                draw(x + 4, y + 7, x + 6, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 7, y + 9, 8'hFF);
            end
        6'b010001: // R
            begin
                draw(x, y, x + 5, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 9, 8'hFF);
                draw(x + 5, y + 1, x + 6, y + 2, 8'hFF);
                draw(x + 6, y + 2, x + 7, y + 4, 8'hFF);
                draw(x + 5, y + 4, x + 6, y + 5, 8'hFF);
                draw(x + 2, y + 5, x + 6, y + 6, 8'hFF);
                draw(x + 6, y + 6, x + 7, y + 9, 8'hFF);
            end
        6'b010010: // S
            begin
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 1, y + 4, 8'hFF);
                draw(x + 6, y + 1, x + 7, y + 3, 8'hFF);
                draw(x + 1, y + 4, x + 6, y + 5, 8'hFF);
                draw(x + 6, y + 5, x + 7, y + 8, 8'hFF);
                draw(x, y + 6, x + 1, y + 8, 8'hFF);
                draw(x + 2, y + 8, x + 7, y + 9, 8'hFF);
            end
        6'b010011: // T
            begin
                draw(x, y, x + 7, y + 2, 8'hFF);
                draw(x + 3, y + 2, x + 5, y + 9, 8'hFF);
            end
        6'b010100: // U
            begin
                draw(x, y, x + 2, y + 8, 8'hFF);
                draw(x + 5, y, x + 7, y + 8, 8'hFF);
                draw(x + 1, y + 7, x + 6, y + 9, 8'hFF);
            end
        6'b010101: // V
            begin
                draw(x, y, x + 1, y + 5, 8'hFF);
                draw(x + 6, y, x + 7, y + 5, 8'hFF);
                draw(x + 1, y + 4, x + 2, y + 7, 8'hFF);
                draw(x + 5, y + 4, x + 6, y + 7, 8'hFF);
                draw(x + 3, y + 6, x + 4, y + 8, 8'hFF);
                draw(x + 5, y + 6, x + 6, y + 8, 8'hFF);
                draw(x + 4, y + 8, x + 5, y + 9, 8'hFF);
            end
        6'b010110: // W
            begin
                draw(x, y, x + 1, y + 8, 8'hFF);
                draw(x + 6, y, x + 7, y + 8, 8'hFF);
                draw(x + 3, y + 3, x + 4, y + 8, 8'hFF);
                draw(x, y + 8, x + 7, y + 9, 8'hFF);
            end
        6'b010111: // X
            begin
                draw(x, y, x + 1, y + 3, 8'hFF);
                draw(x + 6, y, x + 7, y + 3, 8'hFF);
                draw(x + 1, y + 2, x + 2, y + 4, 8'hFF);
                draw(x + 5, y + 2, x + 6, y + 4, 8'hFF);
                draw(x + 2, y + 4, x + 5, y + 5, 8'hFF);
                draw(x + 1, y + 5, x + 2, y + 7, 8'hFF);
                draw(x + 5, y + 5, x + 6, y + 7, 8'hFF);
                draw(x, y + 6, x + 1, y + 9, 8'hFF);
                draw(x + 6, y + 6, x + 7, y + 9, 8'hFF);              
            end
        6'b011000: // Y
            begin
                draw(x, y, x + 2, y + 4, 8'hFF);
                draw(x + 5, y, x + 7, y + 8, 8'hFF);
                draw(x + 1, y + 4, x + 5, y + 5, 8'hFF);
                draw(x, y + 7, x + 2, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        6'b011001: // Z
            begin
                draw(x, y, x + 7, y + 2, 8'hFF);
                draw(x + 5, y + 2, x + 7, y + 3, 8'hFF);
                draw(x + 4, y + 3, x + 5, y + 4, 8'hFF);
                draw(x + 3, y + 4, x + 4, y + 5, 8'hFF);
                draw(x + 2, y + 5, x + 3, y + 6, 8'hFF);
                draw(x, y + 6, x + 2, y + 7, 8'hFF);
                draw(x + 1, y + 7, x + 8, y + 9, 8'hFF);
            end
        6'b011010: // 1
            begin
                draw(x + 3, y, x + 5, y + 9, 8'hFF);
                draw(x + 2, y + 1, x + 3, y + 3, 8'hFF);
                draw(x + 1, y + 2, x + 2, y + 3, 8'hFF);
                draw(x + 1, y + 7, x + 6, y + 9, 8'hFF);
            end
        6'b011011: // 2
            begin
                draw(x, y + 1, x + 2, y + 3, 8'hFF);
                draw(x + 1, y, x + 3, y + 2, 8'hFF);
                draw(x + 3, y, x + 6, y + 1, 8'hFF);
                draw(x + 5, y + 1, x + 7, y + 4, 8'hFF);
                draw(x + 1, y + 4, x + 6, y + 5, 8'hFF);
                draw(x, y + 5, x + 2, y + 8, 8'hFF);
                draw(x + 2, y + 8, x + 8, y + 9, 8'hFF);
            end
        6'b011100: // 3
            begin
                draw(x, y + 1, x + 1, y + 2, 8'hFF);
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x + 6, y + 1, x + 7, y + 4, 8'hFF);
                draw(x + 2, y + 4, x + 6, y + 5, 8'hFF);
                draw(x + 6, y + 5, x + 7, y + 8, 8'hFF);
                draw(x, y + 7, x + 1, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        6'b011101: // 4
            begin
                draw(x + 4, y, x + 7, y + 2, 8'hFF);
                draw(x + 3, y + 1, x + 4, y + 2, 8'hFF);
                draw(x + 2, y + 2, x + 3, y + 3, 8'hFF);
                draw(x + 1, y + 3, x + 2, y + 4, 8'hFF);
                draw(x, y + 4, x + 5, y + 6, 8'hFF);
                draw(x + 4, y + 2, x + 7, y + 9, 8'hFF);
            end
        6'b011110: // 5
            begin
                draw(x, y, x + 7, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 5, 8'hFF);
                draw(x + 2, y + 3, x + 7, y + 5, 8'hFF);
                draw(x + 5, y + 5, x + 7, y + 9, 8'hFF);
                draw(x, y + 7, x + 7, y + 9, 8'hFF);
            end
        6'b011111: // 6
            begin
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 8, 8'hFF);
                draw(x + 5, y + 1, x + 7, y + 2, 8'hFF);
                draw(x + 2, y + 4, x + 6, y + 5, 8'hFF);
                draw(x + 5, y + 5, x + 7, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        6'b100000: // 7
            begin
                draw(x, y, x + 7, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 3, 8'hFF);
                draw(x + 5, y + 2, x + 7, y + 9, 8'hFF);
            end
        6'b100001: // 8
            begin
                draw(x + 1, y, x + 6, y + 2, 8'hFF);
                draw(x, y + 1, x + 2, y + 4, 8'hFF);
                draw(x + 5, y + 1, x + 7, y + 4, 8'hFF);
                draw(x + 1, y + 4, x + 6, y + 5, 8'hFF);
                draw(x, y + 5, x + 2, y + 8, 8'hFF);
                draw(x + 6, y + 5, x + 8, y + 8, 8'hFF);
                draw(x + 2, y + 7, x + 7, y + 9, 8'hFF);
            end
        6'b100010: // 9
            begin
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 2, y + 4, 8'hFF);
                draw(x + 1, y + 4, x + 5, y + 5, 8'hFF);
                draw(x + 5, y + 1, x + 7, y + 8, 8'hFF);
                draw(x, y + 7, x + 1, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        6'b100011: // 0
            begin
                draw(x + 1, y, x + 6, y + 1, 8'hFF);
                draw(x, y + 1, x + 7, y + 2, 8'hFF);
                draw(x, y + 2, x + 2, y + 7, 8'hFF);
                draw(x + 5, y + 2, x + 7, y + 7, 8'hFF);
                draw(x, y + 7, x + 7, y + 8, 8'hFF);
                draw(x + 1, y + 8, x + 6, y + 9, 8'hFF);
            end
        default:
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
    endcase
end
endtask

endmodule