library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity pixel_selector is
   port (
		vga_clk           : in  std_logic;
		pixel_shape       : in  std_logic_vector(7 downto 0);
		pixel_sel         : in  integer range 0 to 7;
		pixel_bit         : out std_logic
	);
end entity;	

architecture rtl of pixel_selector is

begin

	process(pixel_shape, pixel_sel, vga_clk)
	begin
		if falling_edge(vga_clk) then
			case pixel_sel is 
				when 0 => pixel_bit <= pixel_shape(7);
				when 1 => pixel_bit <= pixel_shape(6);
				when 2 => pixel_bit <= pixel_shape(5);
				when 3 => pixel_bit <= pixel_shape(4);
				when 4 => pixel_bit <= pixel_shape(3);
				when 5 => pixel_bit <= pixel_shape(2);
				when 6 => pixel_bit <= pixel_shape(1);
				when 7 => pixel_bit <= pixel_shape(0);
			end case;
		end if;
	end process;

end rtl;




