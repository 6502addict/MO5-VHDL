library IEEE;
	use IEEE.std_logic_1164.all;
   use ieee.numeric_std.all; 

entity MO5_ROM is
  port (
      address       : in    std_logic_vector(15 downto 0);  -- cpu address
		flash_address : out   std_logic_vector(21 downto 0);  -- flash address
		prcart_n      : in    std_logic;                      -- basic disable
		nscart_n      : out   std_logic;                      -- cartouche chip select
		cartsel       : in    std_logic_vector(3 downto 0);   -- cartouche selection (for testing)
		flash_cs_n    : out   std_logic                       -- flash chip select
	);
end entity;	

architecture rtl of MO5_ROM is
begin
	nscart_n      <= '0'                                  when address(15 downto 12) = x"B"  else
					     '0'                                  when address(15 downto 12) = x"C"  else
					     '0'                                  when address(15 downto 12) = x"D"  else
					     '0'                                  when address(15 downto 12) = x"E"  else
						  '1';

	flash_cs_n    <= '0'                                  when address(15 downto 12) = x"B"  else
					     '0'                                  when address(15 downto 12) = x"C"  else
					     '0'                                  when address(15 downto 12) = x"D"  else
					     '0'                                  when address(15 downto 12) = x"E"  else
						  '1';
	
	flash_address <=  "0000" & cartsel & "00" & address(11 downto 0) when address(15 downto 12) = x"B"  else  -- opt   rom $B000 or cartridge if cartsel # 0
							"0000" & cartsel & "01" & address(11 downto 0) when address(15 downto 12) = x"C"  else  -- basic rom $C000 or cartridge if cartsel # 0
							"0000" & cartsel & "10" & address(11 downto 0) when address(15 downto 12) = x"D"  else  -- basic rom $D000 or cartridge if cartsel # 0
							"0000" & cartsel & "11" & address(11 downto 0) when address(15 downto 12) = x"E"  else  -- basic rom $E000 or cartridge if cartsel # 0
							(others => '1');
	
	
-- prtact_n not yet implemented
-- cartsel not yet implemented  (need video + 6809 core + basic/kernel rom	
	
end rtl;



