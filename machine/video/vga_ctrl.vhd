library ieee;
	use ieee.std_logic_1164.all;
	use IEEE.std_logic_arith.all;
	use IEEE.std_logic_unsigned.all;

-- vga timings taken from: http://tinyvga.com/vga-timing	
	
entity vga_ctrl IS
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
end vga_ctrl;

architecture behavior OF vga_ctrl IS
begin
	process (reset_n, clock_vga)
		variable hpos	:	integer range 0 TO htotal - 1 := 0; 
		variable vpos	:	integer range 0 TO vtotal - 1 := 0;
		variable ppos  :  std_logic_vector (18 downto 0);
	BEGIN
	
		if (reset_n = '0') then		
			hpos       := 0;				
			vpos       := 0;				
			ppos       := "0000000000000000000";
			hsync      <= not hpol;		
			vsync      <= not vpol;	
			blanking_n <= '0';		
			
		elsif falling_edge(clock_vga) then
			-- update pixel position
			if (hpos < htotal - 1) then		
				hpos := hpos + 1;
				ppos := ppos + 1;
			else
				hpos := 0;
				if (vpos < vtotal - 1) then	
					vpos := vpos + 1;
				else
					vpos := 0;
				end if;
			end if;
			
			-- export row/column
			if (hpos < hdisp) then  
				col <= hpos;			
			end if;
			if (vpos < vdisp) then	
				row <= vpos;				
			end if;

			-- export address, index
--			index   <= ppos(1 downto 0);
--			address <= ppos(18 downto 2);

			-- generate sync 
			if (vpos < vdisp + vfp OR vpos >= vdisp + vfp + vswidth) then
				vsync <= NOT vpol;		
				ppos := "0000000000000000000";
			else
				vsync <= vpol;			
			end if;
			if (hpos < hdisp + hfp or hpos >= hdisp + hfp + hswidth) then
				hsync <= not hpol;		
			else
				hsync <= hpol;			
			end if;

			-- generate blanking_n
			if (hpos < hdisp AND vpos < vdisp) then
				blanking_n <= '1';											 	
			else																
				blanking_n <= '0';												
			end if;
		end if;
	end process;

end behavior;



