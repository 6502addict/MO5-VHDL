library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity ps2 is
   port (
		clk          : in  std_logic;
		reset_n      : in  std_logic;
		ps2_clk      : in  std_logic;
		ps2_dat      : in  std_logic;
	   ps2_code     : out std_logic_vector(7 downto 0);
		ps2_strobe_n : out std_logic
	);
end ps2;

architecture rtl of ps2 is

component edge_detector is
   port (
		clk          : in  std_logic;
		reset_n      : in  std_logic;
		input        : in  std_logic;
		pos_edge     : out std_logic := '1';
		neg_edge     : out std_logic := '1'
 	);
end component;

component parity_generator is
    Port ( 
        input     : in  std_logic_vector(8 downto 0);
        even      : out std_logic;                
        odd       : out std_logic               
    );
end component;

signal	count      : integer range 0 to 15;
signal	parity     : std_logic;
signal	byte       : std_logic_vector(8 downto 0); 
signal   ps2_clk_n  : std_logic;

begin
	edge:  edge_detector 	port map(clk       => clk, 
					 reset_n   => reset_n,
					 input     => ps2_clk, 
					 pos_edge  => open,
					 neg_edge  => ps2_clk_n);
											
	par : parity_generator port map (input        => byte,
					 even         => open,
					 odd          => parity);	
												
	process(ps2_clk_n, reset_n)
	begin
		if reset_n = '0' then
			byte <= "000000000";
			count  <= 0;
			ps2_strobe_n <= '1';
		elsif rising_edge(ps2_clk_n) then     
			if count >= 10 then
				count <= 0;
			else
				count <= count + 1;
			end if;		
			case count is
				when  0 =>
					ps2_strobe_n <= '1';
				when  1 => byte(0) <= ps2_dat;  -- bit 0
				when  2 => byte(1) <= ps2_dat;  -- bit 1
				when  3 => byte(2) <= ps2_dat;  -- bit 2
				when  4 => byte(3) <= ps2_dat;  -- bit 3
				when  5 => byte(4) <= ps2_dat;  -- bit 4
				when  6 => byte(5) <= ps2_dat;  -- bit 5
				when  7 => byte(6) <= ps2_dat;  -- bit 6
				when  8 => byte(7) <= ps2_dat;  -- bit 7
				when  9 => byte(8) <= ps2_dat;  -- parity bit
				when 10 =>
					if ps2_dat = '1' and parity = '1' then
						ps2_code   <= byte(7 downto 0);
						ps2_strobe_n <= '0';
					end if;
 				when others => NULL;
			end case;
		end if;
	end process; 

end rtl;

