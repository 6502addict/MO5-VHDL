library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity MO5_VIDEO is
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
		VGA_B             : out   std_logic_vector(3 downto 0)  --	VGA Blue[3:0]
	);
end entity;	

architecture rtl of MO5_VIDEO is
	
component vga_ctrl IS
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
	port(
		reset_n		:	in		std_logic;	
		clock_vga	:	in		std_logic;	
		vsync			:	out	std_logic;	
		hsync			:	out	std_logic;	
		row         :  out   integer range 0 to vtotal -1;
		col         :  out   integer range 0 to htotal -1;
		blanking_n 	:	out	std_logic
	);
end component;

component vga_mo5_palette is
  port(
  	 vga_clk  : in  std_logic;
 	 pixel    : in  std_logic_vector(3 downto 0);
	 red      : out std_logic_vector(3 downto 0);
	 green    : out std_logic_vector(3 downto 0);
	 blue	    : out std_logic_vector(3 downto 0)
  ); 
end component;

component vga_translate_640x480 is
	port(
		reset_n		  : in  std_logic;	
		clock_vga	  : in  std_logic;	
		blanking_n    : in  std_logic;
		row           : in  integer range 0 to 767;
		col           : in  integer range 0 to 1023;
		pixel_address : out std_logic_vector(12 downto 0);
		pixel_sel     : out integer range 0 to 7;
		pixel_mode    : out std_logic_vector(1 downto 0)
	);
end component;

component vga_translate_1024x768 is
	port(
		reset_n		  : in	std_logic;	
		clock_vga	  : in	std_logic;	
		blanking_n    : in   std_logic;
		row           : in  integer range 0 to 767;
		col           : in  integer range 0 to 1023;
		pixel_address : out std_logic_vector(12 downto 0);
		pixel_sel     : out integer range 0 to 7;
		pixel_mode    : out std_logic_vector(1 downto 0)
	);
end component;

component shape is
	port(
		data			 : in  std_logic_vector(7 downto 0);
		rdaddress	 : in  std_logic_vector(12 downto 0);
		rdclock		 : in  std_logic;
		wraddress	 : in  std_logic_vector (12 downto 0);
		wrclock		 : in  std_logic ;
		wren		    : in  std_logic := '0';
		q		       : out std_logic_vector (7 downto 0)
	);
end component;

component color is
	port(
		data			 : in  std_logic_vector(7 downto 0);
		rdaddress	 : in  std_logic_vector(12 downto 0);
		rdclock		 : in  std_logic;
		wraddress	 : in  std_logic_vector (12 downto 0);
		wrclock		 : in  std_logic ;
		wren		    : in  std_logic := '0';
		q		       : out std_logic_vector (7 downto 0)
	);
end component;

component pixel_selector is
   port (
		vga_clk      : in  std_logic;
		pixel_shape  : in  std_logic_vector(7 downto 0);
		pixel_sel    : in  integer range 0 to 7;
		pixel_bit    : out std_logic
	);
end component;	

component color_selector is
   port (
		color_sel    : in  std_logic_vector(2 downto 0);
		blk_col      : in  std_logic_vector(3 downto 0);
		brd_col      : in  std_logic_vector(3 downto 0);
		fgnd_col     : in  std_logic_vector(3 downto 0);
		bgnd_col     : in  std_logic_vector(3 downto 0);
		pixel        : out std_logic_vector(3 downto 0)
	);
end component;	
 
signal vsync         : std_logic;	
signal hsync         : std_logic;	
signal blanking_n    : std_logic;	
signal row	         : integer range 0 to 767; 
signal col           : integer range 0 to 1023;
signal pixel         : std_logic_vector(3 downto 0);
signal pixel_address : std_logic_vector(12 downto 0);
signal pixel_sel     : integer range 0 to 7;
signal pixel_shape   : std_logic_vector(7 downto 0);
signal pixel_color   : std_logic_vector(7 downto 0);
signal pixel_mode    : std_logic_vector(1 downto 0);
signal pixel_bit     : std_logic;
signal color_wren    : std_logic;
signal shape_wren    : std_logic;

begin
-- instantiate the vga controller to produce vsync, hsync, blanking and row/col
	ctrl: vga_ctrl    generic map(htotal        => htotal,
									      hdisp		     => hdisp,
		                           hpol		     => hpol,
		                           hswidth	     => hswidth,
		                           hfp	 	     => hfp,
		                           hbp	    	  => hbp,
		                           vtotal        => vtotal,
		                           vdisp		     => vdisp,
		                           vpol		     =>	vpol,
		                           vswidth    	  => vswidth,
		                           vbp	    	  => vbp,
		                           vfp	    	  => vfp)
						  	   port map(reset_n	     => reset_n,
								 		   clock_vga     => vga_clk,
										   vsync		 	  => vsync,
									  	   hsync		     => hsync,
										   row           => row,
										   col           => col,
										   blanking_n 	  => blanking_n);

--	convert the blanking, row and column into the addres of the pixel in the pixel memory
-- or color memory as well as the pixel to display and a pixel mode
-- the pixel mode define if we are in the blanking, the margin or display valid graphic 									
--	tra: vga_translate_640x480   port map(reset_n       => reset_n,
--                                         clock_vga     => vga_clk,
--											        blanking_n    => blanking_n,
--										       	  row           => row,
--											        col           => col,
--											        pixel_address => pixel_address,
--											        pixel_sel     => pixel_sel,
--											        pixel_mode    => pixel_mode);

	tra: vga_translate_1024x768 port map(reset_n       => reset_n,
													 clock_vga     => vga_clk,
											       blanking_n    => blanking_n,
													 row           => row,
											       col           => col,
											       pixel_address => pixel_address,
											       pixel_sel     => pixel_sel,
											       pixel_mode    => pixel_mode);
													
													
-- memory containing the pixel  1 bit per pixels 8 pixels
-- the cpu write at the same time in this memory and in the sram
-- read by vga to produce a byte of pixels
	shp: shape                  port map(data      	   => data_in,
													 rdaddress	   => pixel_address,
													 rdclock       => vga_clk,
													 wraddress     => address(12 downto 0),
													 wrclock       => cpu_clk,
													 wren          => shape_wren,
													 q  		      => pixel_shape);

-- memory containing the foreground / background color 4 bits 2 colors
-- the cpu write at the same time in this memory and in the sram
-- read by vga to produce a byte of color
	clr: color                  port map(data      	   => data_in,
									 			    rdaddress	   => pixel_address,
												    rdclock       => vga_clk,
												    wraddress     => address(12 downto 0),
												    wrclock       => cpu_clk,
												    wren          => color_wren,
												    q  		      => pixel_color);

-- extract the bit to display from the byte of pixels extracted from the "shape" memory
-- and the bit selected (pixel_sel)
   psl: pixel_selector         port map(vga_clk       => vga_clk,
										 	       pixel_shape   => pixel_shape, 
										   	    pixel_sel     => pixel_sel,
											       pixel_bit     => pixel_bit);
											
-- use the pixel mode and the bit extracted by pixel_selector to choose the right color
-- color_sel if formed of the bit extracted previously to select the right color...
-- if I force the color "0000" (black) blk_col, "0110" (cyan) for brd_col (border)
-- and also force fgnd_col to "0100" (blue) and bgnd_col to "0110" (cyan)
-- I get a correct signal in the limit that the color never change
-- but if I set fgnd_col to pixel_color(3 downto 0) and bgnd_col  to pixel_color(7 downto 4)
-- I get after a rebuild either the pixels either the colors
   csl: color_selector         port map(color_sel     => pixel_bit & pixel_mode, 
										 	       blk_col       => "0000",
											       brd_col       => border_color,
											       fgnd_col      => pixel_color(7 downto 4),
											       bgnd_col      => pixel_color(3 downto 0),
											       pixel         => pixel);   

-- connect the mo5 palette	just translate the pixel color into RGB value										
   pal: vga_mo5_palette        port map(vga_clk       => vga_clk,
	                                     pixel         => pixel,
											       red           => VGA_R,
										     	    green         => VGA_G,
											       blue	        => VGA_B);

	shape_wren     <= '1' when vma = '1' and address(15 downto 13) = "000"  and rw = '0' and forme = '1' else '0'; 
	color_wren     <= '1' when vma = '1' and address(15 downto 13) = "000"  and rw = '0' and forme = '0' else '0'; 
											
											
-- connect the vsync and hsync signal to vga port
	VGA_HS   <= hsync;
   VGA_VS   <= vsync;
	
	
end rtl;




