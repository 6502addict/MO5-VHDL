library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity edge_detector is
   port (
		clk          : in  std_logic;
		reset_n      : in  std_logic;
		input        : in  std_logic;
		pos_edge     : out std_logic;
		neg_edge     : out std_logic
	);
end edge_detector;

architecture rtl of edge_detector is
signal r0 : std_logic;
signal r1 : std_logic;

begin

	process(clk, reset_n)
	begin 
		if reset_n = '0' then 
			r0 <= '0';
			r1 <= '1';
	   elsif rising_edge(clk) then
			r0 <= input;
			r1 <= r0;
		end if;
	end process;	
	
	pos_edge <= not r1 and r0;
	neg_edge <= not r0 and r1;

end rtl;	