library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity DE1_MO5 is
  port (
		--	Clock Input
		CLOCK_24      : in   std_logic;		                  -- 24 MHz
		CLOCK_50  	  : in   std_logic;		                  --	50 MHz
		--	Push Button		
		KEY           : in   std_logic_vector(3 downto 0);    --	Pushbutton[3:0]
		-- DPDT Switch	
		SW            : in   std_logic_vector(9 downto 0);  	-- Toggle Switch[9:0]
		--	7-SEG Dispaly	
		HEX0 			  : out  std_logic_vector(6 downto 0);		--	Seven Segment Digit 0
		HEX1			  : out  std_logic_vector(6 downto 0);		--	Seven Segment Digit 1
		HEX2			  : out  std_logic_vector(6 downto 0);		--	Seven Segment Digit 2
		HEX3			  : out  std_logic_vector(6 downto 0);		--	Seven Segment Digit 3
		-- LED	
		LEDG          : out   std_logic_vector(7 downto 0);	--	LED Green[7:0]
		LEDR          : out   std_logic_vector(9 downto 0);	--	LED Red[9:0]
		--	UART	
		UART_TXD 	  : out   std_logic; 					      --	UART Transmitter
		UART_RXD 	  : in    std_logic;  					      -- UART Receiver
		--	Flash Interface
		FL_DQ         : inout std_logic_vector(7 downto 0);	--	FLASH Data bus 8 Bits
		FL_ADDR		  : out   std_logic_vector(21 downto 0);  -- FLASH Address bus 22 Bits
		FL_WE_N		  : out   std_logic;  							-- FLASH Write Enable
		FL_RST_N      : out   std_logic;      				      --	FLASH Reset
		FL_OE_N       : out   std_logic;						      --	FLASH Output Enable
		FL_CE_N       : out   std_logic;				    	 	   --	FLASH Chip Enable
		--	SRAM Interface
		SRAM_DQ       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
		SRAM_ADDR     : out   std_logic_vector(17 downto 0);  --	SRAM Address bus 18 Bits
		SRAM_UB_N     : out   std_logic; 						   --	SRAM High-byte Data Mask 
		SRAM_LB_N	  : out   std_logic;                      --	SRAM Low-byte Data Mask 
		SRAM_WE_N     : out	 std_logic;								--	SRAM Write Enable
		SRAM_CE_N	  : out	 std_logic;								--	SRAM Chip Enable
		SRAM_OE_N	  : out	 std_logic;								--	SRAM Output Enable
		-- SD_Card Interface	
		SD_DAT		  : in    std_logic;								--	SD Card Data            MISO
		SD_DAT3       : out   std_logic;			   				-- SD Card Data 3          CS
		SD_CMD		  : out   std_logic;								--	SD Card Command Signal  MOSI
		SD_CLK		  : out   std_logic;		   					--	SD Card Clock           SCLK
		-- I2C
		I2C_SDAT      : inout std_logic; 							--	I2C Data
		I2C_SCLK      : out   std_logic;								--	I2C Clock
		-- PS2
		PS2_DAT       : inout std_logic; 						   -- PS2 Data
		PS2_CLK       : inout std_logic;						 		-- PS2 Clock
		-- VGA
		VGA_HS        : out   std_logic;							   --	VGA H_SYNC
		VGA_VS        : out   std_logic;							   --	VGA V_SYNC
		VGA_R         : out   std_logic_vector(3 downto 0);   --	VGA Red[3:0]
		VGA_G         : out   std_logic_vector(3 downto 0);	--	VGA Green[3:0]
		VGA_B         : out   std_logic_vector(3 downto 0);   --	VGA Blue[3:0]
		--	Audio CODEC
		AUD_ADCLRCK   : inout std_logic;								--	Audio CODEC ADC LR Clock
		AUD_ADCDAT    : in    std_logic;								--	Audio CODEC ADC Data
		AUD_DACLRCK   : inout std_logic;								--	Audio CODEC DAC LR Clock
		AUD_DACDAT    : out   std_logic;								--	Audio CODEC DAC Data
		AUD_BCLK      : inout std_logic;								--	Audio CODEC Bit-Stream Clock
		AUD_XCK       : out   std_logic								--	Audio CODEC Chip Clock
	);
end entity;	

architecture top of DE1_MO5 is

component hexto7seg is
  port (
	   hex           : in   std_logic_vector(3 downto 0);
		seg           : out  std_logic_vector(6 downto 0)
	);
end component;	

component ram_initializer is
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        clock_ready : in  std_logic;
		  reset_out   : in  std_logic;
        ram_address : out std_logic_vector(18 downto 0);
        ram_data    : out std_logic_vector(7 downto 0);
        ram_cs_n    : out std_logic;
        ram_rw      : out std_logic;
        init_done   : out std_logic;
        cpu_reset_n : out std_logic
    );
end component;

component sram is
  port (
--    8 bits bus interface 
      address       : in    std_logic_vector(18 downto 0);
		data_in       : in    std_logic_vector(7  downto 0);
		data_out      : out   std_logic_vector(7  downto 0);
		cs_n          : in    std_logic;
		rw            : in    std_logic;
--    16 bits sram interface   		
 	   SRAM_DQ       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
		SRAM_ADDR     : out   std_logic_vector(17 downto 0);  --	SRAM Address bus 18 Bits
		SRAM_UB_N     : out   std_logic; 						   --	SRAM High-byte Data Mask 
		SRAM_LB_N	  : out   std_logic;                      --	SRAM Low-byte Data Mask 
		SRAM_WE_N     : out	 std_logic;								--	SRAM Write Enable
		SRAM_CE_N	  : out	 std_logic;								--	SRAM Chip Enable
		SRAM_OE_N	  : out	 std_logic								--	SRAM Output Enable
	);
end component;	

component flash is
    Port (
        reset_n     : in  STD_LOGIC;                          -- Active low reset
        address     : in  STD_LOGIC_VECTOR(21 downto 0);      -- Address bus
        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);       -- Data input (for write operations)
        data_out    : out STD_LOGIC_VECTOR(7 downto 0);       -- Data output (for read operations)
        rw          : in  STD_LOGIC;                          -- Read/Write signal (1 = read, 0 = write)
        cs_n        : in  STD_LOGIC;                          -- Chip select (active high)
		  FL_DQ       : inout std_logic_vector(7 downto 0);	  --	FLASH Data bus 8 Bits
	  	  FL_ADDR	  : out   std_logic_vector(21 downto 0);    -- FLASH Address bus 22 Bits
		  FL_WE_N	  : out   std_logic;  							  -- FLASH Write Enable
		  FL_RST_N    : out   std_logic;      				        -- FLASH Reset
		  FL_OE_N     : out   std_logic;						        -- FLASH Output Enable
		  FL_CE_N     : out   std_logic				    	 	     -- FLASH Chip Enable
    );
end component;

component MO5_CLOCK is
	Port ( 
		clk50       : in  std_logic;
		clk24       : in  std_logic;
		reset_n     : in  std_logic;
		clock_sel   : in  std_logic;
		vga_clock   : out std_logic;
		cpu_clock   : out std_logic;
		synlt_clock : out std_logic;
		sound_clock : out std_logic;
		ready       : out std_logic
    );
end component;

component MO5_CPU IS
	port	(
		cpu_reset_n  : in  std_logic := '1';
		cpu_clk      : in  std_logic;
		address      : out std_logic_vector(15 downto 0);
		data_in      : in  std_logic_vector(7 downto 0);
		data_out     : out std_logic_vector(7 downto 0);
		nmi_n        : in  std_logic;
		irq_n        : in  std_logic;
		firq_n       : in  std_logic;
		vma          : out std_logic;
		rw           : out std_logic;
		halt_n       : in  std_logic
	);
end component;

component MO5_RAM is
  port (
      address       : in    std_logic_vector(15 downto 0);  -- cpu address
		ram_address   : out   std_logic_vector(18 downto 0);  -- ram address
		forme         : in    std_logic;                      -- forme signal
		a7cf          : in    std_logic_vector(7 downto 0);   -- a7cf register    
		prcart_n      : out   std_logic;                      -- basic disable
		nscart_n      : in    std_logic;                      -- cartouche chip select
		ram_cs_n      : out   std_logic                       -- ram chip select
	);
end component;	

component MO5_ROM is
  port (
      address       : in    std_logic_vector(15 downto 0);  -- cpu address
		flash_address : out   std_logic_vector(21 downto 0);  -- flash address
		prcart_n      : in    std_logic;                      -- basic disable
		nscart_n      : out   std_logic;                      -- cartouche chip select
		cartsel       : in    std_logic_vector(3 downto 0);   -- cartouche selection (for testing)
		flash_cs_n    : out   std_logic                       -- flash chip select
	);
end component;	

component MO5_PIA IS
	port	(
		reset_n      : in  std_logic := '1';
		cpu_clk      : in  std_logic;
		address      : in  std_logic_vector(15 downto 0);
		data_in      : in  std_logic_vector(7 downto 0);
		data_out     : out std_logic_vector(7 downto 0);
		irq_n        : out std_logic := '1';
		firq_n       : out std_logic := '1';
		rw           : in  std_logic;
		cs_n         : in  std_logic;
		border_color : out std_logic_vector(3 downto 0);
		forme        : out std_logic;
		kbd_row      : out std_logic_vector(2 downto 0);
		kbd_col      : out std_logic_vector(2 downto 0);
		kbd_data     : in  std_logic;
		sound        : out std_logic;
		lep_in       : in  std_logic;
		lep_out      : out std_logic;
		lep_mtr      : out std_logic;
		synlt_clock  : in  std_logic;
		lightpen_btn : in  std_logic;
		lightpen_sig : in  std_logic;
		incrust      : out std_logic
	);
end component;

component MO5_KBD is
    Port ( 
		  clk            : in  std_logic;
		  reset_n        : in  std_logic;
		  mode           : in  std_logic_vector(1 downto 0);
		  ps2_clk        : in  std_logic;
		  ps2_dat        : in  std_logic;
		  kbd_address    : in  std_logic_vector(5 downto 0);
		  kbd_data_out   : out std_logic;
  	     reset_out      : out std_logic := '0'
    );
end component;

component MO5_SOUND is
    Port ( 
        CLOCK_50      : in    std_logic;                   -- 50MHz system clock
        clock_48Khz   : in    std_logic;                   -- 48 Khz clock
        reset_n       : in    std_logic;
        sound         : in    std_logic;                   -- 1 bit sound signal                
        I2C_SCLK      : out   std_logic;                   -- I2C Clock
        I2C_SDAT      : inout std_logic;                   -- I2C Data
        AUD_ADCLRCK   : out   std_logic;                   -- ADC LR Clock
        AUD_ADCDAT    : in    std_logic;                   -- ADC Data
        AUD_DACLRCK   : out   std_logic;                   -- DAC LR Clock
        AUD_DACDAT    : out   std_logic;                   -- DAC Data
        AUD_XCK       : out   std_logic;                   -- Codec Master Clock
        AUD_BCLK      : out   std_logic                    -- Bit-Stream Clock
    );
end component;

component MO5_MON is
	port (
		address	: in  std_logic_vector(11 downto 0);
		clock		: in  std_logic := '1';
		q		   : out std_logic_vector(7 downto 0)
	);
END component;

component MO5_VIDEO is
	generic(
		htotal   :  integer   := 800;
		hdisp		:	integer   := 640;		
		hpol		:	std_logic := '0';		
		hswidth	:	integer   := 96;    	
		hfp	 	:	integer   := 16;		
		hbp	 	:	integer   := 48;		
		vtotal   :  integer   := 525;
		vdisp		:	integer   := 480;		
		vpol		:	std_logic := '0';		
		vswidth 	:	integer   := 2;		
		vbp	 	:	integer   := 33;		
		vfp	 	:	integer   := 10		
	);
   port (
		reset_n           : in    std_logic;
--    memory interface
		cpu_clk           : in    std_logic;
      address           : in    std_logic_vector(15 downto 0);
		data_in           : in    std_logic_vector(7  downto 0);
		forme             : in    std_logic;
		rw                : in    std_logic;
		vma               : in    std_logic;
		border_color      : in    std_logic_vector(3 downto 0);		
--    vga interface
		vga_clk           : in    std_logic;
		VGA_HS  				: out   std_logic;						   --	VGA H_SYNC
		VGA_VS        		: out   std_logic;						   --	VGA V_SYNC
		VGA_R             : out   std_logic_vector(3 downto 0);  --	VGA Red[3:0]
		VGA_G             : out   std_logic_vector(3 downto 0);	--	VGA Green[3:0]
	   VGA_B             : out   std_logic_vector(3 downto 0)   --	VGA Blue[3:0]
	);
end component;

component MO5_SDDRIVE is
    port    (
        reset_n      : in  std_logic := '1';
        cpu_clk      : in  std_logic;
        address      : in  std_logic_vector(15 downto 0);
        data_in      : in  std_logic_vector(7 downto 0);
        data_out     : out std_logic_vector(7 downto 0);
        rw           : in  std_logic;
        vma          : in  std_logic;
		  sd_cs        : out std_logic;
		  sd_sck       : out std_logic;
		  sd_miso      : in  std_logic;
		  sd_mosi      : out std_logic;
		  led_green    : out std_logic;
		  led_red      : out std_logic
    );
end component;


-- video parameters for 1024x768 VGA screen  with a 960x600 mo5 video 
constant HTOTAL  : integer   := 1344;
constant HDISP   : integer   := 1024;
constant HPOL    : std_logic := '0';
constant HSWIDTH : integer   := 136;
constant HFP     : integer	  := 24;		
constant HBP	    : integer   := 160;		
constant VTOTAL  : integer   := 806;
constant VDISP	 : integer   := 768;
constant VPOL	 : std_logic := '0';			
constant VSWIDTH : integer   := 6;		
constant VBP	    : integer   := 29;		
constant VFP	    : integer   := 3;


--signal synlt_last       : std_logic := '1';

signal reset_n          : std_logic := '1';    
signal cpu_reset_n      : std_logic := '1';

signal cpu_clock        : std_logic;     -- 1Mhz    cpu clock  
signal synlt_clock      : std_logic;     -- 50Hz    mo5 SYNLT clock
signal vga_clock        : std_logic;     -- 25Mhz   vga clock 640x480
signal sound_clock      : std_logic;     -- 48Khz   sound digitizing clock

signal address          : std_logic_vector(15 downto 0);
signal ram_address      : std_logic_vector(18 downto 0);
signal flash_address    : std_logic_vector(21 downto 0);

signal rw               : std_logic;
signal vma              : std_logic;

signal ram_cs_n         : std_logic;
signal flash_cs_n       : std_logic;
signal sddrive_cs_n     : std_logic;
signal pia_cs_n         : std_logic;

signal irq_n            : std_logic;
signal firq_n           : std_logic;

signal data_in_cpu      : std_logic_vector(7 downto 0);
signal data_out_cpu     : std_logic_vector(7 downto 0);
signal data_out_pia     : std_logic_vector(7 downto 0);
signal data_out_ram     : std_logic_vector(7 downto 0);
--signal data_out_rom     : std_logic_vector(7 downto 0);
signal data_out_mon     : std_logic_vector(7 downto 0);
signal data_out_flash   : std_logic_vector(7 downto 0);
signal data_out_sddrive : std_logic_vector(7 downto 0);

signal border_color     : std_logic_vector(3 downto 0);
signal cartsel          : std_logic_vector(3 downto 0);
signal prcart_n         : std_logic := '1';
signal nscart_n         : std_logic;
signal forme            : std_logic;
signal kbd_row          : std_logic_vector(2 downto 0);
signal kbd_col          : std_logic_vector(2 downto 0);
signal kbd_data         : std_logic;
signal sound            : std_logic;
signal sound_out        : std_logic;
signal lep_in           : std_logic;
signal lep_out          : std_logic;
signal lep_mtr          : std_logic;

signal xi2c_sclk        : std_logic;
signal xi2c_sdat        : std_logic;
signal clock_ready      : std_logic;

signal display       : std_logic_vector(15 downto 0);

signal cklp_n           : std_logic;
signal lp_btn           : std_logic;

signal sddrive_green    : std_logic := '0';
signal sddrive_red      : std_logic := '0';
signal reset_out        : std_logic := '0';

signal init_done       : std_logic := '0';
signal ram_init_addr   : std_logic_vector(18 downto 0);
signal ram_init_data   : std_logic_vector(7 downto 0);
signal ram_init_cs_n   : std_logic;
signal ram_init_rw     : std_logic;
signal init_cpu_reset_n: std_logic;

signal ram_data_mux   : std_logic_vector(7 downto 0);
signal ram_addr_mux   : std_logic_vector(18 downto 0);
signal ram_cs_n_mux   : std_logic;
signal ram_rw_mux     : std_logic;

signal sd_sck         : std_logic;
signal sd_cs          : std_logic;
signal sd_miso        : std_logic;
signal sd_mosi        : std_logic;


begin
	display <= address;
	
	
-- connect the cpu address to the hexa display
	h0 : hexto7seg port map  (hex => display(3  downto 0),   seg => HEX0); 
	h1 : hexto7seg port map  (hex => display(7  downto 4),   seg => HEX1); 
	h2 : hexto7seg port map  (hex => display(11 downto 8),   seg => HEX2); 
	h3 : hexto7seg port map  (hex => display(15 downto 12),  seg => HEX3); 

	I2C_SCLK <= xi2c_sclk;
	xi2c_sdat <= I2C_SDAT;

	init: ram_initializer       port map(clk                => cpu_clock,
													reset_n             => reset_n,
													clock_ready         => clock_ready,
													reset_out           => reset_out,
													ram_address         => ram_init_addr,
													ram_data            => ram_init_data,
													ram_cs_n            => ram_init_cs_n,
													ram_rw              => ram_init_rw,
													init_done           => init_done,
													cpu_reset_n         => init_cpu_reset_n);
													
												
	clks: MO5_CLOCK            port map(clk50               => CLOCK_50,
													clk24	         	  => CLOCK_24,
											  	   reset_n             => reset_n,
													clock_sel           => SW(2),
													vga_clock           => vga_clock,
													cpu_clock           => cpu_clock,
													synlt_clock         => synlt_clock,
													sound_clock         => sound_clock,
													ready               => clock_ready);

-- connect sram controller
	RAM2: sram                  port map(address     => ram_addr_mux,
												    data_in     => ram_data_mux,
                                        data_out    => data_out_ram,
                                        cs_n        => ram_cs_n_mux,
                                        rw          => ram_rw_mux,
                                        SRAM_DQ     => SRAM_DQ,
                                        SRAM_ADDR   => SRAM_ADDR,
                                        SRAM_UB_N   => SRAM_UB_N,
                                        SRAM_LB_N   => SRAM_LB_N,
                                        SRAM_WE_N   => SRAM_WE_N,
                                        SRAM_CE_N   => SRAM_CE_N,
                                        SRAM_OE_N   => SRAM_OE_N);
													 
-- connect flash controller					
	FLSH: flash                 port map(reset_n            => reset_n, 
													 address            => flash_address,
											  	    data_in            => data_out_cpu,
													 data_out           => data_out_flash,
													 rw                 => rw,
													 cs_n               => flash_cs_n,
													 FL_ADDR            => FL_ADDR,
													 FL_DQ              => FL_DQ,
													 FL_CE_N            => FL_CE_N,
												 	 FL_OE_N            => FL_OE_N,
													 FL_WE_N            => FL_WE_N,
											 		 FL_RST_N           => FL_RST_N);
													 
									 
-- implement the cpu  actually a 6800 core (just a wrapper to John Kent core to have the signal as close as possible to a real 6802)
	CPU: MO5_CPU     			    port map  (cpu_reset_n      => cpu_reset_n,
														cpu_clk          => cpu_clock,
														address          => address,
														data_in          => data_in_cpu,
														data_out         => data_out_cpu,
														nmi_n            => '1',
														irq_n            => irq_n,
														firq_n           => firq_n,
														vma              => vma,
														rw               => rw,
														halt_n           => '1');

-- map MO5 ram to sram space
	RAM: MO5_RAM    			    port map  (address         => address,
														ram_address     => ram_address,
														forme           => forme,
														a7cf            => x"00",
														prcart_n        => prcart_n,
														nscart_n        => nscart_n,
														ram_cs_n        => ram_cs_n);
											
-- map MO5 rom to flash space											
	ROM: MO5_ROM                  port map(address         => address,
													   flash_address   => flash_address,
														prcart_n        => prcart_n,
														nscart_n        => nscart_n,
														cartsel         => cartsel,
														flash_cs_n      => flash_cs_n);


	MON: MO5_MON                  port map(address        => address(11 downto 0),
											   	   clock          => cpu_clock,
		  											   q              => data_out_mon);


   PIA: MO5_PIA                 port map (reset_n         => cpu_reset_n,
														cpu_clk         => cpu_clock,
														address         => address,
														data_in      	 => data_out_cpu,
														data_out        => data_out_pia,
														irq_n           => irq_n,
														firq_n          => firq_n,
														rw              => rw,
														cs_n            => pia_cs_n,
														border_color    => border_color,
														forme           => forme,
														kbd_row         => kbd_row,
														kbd_col         => kbd_col,
														kbd_data     	 => kbd_data,
														sound           => sound,
														lep_in          => lep_in,
														lep_out         => lep_out,
														lep_mtr         => lep_mtr,
														synlt_clock   	 => synlt_clock,
														lightpen_btn    => lp_btn,
														lightpen_sig    => cklp_n,
														incrust      	 => open);
														
	SND: MO5_SOUND                 port map(CLOCK_50       => CLOCK_50,
														 clock_48Khz    => sound_clock,
														 reset_n        => reset_n,
	 													 sound          => sound,
														 I2C_SCLK       => xi2c_sclk,
														 I2C_SDAT       => xi2c_sdat,
														 AUD_ADCLRCK    => AUD_ADCLRCK,
														 AUD_ADCDAT     => AUD_ADCDAT,
														 AUD_DACLRCK    => AUD_DACLRCK,
														 AUD_DACDAT     => AUD_DACDAT,
														 AUD_XCK        => AUD_XCK,
														 AUD_BCLK       => AUD_BCLK);
														
-- instantiate the mo5 video (actually limited to a static color bar)
	VDU: MO5_VIDEO             generic map(htotal              => HTOTAL,
														hdisp		           => HDISP,		
														hpol		           => HPOL,		
														hswidth	           => HSWIDTH,    	
														hfp	 	           => HFP,		
														hbp	 	           => HBP,		
														vtotal              => VTOTAL,
														vdisp		           => VDISP,		
														vpol		           => VPOL,			
														vswidth 	           => VSWIDTH,		
														vbp	 	           => VBP,		
														vfp	 				  => VFP)
										   port map(reset_n             => cpu_reset_n,
														cpu_clk             => cpu_clock,
														address             => address,
														data_in             => data_out_cpu,
														forme               => forme,
														rw                  => rw,
														vma                 => vma,
														border_color        => border_color,
														vga_clk             => vga_clock,
														VGA_HS  	           => VGA_HS,
														VGA_VS     		     => VGA_VS,
														VGA_R               => VGA_R,
														VGA_G               => VGA_G,
														VGA_B               => VGA_B);
														
	KBD : MO5_KBD						port map(clk                 => cpu_clock,
														reset_n             => cpu_reset_n,
														mode                => SW(1 downto 0),
														ps2_clk             => PS2_CLK,
														ps2_dat             => PS2_DAT,
														kbd_address      	  => kbd_col & kbd_row,
														kbd_data_out     	  => kbd_data,
														reset_out           => reset_out);
														
	SDD : MO5_SDDRIVE             port map(reset_n             => reset_n,
														cpu_clk             => cpu_clock,
												  	   address             => address,
														data_in             => data_out_cpu,
														data_out            => data_out_sddrive,
														rw                  => rw,
														vma                 => vma,
														sd_cs               => sd_cs,
														sd_sck              => sd_sck,
														sd_miso             => sd_miso,
														sd_mosi             => sd_mosi,
														led_green           => sddrive_green,
														led_red             => sddrive_red);
														
														
	ram_addr_mux <= ram_init_addr when init_done = '0' else ram_address;
	ram_data_mux <= ram_init_data when init_done = '0' else data_out_cpu;
	ram_cs_n_mux <= ram_init_cs_n when init_done = '0' else ram_cs_n;
	ram_rw_mux   <= ram_init_rw   when init_done = '0' else rw;													

-- implement the reset signal witk KEY(0)  top right push button
   reset_n     <= KEY(0);

-- compute the chip select according to the address range	
	pia_cs_n     <= '0' when vma = '1' and address(15 downto 2)  = x"A7C" & "00"    else '1';
   sddrive_cs_n <= '1' when vma = '1' and address(15 downto 0)  = x"A7BF"          else '0';

-- multiplex the output of all devices to the cpu data_in	
	data_in_cpu  <= data_out_ram     when rw = '1' and vma = '1' and address(15 downto 12) < x"A"                                       else -- ram     $0000 to $9FFF  (video + main)
						 data_out_pia     when rw = '1' and vma = '1' and address(15 downto 2)  = x"A7C" & "00"                              else -- pia  in $A7C0 to $A7C3  
						 data_out_flash   when rw = '1' and vma = '1' and address(15 downto 12) = x"B"                                       else -- opt rom $B000 to $EFFF
						 data_out_flash   when rw = '1' and vma = '1' and address(15 downto 12) = x"C"                                       else -- opt rom $B000 to $EFFF
						 data_out_flash   when rw = '1' and vma = '1' and address(15 downto 12) = x"D"                                       else -- opt rom $B000 to $EFFF
						 data_out_flash   when rw = '1' and vma = '1' and address(15 downto 12) = x"E"                                       else -- opt rom $B000 to $EFFF
						 data_out_mon     when rw = '1' and vma = '1' and address(15 downto 12) = x"F"                                       else -- mon rom $F000 to $FFFF  mo5 mon or debug
						 data_out_sddrive when rw = '1' and vma = '1' and address(15 downto 0) >= x"A000" and address(15 downto 0) < x"A7C0" else
						 address(15 downto 8);
	
	UART_TXD     <= UART_RXD;	
	
	cartsel           <= "0000";
	
   SD_DAT3 <= sd_cs;	
	SD_CLK  <= sddrive_cs_n;
   SD_CMD  <= sd_mosi;
	sd_miso <= SD_DAT;
	
	LEDR              <= SW;
	LEDG(3 downto 0)  <= KEY;
	LEDG(4)           <= lep_out;
	LEDG(5)           <= lep_mtr;
	lp_btn            <= KEY(1);
	cklp_n            <= KEY(2);
	
	cpu_reset_n <= init_cpu_reset_n;

	
end top;