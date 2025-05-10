library IEEE;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all; 
	
entity MO5_CLOCK is
	Port ( 
		clk50       : in  std_logic;
		clk24       : in  std_logic;
		reset_n     : in  std_logic;
		clock_sel   : in  std_logic; 
		vga_clock   : out std_logic;
		cpu_clock   : out std_logic;
		synlt_clock : out std_logic;
		sound_clock : out std_logic;
		ready       : out std_logic := '0'
    );
end MO5_CLOCK;

architecture Behavioral of MO5_CLOCK is
	component vga is
		port (
			areset      : in  std_logic;
			inclk0		: in  std_logic  := '0';
			c0				: out std_logic;
			locked      : out std_logic
		);
	end component;

	component clock_divider IS
		generic (divider : integer := 4);
		port	(
			reset          : in  std_logic := '1';
			clk_in         : in  std_logic;
			clk_out        : out std_logic
		);
	end component;

	component prog_clock_divider is
		 generic (bits : integer := 8);
		 port (
			  reset_n  : in  std_logic := '1';  				
			  clk_in   : in  std_logic;
			  divider  : in  std_logic_vector(bits -1 downto 0);  
			  clk_out  : out std_logic
		 );
	end component;
	
	component clock_48khz_generator is
    Port (
        clk_24mhz   : in  STD_LOGIC;  -- Input 24MHz clock
        reset_n     : in  STD_LOGIC;  -- Active low reset
        clk_48khz   : out STD_LOGIC   -- Output 48kHz clock
    );
	end component;
	
	component clock_switcher is
    Port ( 
        clk_1mhz     : in  STD_LOGIC;
        clk_10mhz    : in  STD_LOGIC;
        clock_select : in  STD_LOGIC;  -- '0' for 1MHz, '1' for 10MHz
        reset_n      : in  STD_LOGIC;
        cpu_clock    : out STD_LOGIC
    );
	end component;
	
	signal clock_ready : integer range 0 to 7;
	signal locked      : std_logic;
	signal slow_clock  : std_logic;
	signal clk100mhz   : std_logic;
	signal clk10mhz    : std_logic;
	signal clk1mhz     : std_logic;
	
begin	

-- produce the 100Mhz clock needed for the sdram with ALTPLL
	vdo_clk:  vga                    port map(areset => not reset_n,
	                                          inclk0 => clk50,
	                                          c0     => vga_clock,
															locked => locked);
													 
-- produce the cpu clock frequency for 1Mhz (the 69 core is not using a 4x clock)	
	mhz1_clk:  clock_divider      generic map(divider   => 50000000/1000000)
								            port map(reset     => reset_n,
											 	         clk_in    => clk50,
												         clk_out   => clk1mhz);
															
	mhz10_clk: clock_divider      generic map(divider   => 50000000/10000000)
								            port map(reset     => reset_n,
											 	         clk_in    => clk50,
												         clk_out   => clk10mhz);

-- produce 50hz signal (SYNCLT on the MO5)  (derived from the vga clocked)
	synlt_clk:   clock_divider    generic map(divider   => 50000000/50)
								            port map(reset     => reset_n,
											   	      clk_in    => clk50,
												         clk_out   => slow_clock);
															
-- produce 48Khz signal for sound sampling
	snd_clk:  clock_48khz_generator  port map(clk_24mhz  => clk24,
															reset_n    => reset_n,
															clk_48khz  => sound_clock);
															
	clk_swt: clock_switcher          port map(clk_1mhz     => clk1mhz,
															clk_10mhz    => clk10mhz,
															clock_select => clock_sel,
															reset_n      => reset_n,
															cpu_clock    => cpu_clock);
													 
   synlt_clock <= slow_clock;												

	process(slow_clock, reset_n, locked)
	begin
		if reset_n = '0' then
			clock_ready <= 0;
			ready <= '0';
		elsif rising_edge(slow_clock) and locked = '1' then
			if clock_ready < 7 then
				clock_ready <= clock_ready + 1;
			else
				ready <= '1';
			end if;
		end if;	
	end process;
													 
end Behavioral;