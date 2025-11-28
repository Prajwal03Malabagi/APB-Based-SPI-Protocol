module shift_register(pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,data_mosi,miso,recieve_data,mosi,data_miso);

	input pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,miso,recieve_data;
	input [7:0] data_mosi;
	output reg mosi;
	output [7:0]data_miso;

	reg [7:0]shift_register,temp_reg;
	reg [2:0]count,count1,count2,count3;
	
	assign data_miso=(recieve_data)?temp_reg:8'd0;

	always @(posedge pclk,negedge preset_n)
	begin
		if(!preset_n)
			shift_register<=0;
		else if(send_data)
			shift_register<=data_mosi;
		else
			shift_register<=shift_register;
	end
	
	

	always @(posedge pclk) //Receive miso
	begin
		if(!preset_n)
			begin
				//mosi<=1'b0;   due to sim_race commented
				count2<=3'b0;
				count3<=3'd7;
			end
		else 
			begin
				if(!ss)
					begin
						if((cpha&&cpol)||(!cpha&&!cpol))
							begin
								if(lsbfe)
									begin
										if(count2<=7)
											begin
												if(miso_recieve_sclk)
													begin
														temp_reg[count2]<=miso;
														count2<=count2+1;
													end
												else
														count2<=count2;
											end
										else
											count2<=0;
									end
								else
									begin
										if(count3>=3'd0)
											begin
												if(miso_recieve_sclk)
													begin
														temp_reg[count3]<=miso;
														count3<=count3-1;
													end
												else 
													count3<=count3;
											end
										else
											count3<=3'd7;
									end
							end	
						else
							begin
								if(count2<=7)
									begin
										if(miso_recieve_sclk0)
											begin
												temp_reg[count2]<=miso;
												count2<=count2+1;
											end
										else
											count2<=count2;
									end
								else
									count2<=0;
							end
						end
				else
					begin
						if(count3>=3'd0)
							begin
								if(miso_recieve_sclk0)
									begin							
										temp_reg[count3]<=miso;
										count3<=count3-1;
									end
								else 
									count3<=count3;
							end
						else
							count3<=3'd7;
					end
			end
		end
		
		always @(posedge pclk) //Transmit mosi
	begin
		if(!preset_n)
			begin
				mosi<=1'b0;
				count<=3'b0;
				count1<=3'd7;
			end
		else 
			begin
				if(!ss)
					begin
						if((cpha&&cpol)||(!cpha&&!cpol))
							begin
								if(lsbfe)
									begin
										if(count<=7)
											begin
												if(mosi_send_sclk)
													begin
														mosi<=shift_register[count2];
														count<=count+1;
													end
												else
														count<=count;
											end
										else
											count<=0;
									end
								else
									begin
										if(count1>=3'd0)
											begin
												if(mosi_send_sclk)
													begin
														mosi<=shift_register[count3];
														count1<=count1-1;
													end
												else 
													count1<=count1;
											end
										else
											count1<=3'd7;
									end
							end	
						else
							begin
								if(count<=7)
									begin
										if(mosi_send_sclk0)
											begin
												mosi<=shift_register[count];
												count<=count+1;
											end
										else
											count<=count;
									end
								else
									count<=0;
							end
						end
				else
					begin
						if(count1>=3'd0)
							begin
								if(mosi_send_sclk0)
									begin							
										mosi<=shift_register[count1];
										count1<=count1-1;
									end
								else 
									count1<=count1;
							end
						else
							count1<=3'd7;
					end
			end
		end
		
	endmodule

