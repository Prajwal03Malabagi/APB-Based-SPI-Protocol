module shift_register_tb;
	reg pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,miso,receive_data;
	reg [7:0] data_mosi;
	wire mosi;
	wire [7:0]data_miso;

	shift_register dut(pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,data_mosi,miso,receive_data,mosi,data_miso);
		

	always #5 pclk=~pclk;
	
	task init();
	begin
	ss=1;send_data=0;
	miso_recieve_sclk=0;miso_recieve_sclk0=0;mosi_send_sclk=0;mosi_send_sclk0=0;receive_data=0;miso=0;
	end
	endtask
		
	

	task reset();
		begin
			preset_n=0;
			@(negedge pclk)preset_n=1;
		end
	endtask

	task data(input [7:0] a);
		begin
			@(negedge pclk)
			ss=0;send_data=1;lsbfe=1;cpol=0;cpha=0;miso_recieve_sclk=1;miso_recieve_sclk0=0;mosi_send_sclk=1;mosi_send_sclk0=0;receive_data=1;data_mosi=a;miso=1;
		end
	endtask

	initial begin
		pclk=0;
		reset;
		data(8'b0101111000);
		#500 $finish();
	end
	endmodule
