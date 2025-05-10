library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_assembler is
    port (
        clk            : in  std_logic;                     
        reset_n        : in  std_logic;                     
        ps2_code       : in  std_logic_vector(7 downto 0);  
        ps2_strobe_n   : in  std_logic;                     
        escan_code     : out std_logic_vector(9 downto 0);  
        escan_strobe_n : out std_logic
    );
end ps2_assembler;

architecture behavioral of ps2_assembler is

constant BREAK         : std_logic_vector(7 downto 0) := x"F0";
constant EXTENDED      : std_logic_vector(7 downto 0) := x"E0";

type kbd_state_t is (KBD_IDLE, KBD_FETCH, KBD_END);

signal kbd_state   : kbd_state_t := KBD_IDLE;
signal break_flag      : std_logic;
signal extended_flag   : std_logic;	
signal ps2_strobe_last : std_logic;

begin
   process(clk, reset_n)
	begin
		if reset_n = '0' then
			escan_code      <= (others => '0');
			ps2_strobe_last <= '1';
			break_flag      <= '0';
			extended_flag   <= '0';
			escan_strobe_n  <= '1';
			kbd_state       <= KBD_IDLE;
		elsif falling_edge(clk) then
			ps2_strobe_last <= ps2_strobe_n;
			case kbd_state is  
				-- initialize the state machine, reset all parameters to default values
				when KBD_IDLE => 
					break_flag      <= '0';
					extended_flag   <= '0';
					escan_strobe_n  <= '1';
					escan_code      <= (others => '0');
					-- wait for a falling edge ont ps2_strobe
	            -- then change do KBD_FETCH state
					if ps2_strobe_last = '1' and ps2_strobe_n = '0' then
					  kbd_state <= KBD_FETCH;
					end if;

				-- fetch a byte from the lower layer (ps2)
				when KBD_FETCH =>
					case ps2_code is 
						when EXTENDED =>
							extended_flag <= '1';
							
						when BREAK    =>
							break_flag    <= '1';
							
						when others => 
							escan_code <= break_flag & extended_flag & ps2_code;
							escan_strobe_n <= '0';
							kbd_state <= KBD_END;
					end case;	
					
				when KBD_END =>
					-- wait for rising edge of ps2_strobe 
					-- and reset state to KBD_IDLE
					if ps2_strobe_last = '0' and ps2_strobe_n = '1' then
					  kbd_state <= KBD_IDLE;
					end if;
			end case;
		end if;	
	end process;
   
end behavioral;