library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flash is
    Port (
        reset_n     : in  STD_LOGIC;                          -- Active low reset
        address     : in  STD_LOGIC_VECTOR(21 downto 0);      -- Address bus
        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);       -- Data input (for write operations)
        data_out    : out STD_LOGIC_VECTOR(7 downto 0);       -- Data output (for read operations)
        rw          : in  STD_LOGIC;                          -- Read/Write signal (1 = read, 0 = write)
        cs_n        : in  STD_LOGIC;                          -- Chip select (active low)
		  FL_DQ       : inout std_logic_vector(7 downto 0);	  -- FLASH Data bus 8 Bits
	  	  FL_ADDR	  : out   std_logic_vector(21 downto 0);    -- FLASH Address bus 22 Bits
		  FL_WE_N	  : out   std_logic;  							  -- FLASH Write Enable
		  FL_RST_N    : out   std_logic;      				        -- FLASH Reset
		  FL_OE_N     : out   std_logic;						        -- FLASH Output Enable
		  FL_CE_N     : out   std_logic				    	 	     -- FLASH Chip Enable
    );
end flash;

architecture Behavioral of flash is
    
begin
   FL_RST_N  <= reset_n;
	FL_ADDR   <= address;
   FL_CE_N   <= '0' when cs_n = '0'              else '1';
   FL_OE_N   <= '0' when cs_n = '0' and rw = '1' else '1';   
   FL_WE_N   <= '0' when cs_n = '0' and rw = '1' else '1';   -- write disabled
	data_out  <= FL_DQ;
end Behavioral;

