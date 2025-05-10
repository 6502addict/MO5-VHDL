library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MO5_SDDRIVE is
    port    (
        reset_n      : in  std_logic := '1';
        cpu_clk      : in  std_logic;
        address      : in  std_logic_vector(15 downto 0);
        data_in      : in  std_logic_vector(7 downto 0);
        data_out     : out std_logic_vector(7 downto 0);
        rw           : in  std_logic;
        vma          : in  std_logic;
		  sd_cs        : out std_logic;
		  sd_sck       : out std_logic;
		  sd_miso      : in  std_logic;
		  sd_mosi      : out std_logic;
		  led_green    : out std_logic;
		  led_red      : out std_logic
    );
end MO5_SDDRIVE;

architecture rtl of MO5_SDDRIVE is
	

component sddrive IS
	port
	(
		address	: in  std_logic_vector(10 downto 0);
		clock		: in  std_logic := '1';
		q		   : out std_logic_vector(7 downto 0)
	);
end component;

	signal data_rom   : std_logic_vector(7 downto 0);
	
begin

	SDC:  sddrive port map (address => address(10 downto 0),
									clock   => cpu_clk,
									q       => data_rom);
									
	data_out <= sd_miso & "0000000" when vma='1' and rw='1' and address = x"A7BF" else data_rom;		
	sd_sck   <= '1'                 when vma='1'            and address = x"A7BF" else '0';
	sd_mosi  <= data_in(0)          when vma='1' and rw='0' and address = x"A7BF" else 'Z';
   sd_cs     <= '0';
   led_green <= '1';
	led_red   <= '1' when vma = '1' and address = x"A7BF" else '0';

end architecture rtl;