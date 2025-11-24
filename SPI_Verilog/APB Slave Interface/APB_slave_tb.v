module SPB_slave_tb;

	// Inputs
	reg pclk=0;
	reg preset_n;
	reg [2:0] paddr;
	reg pwrite;
	reg psel;
	reg penable;
	reg [7:0] pwdata;
	reg ss;
	reg [7:0] miso_data;
	reg receive_data;
	reg tip;

	// Outputs
	wire [7:0] prdata;
	wire mstr;
	wire cpol;
	wire cpha;
	wire lsbfe;
	wire spiswai;
	wire [2:0] sppr;
	wire [2:0] spr;
	wire spi_interrupt_request;
	wire pready;
	wire pslverr;
	wire send_data;
	wire mosi_data;
	wire [1:0] spi_mode;

	// Instantiate the Unit Under Test (UUT)
	APB_slave uut (
		.pclk(pclk), 
		.preset_n(preset_n), 
		.paddr(paddr), 
		.pwrite(pwrite), 
		.psel(psel), 
		.penable(penable), 
		.pwdata(pwdata), 
		.ss(ss), 
		.miso_data(miso_data), 
		.receive_data(receive_data), 
		.tip(tip), 
		.prdata(prdata), 
		.mstr(mstr), 
		.cpol(cpol), 
		.cpha(cpha), 
		.lsbfe(lsbfe), 
		.spiswai(spiswai), 
		.sppr(sppr), 
		.spr(spr), 
		.spi_interrupt_request(spi_interrupt_request), 
		.pready(pready), 
		.pslverr(pslverr), 
		.send_data(send_data), 
		.mosi_data(mosi_data), 
		.spi_mode(spi_mode)
	);
	
	always #5 pclk=~pclk;
	
	task init();
	begin
		pclk = 0;
		preset_n =1;
		paddr = 0;
		pwrite = 0;
		psel = 0;
		penable = 0;
		pwdata = 0;
		ss = 0;
		miso_data = 0;
		receive_data = 0;
		tip = 1;
	//	@(negedge pclk);
	end
	endtask
		
	task reset();
	begin
	 preset_n=0;
		@(negedge pclk)
		preset_n=1;
	end
	endtask
	
	task data(input [7:0] a,input[2:0]b);
	begin
	//ss=0;
	paddr=b;
	pwrite=1;
	psel=1;penable=0;
	pwdata=a;
	//receive_data=0;
	//tip=0;
	@(negedge pclk);
		penable=1;
	//	miso_data=b;
//	@(negedge pclk);
	wait(pready)
	@(negedge pclk);
		penable=0;
		@(negedge pclk);

		end
		endtask

	initial begin
	init;
	reset;
	data(8'b01010001,3'b000);
	data(8'b01110110,3'b001);
	data(8'b11111000,3'b010);
	data(8'b010101010,3'b101);
	
	
	end
      
endmodule

