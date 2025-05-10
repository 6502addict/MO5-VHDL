library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity color_selector is
   port (
		color_sel : in  std_logic_vector(2 downto 0);
		blk_col   : in  std_logic_vector(3 downto 0);
		brd_col   : in  std_logic_vector(3 downto 0);
		fgnd_col  : in  std_logic_vector(3 downto 0);
		bgnd_col  : in  std_logic_vector(3 downto 0);
		pixel     : out std_logic_vector(3 downto 0)
	);
end entity;	

architecture rtl of color_selector is

begin
	pixel <= blk_col   when color_sel(1 downto 0) = "00" else
				brd_col   when color_sel(1 downto 0) = "01" else
				fgnd_col  when color_sel(2)          = '1'  else
				bgnd_col;
end rtl;




