library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all; 

entity vga_mo5_palette is
  port(
	 vga_clk  : in  std_logic;
 	 pixel    : in  std_logic_vector(3 downto 0);
	 red      : out std_logic_vector(3 downto 0);
	 green    : out std_logic_vector(3 downto 0);
	 blue	    : out std_logic_vector(3 downto 0)
  ); 
end vga_mo5_palette;

-- Daniel's data for mo5 colors
-- Couleur 00 : R=000 V=000 B=000 BLACK
-- Couleur 01 : R=255 V=000 B=000 RED
-- Couleur 02 : R=000 V=255 B=000 GREEN
-- Couleur 03 : R=255 V=255 B=000 YELLOW
-- Couleur 04 : R=042 V=042 B=255 BLUE
-- Couleur 05 : R=255 V=000 B=255 MAGENTA
-- Couleur 06 : R=042 V=255 B=255 CYAN
-- Couleur 07 : R=255 V=255 B=255 WHITE
-- Couleur 08 : R=170 V=170 B=170 GREY
-- Couleur 09 : R=255 V=170 B=170 PINK 
-- Couleur 10 : R=170 V=255 B=170 LIGHT GREEN
-- Couleur 11 : R=255 V=255 B=170 LIGHT YELLOW
-- Couleur 12 : R=042 V=170 B=255 LIGHT BLUE
-- Couleur 13 : R=255 V=170 B=255 LIGHT PINK
-- Couleur 14 : R=170 V=255 B=255 LIGHT BLUE
-- Couleur 15 : R=255 V=170 B=042 ORANGE

architecture behavior OF vga_mo5_palette IS
begin
	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			case pixel is
				when "0000" =>       -- BLACK
					red   <= "0000";  -- 0
					green <= "0000";  -- 0
					blue  <= "0000";  -- 0 
				when "0001" =>       -- RED
					red   <= "1111";  -- 255
					green <= "0000";  -- 0
					blue  <= "0000";  -- 0
				when "0010" =>       -- GREEN 
					red   <= "0000";  -- 0
					green <= "1111";  -- 255
					blue  <= "0000";  -- 0
				when "0011" =>       -- YELLOW
					red   <= "1111";  -- 255
					green <= "1111";  -- 255
					blue  <= "0000";  -- 0 
				when "0100" =>       -- BLUE
					red   <= "0010";  -- 42
					green <= "0010";  -- 42
					blue  <= "1111";  -- 255
				when "0101" =>       -- MAGENTA   
					red   <= "1111";  -- 255
					green <= "0000";  -- 0
					blue  <= "1111";  -- 255
				when "0110" =>       -- CYAN
					red   <= "0010";  -- 42
					green <= "1111";  -- 255 
					blue  <= "1111";  -- 255
				when "0111" =>       -- WHITE
					red   <= "1111";  -- 255
					green <= "1111";  -- 255
					blue  <= "1111";  -- 255
				when "1000" =>       -- GREY
					red   <= "1010";  -- 170
					green <= "1010";  -- 170
					blue  <= "1010";  -- 170 
				when "1001" =>       -- PINK
					red   <= "1111";  -- 255
					green <= "1010";  -- 170
					blue  <= "1010";  -- 170
				when "1010" =>       -- LIGHT GREEN
					red   <= "1010";  -- 170
					green <= "1111";  -- 255
					blue  <= "1010";  -- 170
				when "1011" =>       -- LIGHT YELLOW
					red   <= "1111";  -- 255
					green <= "1111";  -- 255
					blue  <= "1010";  -- 170
				when "1100" =>       -- LIGHT BLUE
					red   <= "0010";  -- 42
					green <= "1010";  -- 170
					blue  <= "1111";  -- 255
				when "1101" =>       -- PINK
					red   <= "1111";  -- 255
					green <= "1010";  -- 170 
					blue  <= "1111";  -- 255
				when "1110" =>       -- LIGHT CYAN
					red   <= "1010";  -- 170
					green <= "1111";  -- 255
					blue  <= "1111";  -- 255
				when "1111" =>       -- ORANGE
					red   <= "1111";  -- 255
					green <= "1010";  -- 170
					blue  <= "0010";  -- 42
				when others => NULL;
			end case;
		end if;
	end process;	
end behavior;