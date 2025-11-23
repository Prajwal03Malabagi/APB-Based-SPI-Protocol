module slave_select(pclk, preset_n, mstr, spiswai, spi_mode, send_data, BaudRateDivisor, recieve_data, ss, tip);
	input pclk, preset_n, mstr, spiswai, send_data;
	input [1:0]spi_mode;
	input [11:0]BaudRateDivisor;
	output reg recieve_data, ss;
	output tip;

	reg rcv_s;
	reg [15:0]count_s;
	wire [15:0]target_s;

	assign tip=~ss;
	assign target_s=16*(BaudRateDivisor/2);

	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				recieve_data<=1'b0;
			else
				recieve_data<=rcv_s;	
		end
	

	always@(posedge pclk or negedge preset_n)
		begin
		if(!preset_n)
			rcv_s <=1'b0;
		else if(mstr && !spiswai &&(spi_mode==2'b00 || spi_mode==2'b01))
			begin
				if(send_data)
					rcv_s<=1'b0;
				else
					begin
						if(count_s==target_s-1'b1)
							rcv_s<=1'b1;
						else
							rcv_s<=1'b0;
					end
			end
		else
			rcv_s<=1'b0;
		end


	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				ss<=1'b1;
			else if((mstr && (spi_mode==2'b00 || (spi_mode==2'b01 && !spiswai))))
				begin
					if(send_data)
						ss<=1'b0;
					else
						begin
							if(count_s<=target_s-1'b1)
								ss<=1'b0;
							else
								ss<=1'b1;
						end
				end
			else
					ss<=1'b1;
		end
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				count_s<=16'hffff;
			else if((mstr && !spiswai && (spi_mode==2'b00 || spi_mode==2'b01)))
				begin
					if(send_data)
						count_s<=1'b0;
					else
						begin
							if(count_s<=target_s-1'b1)
								count_s<=count_s+1'b1;
							else
								count_s<=16'hffff;
						end
				end
			else
				count_s<=16'hffff;
		end

endmodule





