
module APB_slave(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,ss,miso_data,receive_data,tip,prdata,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spi_interrupt_request,pready,pslverr,send_data,mosi_data,spi_mode);

	input pclk,preset_n,pwrite,psel,penable,ss,receive_data,tip;
	input [2:0]paddr;
	input [7:0]pwdata,miso_data;

	output  mstr,cpol,cpha,lsbfe,spiswai,pready,pslverr;
	output reg send_data,spi_interrupt_request;
	output reg [7:0]mosi_data;
	output reg [1:0]spi_mode;
	output [2:0]sppr,spr;
	output reg[7:0]prdata;

	reg [1:0]ns,ps; //APB states
	reg [1:0]nmode; //SPI mode States

	parameter idle=2'b00,setup=2'b01,enable=2'b10; //For APB
	parameter run=2'b00,spi_wait=2'b01,stop=2'b10; //For SPI 

	reg [7:0]spi_cr1; //  control register 1
	reg [7:0]spi_cr2; // control register 2

	reg[7:0]spi_br; // baud register
	
	wire[7:0] spi_sr; //status register
	reg[7:0] spi_dr; //data register

	wire wr_en,rd_en; // read or write enable

	wire spie,spe,sptie,ssoe;  // cr1 bits
	wire modfen; //cr2 bits
	wire spif,sptef; /// status register bits
	reg modf; //status Register Bits

   wire [7:0] cr2_mask=8'b00011011;  // mask value for control register
	wire[7:0] br_mask=8'b01110111;  // mask value for baud rate register
	
	assign lsbfe=spi_cr1[0]; // cr1 bit mapping 
	assign ssoe=spi_cr1[1];
	assign cpha=spi_cr1[2];
	assign cpol=spi_cr1[3]; 
	assign mstr=spi_cr1[4];
	assign sptie=spi_cr1[5];
	assign spe=spi_cr1[6];
	assign spie=spi_cr1[7];

	assign spiswai=spi_cr2[1];  // cr2 bit mapping
	assign modfen=spi_cr2[4];

	assign sppr=spi_br[6:4];  // spi_br bit mapping
	assign spr=spi_br[2:0];

	assign spif=(spi_dr=8'b0)?1:0; //spi_sr bit mapping
	assign sptef=(spi_dr=8'b0)?1:0;

	
	assign wr_en=(pwrite&&(ps==enable))?1:0;
	assign rd_en=(!pwrite&&(ps==enable))?1:0;

	

	// registers bit ?

	//mask?
	
	always @(*)             // modf(detect mode fault)
	begin
		if(!ss && mstr && modfen && !ssoe)
			modf=1'b1;
		else 
			modf=1'b0;
	end

	always @(*)          // interrupt request based on the spi control bits and status register
	begin
		if(!spie && !sptie)
			spi_interrupt_request=0;
		else if(spie && !sptie)
			spi_interrupt_request= (spif | modf);
		else if(!spie && sptie)
			spi_interrupt_request=sptef;
		else 
			spi_interrupt_request= (spif | modf | sptef);
	end

			

	

	assign pready=(ps==enable)?1:0;  // For Pready
	assign pslverr=(ps==enable)?~tip:1'b0;  //For Slave error
	assign spi_sr=(!preset_n)?8'b00100000:{spif,1'b0,sptef,modf,4'b0}; // For SPI_SR



	always @(posedge pclk)  //spi_mode fsm for(sequential logic) present state
	begin
		if(!preset_n)
			spi_mode<=run;
		else 
			spi_mode<=nmode;
	end

	always @(*)    // spi_mode fsm (combo logic) next state
	begin
		nmode=run;
		case(ps)
			run:if(!spe) nmode=spi_wait;
				else nmode=run;
			spi_wait:if(!spiswai && !spe ) ns=spi_wait;
				else if(spiswai) nmode=stop;
				else nmode=run;
			stop:if(!spiswai)nmode=spi_wait;
				else if(spe) nmode=run;
				else nmode=stop;
		endcase
	end

	always @(posedge pclk)  //APB fsm(sequential logic) present state
	begin
		if(!preset_n)
			ps<=idle;
		else 
			ps<=ns;
	end

	always @(*) begin //APB fsm(combo logic ) next state
		ns=idle;
		case(ps)
			idle:if(psel &&!penable) ns=setup;
				else ns=idle;
			setup:if(psel && penable) ns=enable;
				else if(!psel)
					ns=idle;
				else ns= setup;
			enable:if(psel) ns=setup;
					else ns=idle;
		endcase
	end

	always@(*)begin  //Read for ALL Regiser 
		if(!preset_n)
			prdata=8'b0;
		else if(rd_en)
			case(paddr)
				3'b000:prdata=spi_cr1;
				3'b001:prdata=spi_cr2;
				3'b010:prdata=spi_br;
				3'b011:prdata=spi_sr;
				3'b101:prdata=spi_dr;
				default:prdata=8'b0;
			endcase
		else
			prdata=prdata;
		end

	always @(posedge pclk)        // For Write in control Register 1
	begin
		if(!preset_n)
			spi_cr1<=8'h04;
		else
		begin
			if(wr_en)
			begin
				if(paddr==3'b000)
					spi_cr1<=pwdata;
				else
					spi_cr1<=spi_cr1;
			end
		//	else
		//		spi_cr1<=8'h04;
		end
	end

	 always@(posedge pclk)       // Write For Control Register 2
	 begin
		 if(!preset_n)
			 spi_cr2<=8'h00;
		 else
		 begin
			 if(wr_en)
			 begin
				 if(paddr==3'b001)
					 spi_cr2<=(pwdata & cr2_mask);
				else
					spi_cr2<=spi_cr2;
			end
			//else
			//	spi_cr2<=8'h00;
		end
	end

	
	always@(posedge pclk) //Write For Baud Rate Register
	begin
		if(!preset_n)
			spi_br<=8'h00;
		else
		begin
			if(wr_en)
			begin
				if(paddr==3'b010)
					spi_br<=(pwdata & br_mask);
				else
					spi_br<=spi_br;
			end
			//else
			//	spi_br<=8'h00;
		end
	end

	always @(posedge pclk)   // For the Data Register
	begin
		if(!preset_n)
			spi_dr<=8'b0;
		else if(wr_en)
		       begin
		          if(paddr==3'b101)
		       	  begin
				   spi_dr<=pwdata;
			  end
			  else
				spi_dr<=spi_dr;
			end
			else if(spi_dr==pwdata && spi_dr!=miso_data && (spi_mode==run || spi_mode==spi_wait))
				begin
					spi_dr<=0;
				end
				else if((spi_mode==run || spi_mode==spi_wait) && receive_data )
						spi_dr<=miso_data;
					else
						spi_dr<=spi_dr;
			
	end


	always @(posedge pclk)      // For send data
	begin
		if(!preset_n)
			send_data<=0;
		else
		begin
		
				if(!wr_en&&(spi_dr==pwdata && (spi_dr!=miso_data) &&(spi_mode==run || spi_mode==spi_wait)))
					send_data<=1;
				else
				begin
					if((spi_mode==run || spi_mode==spi_wait) && receive_data)
						send_data<=0;
					else
						send_data<=0;
				end
				end
	end
	

	always @(posedge pclk)  // For Mosi data
	begin
		if(!preset_n)
			mosi_data<=0;
		else
		begin
			if(!wr_en)
			begin
			
				if(spi_dr==pwdata && spi_dr!=miso_data && (spi_mode==run || spi_mode==spi_wait))
					mosi_data<=spi_dr;
				else
				begin
					if(spi_mode==run || spi_mode==spi_wait && receive_data)
						mosi_data<=mosi_data;
				else
					mosi_data<=mosi_data;
				end
			end
			end
	end
	endmodule







			
			


