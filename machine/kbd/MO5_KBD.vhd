library IEEE;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all; 
	
entity MO5_KBD is
    Port ( 
		  clk            : in  std_logic;
		  reset_n        : in  std_logic;
		  mode           : in  std_logic_vector(1 downto 0);
		  ps2_clk        : in  std_logic;
		  ps2_dat        : in  std_logic;
		  kbd_address    : in  std_logic_vector(5 downto 0);
		  kbd_data_out   : out std_logic;
   	  reset_out      : out std_logic := '0'
    );
end MO5_KBD;

architecture Behavioral of MO5_KBD is

component ps2 is
   port (
		clk          : in  std_logic;
		reset_n      : in  std_logic;
		ps2_clk      : in  std_logic;
		ps2_dat      : in  std_logic;
	   ps2_code     : out std_logic_vector(7 downto 0);
		ps2_strobe_n : out std_logic
	);
end component;

component ps2_assembler is
    port (
        clk            : in  std_logic;                     -- System clock
        reset_n        : in  std_logic;                     -- Active low reset
        ps2_code       : in  std_logic_vector(7 downto 0);  -- Raw scancode input
        ps2_strobe_n   : in  std_logic;                     -- Active low pulse indicating new scancode
        escan_code     : out std_logic_vector(9 downto 0);  -- Processed scancode with flags
        escan_strobe_n : out std_logic                      -- Active low pulse for new escan value
    );
end component;

component mo5_decode is
    Port ( 
      clk            : in  std_logic;  
		reset_n        : in  std_logic;
		mode           : in  std_logic_vector(1 downto 0);
		escan_code     : in  std_logic_vector(9 downto 0);
		escan_strobe_n : in  std_logic;
		kbd_address    : in  std_logic_vector(5 downto 0);
		kbd_data       : out std_logic;
  	   reset_out      : out std_logic := '0'
    );
end component;

signal  ps2_code        : std_logic_vector(7 downto 0);
signal  ps2_strobe_n    : std_logic;
signal  map_code        : std_logic_vector(9 downto 0);
signal  map_strobe_n    : std_logic;
signal  escan_code      : std_logic_vector(9 downto 0);
signal  escan_strobe_n  : std_logic;

begin  

	kbd: ps2         			   port map(clk                => clk,   
													reset_n            => reset_n,
													ps2_clk            => ps2_clk,
													ps2_dat            => ps2_dat,
													ps2_code           => ps2_code,
													ps2_strobe_n       => ps2_strobe_n);

	kas:  ps2_assembler        port map(clk                => clk,
												   reset_n            => reset_n,
													ps2_code           => ps2_code,
													ps2_strobe_n       => ps2_strobe_n,
													escan_code         => escan_code,
													escan_strobe_n     => escan_strobe_n);
													
   dec: mo5_decode          	port map(clk              => clk,
													reset_n          => reset_n,
													mode             => mode,
													escan_code       => escan_code,
													escan_strobe_n   => escan_strobe_n,
													kbd_address      => kbd_address,
													kbd_data         => kbd_data_out,
													reset_out        => reset_out);
end Behavioral;

