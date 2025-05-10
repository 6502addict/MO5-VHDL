library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity MO5_RAM is
  port (
      address       : in    std_logic_vector(15 downto 0);  -- cpu address
		ram_address   : out   std_logic_vector(18 downto 0);  -- ram address
		forme         : in    std_logic;                      -- forme / color signal
		a7cf          : in    std_logic_vector(7 downto 0);   -- a7cf register    
		prcart_n      : out   std_logic;                      -- basic disable
		nscart_n      : in    std_logic;                      -- cartouche chip select
		ram_cs_n      : out   std_logic                       -- ram chip select
	);
end entity;	

architecture rtl of MO5_RAM is
begin
	ram_cs_n    <= '0' when (address(15 downto 12) < x"A") else '1';

	ram_address <= "000" & x"0" & address(11 downto 0) when (address(15 downto 12) = x"0") and forme = '1'    else  -- $0000 forme memory
						"000" & x"1" & address(11 downto 0) when (address(15 downto 12) = x"0") and forme = '0'    else  -- $0000 color memory
					   "000" & x"2" & address(11 downto 0) when (address(15 downto 12) = x"1") and forme = '1'    else  -- $1000 forme memory
						"000" & x"3" & address(11 downto 0) when (address(15 downto 12) = x"1") and forme = '0'    else  -- $0000 color memory
					   "000" & x"4" & address(11 downto 0) when (address(15 downto 12) = x"2")                	 else  -- $2000 main  memory
					   "000" & x"5" & address(11 downto 0) when (address(15 downto 12) = x"3")                    else  -- $3000 main  memory
					   "000" & x"6" & address(11 downto 0) when (address(15 downto 12) = x"4")                    else  -- $4000 main  memory
					   "000" & x"7" & address(11 downto 0) when (address(15 downto 12) = x"5")                    else  -- $5000 main  memory
					   "000" & x"8" & address(11 downto 0) when (address(15 downto 12) = x"6")                    else  -- $6000 main  memory
					   "000" & x"9" & address(11 downto 0) when (address(15 downto 12) = x"7")                    else  -- $7000 main  memory
						"000" & x"A" & address(11 downto 0) when (address(15 downto 12) = x"8")                    else  -- $8000 main  memory
						"000" & x"B" & address(11 downto 0) when (address(15 downto 12) = x"9")                    else  -- $9000 main  memory
						(others => '1');

end rtl;
