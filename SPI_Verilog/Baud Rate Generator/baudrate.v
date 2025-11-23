module baud_rate(Pclk,PRESET_n,spi_mode,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,BaudRateDivisor);

	input Pclk,PRESET_n,spiswai,cpol,cpha,ss;
	input [1:0] spi_mode;
	input [2:0] sppr,spr;
	output reg sclk,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0;
	output [11:0] BaudRateDivisor;

	wire pre_sclk;
	reg [11:0] count;

	assign BaudRateDivisor=(sppr+1)*(2**(spr+1)); // Baud Rate Divisor
	assign pre_clk=(cpol)?1:0;     

	//Pre clk

	always @(posedge Pclk or negedge PRESET_n)   // Generate Serial Clk for SPI
	begin
		if(!PRESET_n)
		begin
			count<=0;
			sclk<=pre_clk;
		end
		else if(!ss && (spi_mode==2'b00||spi_mode==2'b01) && !spiswai)
		begin
			if(count==(BaudRateDivisor/2)-1'b1)
				sclk<=~sclk;
			else
				sclk<=sclk;
		end
		else 
			sclk<=pre_clk;
	end

	always @(posedge Pclk or negedge PRESET_n)   //For MISO 
	begin
		if(!PRESET_n)
		begin
			miso_recieve_sclk<=0;
			miso_recieve_sclk0<=0;
		end
		else if(((cpol==0 && cpha==0)||(cpol==1 && cpha==1)))
		begin
			if(!sclk)begin
				if(count==(BaudRateDivisor/2)-1)
					miso_recieve_sclk<=1;
				else

					miso_recieve_sclk<=0;
				end
			else
				miso_recieve_sclk<=0;
		end

		else //if((cpol==0 && cpha==1)||(cpol==1 && cpha==0))
		begin
			if(sclk)
			begin
				if(count==(BaudRateDivisor/2)-1)

					miso_recieve_sclk0<=1;
				else				
					miso_recieve_sclk0<=0;
			end
			else
				miso_recieve_sclk0<=0;
		end
	end
		
	always @(posedge Pclk or negedge PRESET_n)   //For MOSI
		begin
			if(!PRESET_n)
			begin
				mosi_send_sclk<=0;
				mosi_send_sclk0<=0;
			end
			else if(((cpol==0 && cpha==0)||(cpol==1 && cpha==1)))
			begin
				if(!sclk)
					if(count==(BaudRateDivisor/2)-2)
						mosi_send_sclk<=1;
				else	
						mosi_send_sclk<=0;
		  end

		else //if((cpol==0 && cpha==1)||(cpol==1 && cpha==0))
		begin
			if(sclk)
			begin
				if(count==(BaudRateDivisor/2)-2)
					mosi_send_sclk0<=1;
				else
					mosi_send_sclk0<=0;
			end
		else
			mosi_send_sclk0<=0;
		end
		end
		
		always@(posedge Pclk or negedge PRESET_n)
		begin
			if(!PRESET_n)
				count<=12'b0;
			else if(!ss && (spi_mode==2'b00||spi_mode==2'b01) && !spiswai)
			begin
				if(count==(BaudRateDivisor/2)-1'b1)
					count<=12'b0;
				else 
					count<=count+1'b1;
			end
			else 
				count<=12'b0;
			end
		
	endmodule



