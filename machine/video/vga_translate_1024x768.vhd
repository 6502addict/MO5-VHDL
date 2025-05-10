library ieee;
	use ieee.std_logic_1164.all;
	use IEEE.std_logic_arith.all;
	use IEEE.std_logic_unsigned.all;
	
entity vga_translate_1024x768 IS
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
end vga_translate_1024x768;

architecture behavior OF vga_translate_1024x768 is
begin
	process(reset_n, blanking_n, clock_vga, row, col)
	begin
		if falling_edge(clock_vga) then
			if blanking_n = '0' then
				pixel_mode <= "00";
			elsif row < 84 then
				pixel_mode <= "01"; -- Top border region
			elsif row >= 684 then
				pixel_mode <= "01"; -- Bottom border region
			elsif col < 32 or col >= 992 then
				pixel_mode <= "01"; -- Side borders (left and right)
			else
				pixel_mode <= "10"; -- Active display area
				-- Calculate address based on 3x scaling
				-- MO5 has 320x200 pixels, each byte contains 8 pixels
				-- 320/8 = 40 bytes per row, 200 rows total
				pixel_address <= conv_std_logic_vector(((row - 84) / 3) * 40 + ((col - 32) / 3) / 8, pixel_address'length);
				pixel_sel <= ((col - 32) / 3) mod 8; -- Select bit within byte
			end if;
		end if;
	end process;
	
end behavior;