module top(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,miso,ss,sclk,spi_interrupt_request,mosi,prdata,pready,pslverr);
	
	input pclk,preset_n,pwrite,psel,penable,miso;
	input [7:0]pwdata;
	input [2:0]paddr;
	output ss,sclk,spi_interrupt_request,mosi,pready,pslverr;
	output [7:0]prdata;

	wire [1:0]spi_mode;             // slave select
	wire [11:0]BaudRateDivisor;     // slave select

	//wire [1:0] spi_mode;           // baud rate
	wire  [2:0] sppr,spr;          // baud rate
	//wire [11:0] BaudRateDivisor;   // baud rate

	wire [7:0] data_mosi;           //shift register
	wire [7:0]data_miso;            // shift register

//	wire [2:0]paddr;               //APB slave
	//wire [7:0]pwdata,miso_data;    //APB slave
	//wire  [1:0]spi_mode;           //APB slave
	//wire [2:0]sppr,spr;            //APB slave
	//wire [7:0]prdata;              //APB slave

	slave_select dut1(.pclk(pclk),.preset_n( preset_n),.mstr(mstr),.spiswai(spiswai), .spi_mode(spi_mode), .send_data(send_data),.BaudRateDivisor(BaudRateDivisor), .recieve_data(receive_data), .ss(ss), .tip(tip));

	baud_rate dut2(.Pclk(pclk),.PRESET_n(preset_n),.spi_mode(spi_mode),.spiswai(spiswai),.sppr(sppr),.spr(spr),.cpol(cpol),.cpha(cpha),.ss(ss),.sclk(sclk),.miso_recieve_sclk(miso_recieve_sclk),.miso_recieve_sclk0(miso_recieve_sclk0),.mosi_send_sclk(mosi_send_sclk),.mosi_send_sclk0(mosi_send_sclk0),.BaudRateDivisor(BaudRateDivisor));
	
	//shift_register dut3(.pclk(pclk),.preset_n(preset_n),.ss(ss),.send_data(send_data),.lsbfe(lsbfe),.cpha(cpha),.cpol(cpol),.miso_recieve_sclk(miso_recieve_sclk),.miso_recieve_sclk0(miso_recieve_sclk0),.mosi_send_sclk(mosi_send_sclk),.mosi_send_sclk0(mosi_send_sclk0),.data_mosi(data_mosi),.miso(miso),.recieve_data(receive_data),.mosi(mosi),.data_miso(data_miso));

//	APB_slave dut4(.pclk(pclk),.preset_n(preset_n),.paddr(paddr),.pwrite(pwrite),.psel(psel),.penable(penable),.pwdata(pwdata),.ss(ss),.miso_data(data_miso),.receive_data(receive_data),.tip(tip),.prdata(prdata),.mstr(mstr),.cpol(cpol),.cpha(cpha),.lsbfe(lsbfe),.spiswai(spiswai),.sppr(sppr),.spr(spr),.spi_interrupt_request(spi_interrupt_request),.pready(pready),.pslverr(pslverr),.send_data(send_data),.mosi_data(mosi),.spi_mode(spi_mode));
	
shift_register dut3(pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,data_mosi,miso,receive_data,mosi,data_miso);
APB_slave dut4(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,ss,data_miso,receive_data,tip,prdata,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spi_interrupt_request,pready,pslverr,send_data,data_mosi,spi_mode);




	endmodule
