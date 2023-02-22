//Yiğit Göksel 150119053
//Mustafa Yanar 150118048
//Emir Said Haliloğlu 150119039

module top ( input clk,
 input ps2c,
 input ps2d,
 output logic ground,
 output logic [2:0] rgb,
 output logic hsync,
 output logic vsync
 );
 

logic [15:0] data_all;
logic  [15:0] x;
logic  [15:0] y;
logic ack;
//memory map is defined here
localparam BEGINMEM=12'h000,
ENDMEM=12'h1ff,
XDATA=12'h200,
YDATA=12'h201,
KEYBOARD=12'h900,
VGA=12'hb00;


logic [15:0] memory [0:127];


logic [15:0] data_out;
logic [15:0] data_in;
logic [11:0] address;
logic memwt;


logic [15:0] keyboard_out;



vga_sync vga(
    .clk(clk),
    .hsync(hsync),
    .vsync(vsync),
    .rgb(rgb),
	 .xCoordinate(x),
	 .yCoordinate(y)
    ); 

keyboard keyboard(
    .clk(clk),
    .ps2d(ps2d),
    .ps2c(ps2c),
    .ack(ack),
    .dout(keyboard_out)
    ); 

bird bird (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out),
    .address(address),
    .memwt(memwt),
    ); 


always_comb
if ( (BEGINMEM<=address) && (address<=ENDMEM) )
begin
ack=0;
data_in=memory[address];
end

else if (address==KEYBOARD+1) 
begin 
data_in= keyboard_out;
ack=0; 
end 

else if (address==KEYBOARD) 
begin 
data_in= keyboard_out;
ack=1;
end 

else begin
ack=0;
data_in=16'hf345; 
end




always_ff @(posedge clk) 
if (memwt)
begin
if ( (BEGINMEM<=address) && (address<=ENDMEM) )
memory[address]<=data_out;
else if (address==XDATA)
x<=data_out;
else if (address==YDATA)
y<=data_out;
end
initial begin
    $readmemh("ram.dat", memory);
end
endmodule