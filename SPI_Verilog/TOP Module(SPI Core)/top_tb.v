module top_tb;
	
	reg pclk,preset_n,pwrite,psel,penable,data_miso;
	reg [7:0]pwdata;
	reg [2:0]paddr;
	wire ss,sclk,spi_interrupt_request,data_mosi,pready,pslverr;
	wire [7:0]prdata;
	integer i;

	top dut(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,data_miso,ss,sclk,spi_interrupt_request,data_mosi,prdata,pready,pslverr);

	always #5 pclk=~pclk;

	task init();
		begin
			 {pclk,pwrite,psel,penable,data_miso}=0;
		 end
	 endtask


	task reset();
		begin
			preset_n=1'b0;
			@(negedge pclk)preset_n=1'b1;
		end
	endtask;

	task write(input [2:0]a,input [7:0]b);
		begin
			psel=1'b1;
			pwrite=1'b1;
			paddr=a;
			pwdata=b;
			@(negedge pclk);
			penable=1'b1;
			@(negedge pclk);
			penable=1'b0;
			@(negedge pclk);
		end
	endtask

	task read(input [2:0] addr);
		begin
			psel=1'b1;
			pwrite=1'b0;
			paddr= addr;
			@(negedge pclk)
			penable=1'b1;
			@(negedge pclk)
			psel=0;
		end
	endtask

	task miso();
		begin
			@(negedge sclk)
			for(i=0;i<8;i=i+1)
				data_miso=i;
		end
	endtask;

	initial begin
		init;
		reset;
		write(3'b000,8'b00010111);
		write(3'b001,8'b00010000);
		write(3'b010,8'b00010000);
		write(3'b101,8'b11110011);
		miso;
		read(3'b101);
	end
	endmodule
	
	
