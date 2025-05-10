library IEEE;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all; 
	
entity mo5_decode is
    Port ( 
      clk            : in  std_logic;  
		reset_n        : in  std_logic;
		mode           : in  std_logic_vector(1 downto 0)  := "00";       
		escan_code     : in  std_logic_vector(9 downto 0);
		escan_strobe_n : in  std_logic;
		kbd_address    : in  std_logic_vector(5 downto 0);
		kbd_data       : out std_logic;
		reset_out      : out std_logic := '0'
    );

end entity;

architecture Behavioral of mo5_decode is

function build_index(
    shift_on   : in std_logic;
    escan_code : in std_logic_vector(8 downto 0)
) return integer is
    variable result : integer;
    variable scan_code : integer;
    variable is_extended : std_logic;
begin
    scan_code := to_integer(unsigned(escan_code(7 downto 0)));
    is_extended := escan_code(8);
    result := scan_code;
    if is_extended = '1' then  result := result + 16#90#; end if;
    if shift_on    = '1' then  result := result + 2**8;   end if; 
    return result;
end function build_index;

component mo5_qwerty_kbd is
    Port ( 
      index       : in integer range 0 to 511;
		output      : out std_logic_vector(7 downto 0)
    );
end component;

component mo5_azerty_kbd is
    Port ( 
      index       : in integer range 0 to 511;
		output      : out std_logic_vector(7 downto 0)
    );
end component;

component mo5_null_kbd is
    Port ( 
      index       : in integer range 0 to 511;
		output      : out std_logic_vector(7 downto 0)
    );
end component;

constant MO5_SHIFT        : std_logic_vector(5 downto 0) := "111000";
constant MO5_ACC          : std_logic_vector(5 downto 0) := "110110";
constant MO5_A            : std_logic_vector(5 downto 0) := "101101";

constant NULL_KEY         : std_logic_vector(7 downto 0) := "11111111";

constant PS2_LEFT_SHIFT   : std_logic_vector(8 downto 0) := '0' & x"12";
constant PS2_RIGHT_SHIFT  : std_logic_vector(8 downto 0) := '0' & x"59";
constant PS2_LEFT_ALT     : std_logic_vector(8 downto 0) := '0' & x"11";
constant PS2_RIGHT_ALT    : std_logic_vector(8 downto 0) := '1' & x"11";
constant PS2_LEFT_CTRL    : std_logic_vector(8 downto 0) := '0' & x"14";
constant PS2_RIGHT_CTRL   : std_logic_vector(8 downto 0) := '1' & x"14";
constant PS2_DELETE       : std_logic_vector(8 downto 0) := '1' & x"71";
constant PS2_ESCAPE       : std_logic_vector(8 downto 0) := '1' & x"76";

constant PS2_0            : std_logic_vector(8 downto 0) := '0' & x"45";
constant PS2_1            : std_logic_vector(8 downto 0) := '0' & x"16";
constant PS2_2            : std_logic_vector(8 downto 0) := '0' & x"1E";
constant PS2_3            : std_logic_vector(8 downto 0) := '0' & x"26";
constant PS2_4            : std_logic_vector(8 downto 0) := '0' & x"25";
constant PS2_5            : std_logic_vector(8 downto 0) := '0' & x"2E";
constant PS2_6            : std_logic_vector(8 downto 0) := '0' & x"36";
constant PS2_7            : std_logic_vector(8 downto 0) := '0' & x"3D";
constant PS2_8            : std_logic_vector(8 downto 0) := '0' & x"3E";
constant PS2_9            : std_logic_vector(8 downto 0) := '0' & x"46";
constant PS2_EQUALS       : std_logic_vector(8 downto 0) := '0' & x"55"; -- =
constant PS2_BRACKET_R    : std_logic_vector(8 downto 0) := '0' & x"5B"; -- ]
constant PS2_APOSTROPHE   : std_logic_vector(8 downto 0) := '0' & x"52";


-- Custom remapped codes for French AltGr combinations
constant PS2_ALT_2        : std_logic_vector(8 downto 0) := '0' & x"80"; -- AltGr + 2
constant PS2_ALT_3        : std_logic_vector(8 downto 0) := '0' & x"81"; -- AltGr + 3
constant PS2_ALT_4        : std_logic_vector(8 downto 0) := '0' & x"82"; -- AltGr + 4
constant PS2_ALT_5        : std_logic_vector(8 downto 0) := '0' & x"83"; -- AltGr + 5
constant PS2_ALT_6        : std_logic_vector(8 downto 0) := '0' & x"84"; -- AltGr + 6
constant PS2_ALT_7        : std_logic_vector(8 downto 0) := '0' & x"85"; -- AltGr + 7
constant PS2_ALT_8        : std_logic_vector(8 downto 0) := '0' & x"86"; -- AltGr + 8
constant PS2_ALT_9        : std_logic_vector(8 downto 0) := '0' & x"87"; -- AltGr + 9
constant PS2_ALT_0        : std_logic_vector(8 downto 0) := '0' & x"88"; -- AltGr + 0
constant PS2_ALT_PAREN    : std_logic_vector(8 downto 0) := '0' & x"89"; -- AltGr + )
constant PS2_ALT_EQUAL    : std_logic_vector(8 downto 0) := '0' & x"8A"; -- AltGr + =		

constant PS2_F6           : std_logic_vector(8 downto 0) := '0' & x"0B";
constant PS2_F7           : std_logic_vector(8 downto 0) := '0' & x"83";
constant PS2_F8           : std_logic_vector(8 downto 0) := '0' & x"0A";
constant PS2_F9           : std_logic_vector(8 downto 0) := '0' & x"01";
constant PS2_F10          : std_logic_vector(8 downto 0) := '0' & x"09";



-- Define a record to store key state with shift information
type key_state_t is record
    active : std_logic;
    shift  : std_logic;
	 accent : std_logic;
end record;

-- Define arrays to track key states
type   key_state_array_t is array(0 to 255) of key_state_t;
signal all_keys : key_state_array_t := (others => ('0', '0', '0'));

type kbd_state_t is (KBD_IDLE, KBD_FETCH, KBD_PROCESS, 
							KBD_SHIFT_PREPARE, KBD_SHIFT_DELAY, KBD_KEY_SET, KBD_KEY_HOLD, KBD_RESTORE_SHIFT, 
							KBD_ACC_SET, KBD_ACC_SET_DELAY, KBD_ACC_RELEASE, KBD_ACC_KEY_SET, KBD_ACC_KEY_HOLD,
							KBD_END);
							
signal kbd_state         : kbd_state_t := KBD_IDLE;                              -- FSM state
signal prev_strobe       : std_logic;                                            -- previous strobe state;
signal acc_on            : std_logic := '0';                                     -- current accent state
signal acc_mode          : std_logic := '0';                                     -- wanted accent state
signal shift_on          : std_logic := '0';                                     -- curent shift state
signal shift_mode        : std_logic := '0';                                     -- wanted shift state 
signal kbd_index         : integer range 0 to 511;                               -- index in kbd table
signal kbd_output        : std_logic_vector(7 downto 0);                         -- mapping data acc, shift, row, col
signal kbd_azerty        : std_logic_vector(7 downto 0);                         -- mapping data acc, shift, row, col  AZERTY  mapping
signal kbd_qwerty        : std_logic_vector(7 downto 0);                         -- mapping data acc, shift, row, col  QWERTY  mapping
signal kbd_null          : std_logic_vector(7 downto 0);                         -- mapping data acc, shift, row, col   1 to 1 mapping
signal matrix            : std_logic_vector(63 downto 0) := (others => '1');     -- mo5 kbd matrice (active low)
signal key_action        : std_logic := '0';                                     -- '0' for press, '1' for release
signal prev_shift_state  : std_logic := '1';                                     -- Previous state of shift matrix position
signal delay_counter     : integer range 0 to 32767 := 0;                        -- Counter for timing delays
signal current_key_addr  : std_logic_vector(5 downto 0);                         -- Current key being processed
signal ctrl_pressed      : std_logic := '0';
signal alt_pressed       : std_logic := '0';
signal del_pressed       : std_logic := '0';
signal acc_pending       : std_logic := '0';
signal last_mode         : std_logic_vector(1 downto 0) := "00";
signal mode_changed      : std_logic := '0';


begin

	kmq: mo5_qwerty_kbd  port map(index   => kbd_index,
	                              output  => kbd_qwerty);

	kma: mo5_azerty_kbd  port map(index   => kbd_index,
   	                           output  => kbd_azerty);
									  
	kmn: mo5_null_kbd    port map(index   => kbd_index,
   	                           output  => kbd_null);
											
   kbd_output <=  kbd_qwerty when mode = "00"  else
	               kbd_azerty when mode = "01"  else
						kbd_null;
						

	kbd_data <= matrix(to_integer(unsigned(kbd_address)));		


	mode_changed <= '0' when last_mode = mode else '1';
	
	
	process(reset_n, clk, mode_changed)
        variable key_shift     : std_logic;
        variable is_shift_key  : boolean;
        variable matrix_idx    : integer;
		  variable remapped_code : std_logic_vector(8 downto 0);
	begin
		if reset_n = '0' or mode_changed = '1' then
			prev_strobe      <= '1'; 
			kbd_state        <= KBD_IDLE;
			shift_on         <= '0';
			acc_on           <= '0';
			matrix           <= (others => '1');
			all_keys         <= (others => ('0', '0', '0'));
         delay_counter    <= 0;
         prev_shift_state <= '1';
		   ctrl_pressed     <= '0';
		   alt_pressed      <= '0';
		   del_pressed      <= '0';
			reset_out        <= '0';
		elsif falling_edge(clk) then
			last_mode        <= mode;
			prev_strobe <= escan_strobe_n;
			if prev_strobe = '1' and escan_strobe_n = '0' then
				if (escan_code(8 downto 0) = PS2_LEFT_CTRL) or (escan_code(8 downto 0) = PS2_RIGHT_CTRL) then
					ctrl_pressed <= not escan_code(9);
				elsif (escan_code(8 downto 0) = PS2_LEFT_ALT) or (escan_code(8 downto 0) = PS2_RIGHT_ALT) then
					alt_pressed <= not escan_code(9);
				elsif (escan_code(8 downto 0) = PS2_DELETE) then
					del_pressed <=  not escan_code(9);
				end if;			
			end if;
			if ctrl_pressed = '1' and alt_pressed = '1' and del_pressed = '1' then
				reset_out <= '1';
			else
				reset_out <= '0';
			end if;			
			
			if prev_strobe = '1' and escan_strobe_n = '0' then
				remapped_code := escan_code(8 downto 0);
				if escan_code(8 downto 0) = PS2_ESCAPE then
					acc_pending <= not escan_code(9);
					kbd_state <= KBD_END;
				end if;

				if alt_pressed = '1' and mode = "01" then
					case escan_code(8 downto 0) is
						when PS2_3  => remapped_code := PS2_ALT_3;
						when PS2_7  => remapped_code := PS2_ALT_7;
						when PS2_9  => remapped_code := PS2_ALT_9;
						when PS2_0  => remapped_code := PS2_ALT_0;
						when others =>	null;
					end case;
				end if;
--				if acc_pending ='1' then
--					case escan_code(8 downto 0) is
--						when PS2_6  => remapped_code := PS2_2;
--						when PS2_7  => remapped_code := PS2_2;
--						when PS2_8  => remapped_code := PS2_APOSTROPHE;
--						when PS2_9  => remapped_code := PS2_9;
--						when PS2_0  => remapped_code := PS2_0;
--						when others =>	null;
--					end case;
--				end if;
			end if;

			case kbd_state is 
				when KBD_IDLE => 
					 if prev_strobe = '1' and escan_strobe_n = '0' then
						  key_action <= escan_code(9); -- Save make/break flag
						  is_shift_key := (escan_code(8 downto 0) = PS2_LEFT_SHIFT) or 
												(escan_code(8 downto 0) = PS2_RIGHT_SHIFT);
						  if is_shift_key then
								case escan_code(9) is
									 when '0' => shift_on <= '1'; -- Key pressed
									 when '1' => shift_on <= '0'; -- Key released
									 when others => null;
								end case;
						  end if;
						  if escan_code(9) = '0' then  -- Make code
								all_keys(build_index('0', remapped_code(8 downto 0))).active <= '1';
								all_keys(build_index('0', remapped_code(8 downto 0))).shift <= shift_on;
								all_keys(build_index('0', remapped_code(8 downto 0))).accent <= acc_on;  -- Store accent state
								if acc_pending = '1' then
									kbd_index <= build_index('0', remapped_code(8 downto 0));
								else
									kbd_index <= build_index(shift_on, remapped_code(8 downto 0));
								end if;
						  else  -- Break code
								key_shift := all_keys(build_index('0', remapped_code(8 downto 0))).shift;
								all_keys(build_index('0', remapped_code(8 downto 0))).active <= '0';
								if acc_pending = '1' then
									kbd_index <= build_index('0', remapped_code(8 downto 0));	
								else 
									kbd_index <= build_index(key_shift, remapped_code(8 downto 0));	
								end if;
						  end if;
									 
						  kbd_state <= KBD_FETCH;
					 end if;
					
				when KBD_FETCH =>			
					current_key_addr <= kbd_output(5 downto 0);
					shift_mode       <= kbd_output(6);
					acc_mode         <= kbd_output(7);
					kbd_state        <= KBD_PROCESS;
				
				when KBD_PROCESS =>
					if kbd_output = NULL_KEY then
						 kbd_state <= KBD_END;
					else
						 if current_key_addr = MO5_SHIFT then
							  matrix(to_integer(unsigned(current_key_addr))) <= key_action;
							  kbd_state <= KBD_END;
						 elsif acc_mode = '1' and key_action = '0' then
							  kbd_state <= KBD_ACC_SET;
						 elsif acc_mode = '1' and key_action = '1' then
							  matrix(to_integer(unsigned(current_key_addr))) <= key_action;
							  acc_on <= '0';
							  kbd_state <= KBD_END;
						 elsif matrix(to_integer(unsigned(MO5_SHIFT))) = not shift_mode then
							  matrix(to_integer(unsigned(current_key_addr))) <= key_action;
							  kbd_state <= KBD_END;
						 else
							  kbd_state <= KBD_SHIFT_PREPARE;
						 end if;
					end if;

            when KBD_SHIFT_PREPARE =>
               prev_shift_state <= matrix(to_integer(unsigned(MO5_SHIFT)));
               matrix(to_integer(unsigned(MO5_SHIFT))) <= not shift_mode;
               delay_counter <= 20000;
               kbd_state <= KBD_SHIFT_DELAY;
                
            when KBD_SHIFT_DELAY =>
               if delay_counter > 0 then
						delay_counter <= delay_counter - 1;
               else
                  kbd_state <= KBD_KEY_SET;
               end if;
                
            when KBD_KEY_SET =>
               matrix(to_integer(unsigned(current_key_addr))) <= key_action;
					delay_counter <= 20000;
               kbd_state <= KBD_KEY_HOLD;
                
            when KBD_KEY_HOLD =>
               if delay_counter > 0 then
						delay_counter <= delay_counter - 1;
               else
                  matrix(to_integer(unsigned(MO5_SHIFT))) <= prev_shift_state;
                  kbd_state <= KBD_END;
               end if;

				when KBD_ACC_SET =>    
					matrix(to_integer(unsigned(MO5_ACC))) <= '0';  -- Active low, so set to 0
					delay_counter <= 20000;
					kbd_state <= KBD_ACC_SET_DELAY;
								
				when KBD_ACC_SET_DELAY =>
					if delay_counter > 0 then
						delay_counter <= delay_counter - 1;
					else
						delay_counter <= 20000;  -- Reset the counter for the next delay
						kbd_state <= KBD_ACC_RELEASE;
					end if;

				when KBD_ACC_RELEASE =>
					matrix(to_integer(unsigned(MO5_ACC))) <= '1';  -- Release the accent key
					if delay_counter > 0 then
						delay_counter <= delay_counter - 1;
					else
						delay_counter <= 20000;  -- Reset the counter for the next delay
						kbd_state <= KBD_ACC_KEY_SET;
					end if;
								
				when KBD_ACC_KEY_SET =>
					matrix(to_integer(unsigned(current_key_addr))) <= key_action;
					delay_counter <= 20000;
					kbd_state <= KBD_ACC_KEY_HOLD;
								
				when KBD_ACC_KEY_HOLD =>
					if delay_counter > 0 then
						delay_counter <= delay_counter - 1;
					else
						kbd_state <= KBD_END;
					end if;
                    
				when KBD_END =>
					-- wait for rising edge of escan_strobe
					-- then move to KBD_IDLE;
					if prev_strobe = '0' and escan_strobe_n = '1' then
						kbd_state <= KBD_IDLE;
					end if;
                    
            when others =>
					kbd_state <= KBD_IDLE;
			end case;
		end if;
	end process;
													
end Behavioral;




 