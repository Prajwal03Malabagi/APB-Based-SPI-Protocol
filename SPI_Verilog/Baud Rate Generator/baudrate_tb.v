module baud_rate_tb;
	
	reg Pclk,PRESET_n,spiswai,cpol,cpha,ss;
	reg [1:0] spi_mode;
	reg [2:0] sppr,spr;
	wire sclk,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0;
	wire [11:0] BaudRateDivisor;
   baud_rate dut(Pclk,PRESET_n,spi_mode,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,BaudRateDivisor);
	always #5 Pclk=~Pclk;
	
	task reset();
	begin
	PRESET_n=0;
	@(negedge Pclk);
	PRESET_n=1;
	end
	endtask
	
	task data(input a,b);
	begin
	spi_mode=2'b00;
	sppr=3'b000;
	spr=3'b001;
	spiswai=1'b0;
	ss=1'b0;
	cpol=a;
	cpha=b;
	@(negedge Pclk);
	end
	endtask
	
	initial begin
	Pclk=0;
	cpol=0;
	cpha=0;
        reset;
   repeat(20)
	data(1,0);
	#100 $finish;
	end
	endmodule
	
