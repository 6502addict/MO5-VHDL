library IEEE;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all; 
	
entity mo5_qwerty_kbd is
    Port ( 
      index       : in integer range 0 to 511;
		output      : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of mo5_qwerty_kbd is

function mo5_matrix(row, col : integer) return std_logic_vector is
begin
    return std_logic_vector(to_unsigned(7-row, 3)) & std_logic_vector(to_unsigned(col, 3));
end function mo5_matrix;

function ps2_index(code: integer; ext, shift: std_logic) return integer is
    variable result : integer := code;
begin
    if ext   = '1' then result := result + 16#90#; end if;
    if shift = '1' then result := result + 2**8;   end if;
    return result;
end function;

function mo5_output(acc, shift: std_logic; matrix: std_logic_vector(5 downto 0)) 
	return std_logic_vector is
begin
   return '0' & shift & matrix;
end function;


-- MO5 KEYBOARD MATRIX
constant MO5_SHIFT    : std_logic_vector(5 downto 0) := mo5_matrix(0, 0);
constant MO5_BASIC    : std_logic_vector(5 downto 0) := mo5_matrix(0, 1);
constant MO5_RAZ      : std_logic_vector(5 downto 0) := mo5_matrix(1, 3);
constant MO5_ENT      : std_logic_vector(5 downto 0) := mo5_matrix(1, 4);
constant MO5_CNT      : std_logic_vector(5 downto 0) := mo5_matrix(1, 5);
constant MO5_MERGE    : std_logic_vector(5 downto 0) := mo5_matrix(5, 1);
constant MO5_ACC      : std_logic_vector(5 downto 0) := mo5_matrix(1, 6);
constant MO5_INS      : std_logic_vector(5 downto 0) := mo5_matrix(6, 1);
constant MO5_EFF      : std_logic_vector(5 downto 0) := mo5_matrix(7, 1);
constant MO5_STOP     : std_logic_vector(5 downto 0) := mo5_matrix(1, 7);
constant MO5_CSRL     : std_logic_vector(5 downto 0) := mo5_matrix(2, 1);
constant MO5_CSRR     : std_logic_vector(5 downto 0) := mo5_matrix(4, 1);
constant MO5_CSRU     : std_logic_vector(5 downto 0) := mo5_matrix(1, 1);
constant MO5_CSRD     : std_logic_vector(5 downto 0) := mo5_matrix(3, 1);

constant MO5_A        : std_logic_vector(5 downto 0) := mo5_matrix(2, 5);
constant MO5_B        : std_logic_vector(5 downto 0) := mo5_matrix(3, 2);
constant MO5_C        : std_logic_vector(5 downto 0) := mo5_matrix(1, 2);
constant MO5_D        : std_logic_vector(5 downto 0) := mo5_matrix(4, 3);
constant MO5_E        : std_logic_vector(5 downto 0) := mo5_matrix(4, 5);
constant MO5_F        : std_logic_vector(5 downto 0) := mo5_matrix(5, 3);
constant MO5_G        : std_logic_vector(5 downto 0) := mo5_matrix(6, 3);
constant MO5_H        : std_logic_vector(5 downto 0) := mo5_matrix(7, 3);
constant MO5_I        : std_logic_vector(5 downto 0) := mo5_matrix(6, 4);
constant MO5_J        : std_logic_vector(5 downto 0) := mo5_matrix(7, 2);
constant MO5_K        : std_logic_vector(5 downto 0) := mo5_matrix(6, 2);
constant MO5_L        : std_logic_vector(5 downto 0) := mo5_matrix(5, 2);
constant MO5_M        : std_logic_vector(5 downto 0) := mo5_matrix(4, 2); 
constant MO5_N        : std_logic_vector(5 downto 0) := mo5_matrix(7, 0);
constant MO5_O        : std_logic_vector(5 downto 0) := mo5_matrix(5, 4);
constant MO5_P        : std_logic_vector(5 downto 0) := mo5_matrix(4, 4);
constant MO5_Q        : std_logic_vector(5 downto 0) := mo5_matrix(2, 3);
constant MO5_R        : std_logic_vector(5 downto 0) := mo5_matrix(5, 5);
constant MO5_S        : std_logic_vector(5 downto 0) := mo5_matrix(3, 3);
constant MO5_T        : std_logic_vector(5 downto 0) := mo5_matrix(6, 5);
constant MO5_U        : std_logic_vector(5 downto 0) := mo5_matrix(7, 4);
constant MO5_V        : std_logic_vector(5 downto 0) := mo5_matrix(2, 2);
constant MO5_W        : std_logic_vector(5 downto 0) := mo5_matrix(1, 0);
constant MO5_X        : std_logic_vector(5 downto 0) := mo5_matrix(2, 0);
constant MO5_Y        : std_logic_vector(5 downto 0) := mo5_matrix(7, 5);
constant MO5_Z        : std_logic_vector(5 downto 0) := mo5_matrix(3, 5);

constant MO5_0        : std_logic_vector(5 downto 0) := mo5_matrix(4, 6);
constant MO5_1        : std_logic_vector(5 downto 0) := mo5_matrix(2, 7);
constant MO5_2        : std_logic_vector(5 downto 0) := mo5_matrix(3, 7);
constant MO5_4        : std_logic_vector(5 downto 0) := mo5_matrix(5, 7);
constant MO5_3        : std_logic_vector(5 downto 0) := mo5_matrix(4, 7);
constant MO5_5        : std_logic_vector(5 downto 0) := mo5_matrix(6, 7);
constant MO5_6        : std_logic_vector(5 downto 0) := mo5_matrix(7, 7);
constant MO5_7        : std_logic_vector(5 downto 0) := mo5_matrix(7, 6);
constant MO5_8        : std_logic_vector(5 downto 0) := mo5_matrix(6, 6);
constant MO5_9        : std_logic_vector(5 downto 0) := mo5_matrix(5, 6);

constant MO5_AROBASE  : std_logic_vector(5 downto 0) := mo5_matrix(4, 0);
constant MO5_MINUS    : std_logic_vector(5 downto 0) := mo5_matrix(3, 6);
constant MO5_PLUS     : std_logic_vector(5 downto 0) := mo5_matrix(2, 6);
constant MO5_MULTIPLY : std_logic_vector(5 downto 0) := mo5_matrix(2, 4);
constant MO5_SPACE    : std_logic_vector(5 downto 0) := mo5_matrix(3, 0);
constant MO5_COMMA    : std_logic_vector(5 downto 0) := mo5_matrix(6, 0);
constant MO5_PERIOD   : std_logic_vector(5 downto 0) := mo5_matrix(5, 0);
constant MO5_DIVIDE   : std_logic_vector(5 downto 0) := mo5_matrix(3, 4);

-- PS/2 Keyboard Scan Codes (Set 2)
-- Alphabetic Keys
constant PS2_A            : integer := 16#1C#; 
constant PS2_B            : integer := 16#32#;
constant PS2_C            : integer := 16#21#;
constant PS2_D            : integer := 16#23#;
constant PS2_E            : integer := 16#24#;
constant PS2_F            : integer := 16#2B#;
constant PS2_G            : integer := 16#34#;
constant PS2_H            : integer := 16#33#;
constant PS2_I            : integer := 16#43#;
constant PS2_J            : integer := 16#3B#;
constant PS2_K            : integer := 16#42#;
constant PS2_L            : integer := 16#4B#;
constant PS2_M            : integer := 16#3A#;
constant PS2_N            : integer := 16#31#;
constant PS2_O            : integer := 16#44#;
constant PS2_P            : integer := 16#4D#;
constant PS2_Q            : integer := 16#15#; 
constant PS2_R            : integer := 16#2D#;
constant PS2_S            : integer := 16#1B#;
constant PS2_T            : integer := 16#2C#;
constant PS2_U            : integer := 16#3C#;
constant PS2_V            : integer := 16#2A#;
constant PS2_W            : integer := 16#1D#;
constant PS2_X            : integer := 16#22#;
constant PS2_Y            : integer := 16#35#;
constant PS2_Z            : integer := 16#1A#;
 
-- Numeric Keys
constant PS2_0            : integer := 16#45#;
constant PS2_1            : integer := 16#16#;
constant PS2_2            : integer := 16#1E#;
constant PS2_3            : integer := 16#26#;
constant PS2_4            : integer := 16#25#;
constant PS2_5            : integer := 16#2E#;
constant PS2_6            : integer := 16#36#;
constant PS2_7            : integer := 16#3D#;
constant PS2_8            : integer := 16#3E#;
constant PS2_9            : integer := 16#46#;

-- Function Keys
constant PS2_F1           : integer := 16#05#;
constant PS2_F2           : integer := 16#06#;
constant PS2_F3           : integer := 16#04#;
constant PS2_F4           : integer := 16#0C#;
constant PS2_F5           : integer := 16#03#;
constant PS2_F6           : integer := 16#0B#;
constant PS2_F7           : integer := 16#83#;
constant PS2_F8           : integer := 16#0A#;
constant PS2_F9           : integer := 16#01#;
constant PS2_F10          : integer := 16#09#;
constant PS2_F11          : integer := 16#78#;
constant PS2_F12          : integer := 16#07#;

-- Special Keys
constant PS2_ESCAPE       : integer := 16#76#;
constant PS2_BACKSPACE    : integer := 16#66#;
constant PS2_TAB          : integer := 16#0D#;
constant PS2_SPACEBAR     : integer := 16#29#;
constant PS2_CAPS_LOCK    : integer := 16#58#;
constant PS2_ENTER        : integer := 16#5A#;
constant PS2_LEFT_SHIFT   : integer := 16#12#;
constant PS2_RIGHT_SHIFT  : integer := 16#59#;
constant PS2_LEFT_CTRL    : integer := 16#14#;
constant PS2_LEFT_ALT     : integer := 16#11#;
constant PS2_RIGHT_ALT    : integer := 16#11#; -- E0 prefix + 11
constant PS2_RIGHT_CTRL   : integer := 16#14#; -- E0 prefix + 14
constant PS2_SCROLL_LOCK  : integer := 16#7E#;
constant PS2_NUM_LOCK     : integer := 16#77#;

-- Symbol Keys
constant PS2_GRAVE        : integer := 16#0E#; -- `
constant PS2_PARAGRAPH    : integer := 16#0E#;
constant PS2_MINUS        : integer := 16#4E#; -- -
constant PS2_EQUALS       : integer := 16#55#; -- =
constant PS2_BACKSLASH    : integer := 16#5D#; -- \
constant PS2_BRACKET_L    : integer := 16#54#; -- [
constant PS2_BRACKET_R    : integer := 16#5B#; -- ]
constant PS2_SEMICOLON    : integer := 16#4C#; -- ;
constant PS2_APOSTROPHE   : integer := 16#52#; -- '
constant PS2_COMMA        : integer := 16#41#; -- ,
constant PS2_PERIOD       : integer := 16#49#; -- .
constant PS2_SLASH        : integer := 16#4A#; -- /
constant PS2_SUPERIOR     : integer := 16#61#; -- >

-- Keypad Keys
constant PS2_KP_0         : integer := 16#70#;
constant PS2_KP_1         : integer := 16#69#;
constant PS2_KP_2         : integer := 16#72#;
constant PS2_KP_3         : integer := 16#7A#;
constant PS2_KP_4         : integer := 16#6B#;
constant PS2_KP_5         : integer := 16#73#;
constant PS2_KP_6         : integer := 16#74#;
constant PS2_KP_7         : integer := 16#6C#;
constant PS2_KP_8         : integer := 16#75#;
constant PS2_KP_9         : integer := 16#7D#;
constant PS2_KP_DECIMAL   : integer := 16#71#;
constant PS2_KP_PLUS      : integer := 16#79#;
constant PS2_KP_MINUS     : integer := 16#7B#;
constant PS2_KP_MULTIPLY  : integer := 16#7C#;
constant PS2_KP_DIVIDE    : integer := 16#4A#; -- E0 prefix + 4A
constant PS2_KP_ENTER     : integer := 16#5A#; -- E0 prefix + 5A

-- Navigation Keys
constant PS2_INSERT       : integer := 16#70#; -- E0 prefix + 70
constant PS2_HOME         : integer := 16#6C#; -- E0 prefix + 6C
constant PS2_PAGE_UP      : integer := 16#7D#; -- E0 prefix + 7D
constant PS2_DELETE       : integer := 16#71#; -- E0 prefix + 71
constant PS2_END          : integer := 16#69#; -- E0 prefix + 69
constant PS2_PAGE_DOWN    : integer := 16#7A#; -- E0 prefix + 7A
constant PS2_UP_ARROW     : integer := 16#75#; -- E0 prefix + 75
constant PS2_LEFT_ARROW   : integer := 16#6B#; -- E0 prefix + 6B
constant PS2_DOWN_ARROW   : integer := 16#72#; -- E0 prefix + 72
constant PS2_RIGHT_ARROW  : integer := 16#74#; -- E0 prefix + 74

-- Windows/Menu Keys (Modern keyboards)
constant PS2_LEFT_WIN     : integer := 16#1F#; -- E0 prefix + 1F
constant PS2_RIGHT_WIN    : integer := 16#27#; -- E0 prefix + 27
constant PS2_MENU         : integer := 16#2F#; -- E0 prefix + 2F

type table_type  is array (0 to 1023) of std_logic_vector(7 downto 0);

constant table : table_type := (
	ps2_index(PS2_A,           '0', '0') => mo5_output('0', '0', MO5_A),
	ps2_index(PS2_B,           '0', '0') => mo5_output('0', '0', MO5_B),
	ps2_index(PS2_C,           '0', '0') => mo5_output('0', '0', MO5_C),
	ps2_index(PS2_D,           '0', '0') => mo5_output('0', '0', MO5_D),
	ps2_index(PS2_E,           '0', '0') => mo5_output('0', '0', MO5_E),
	ps2_index(PS2_F,           '0', '0') => mo5_output('0', '0', MO5_F),
	ps2_index(PS2_G,           '0', '0') => mo5_output('0', '0', MO5_G),
	ps2_index(PS2_H,           '0', '0') => mo5_output('0', '0', MO5_H),
	ps2_index(PS2_I,           '0', '0') => mo5_output('0', '0', MO5_I),
	ps2_index(PS2_J,           '0', '0') => mo5_output('0', '0', MO5_J),
	ps2_index(PS2_K,           '0', '0') => mo5_output('0', '0', MO5_K),
	ps2_index(PS2_L,           '0', '0') => mo5_output('0', '0', MO5_L),
	ps2_index(PS2_M,           '0', '0') => mo5_output('0', '0', MO5_M),
	ps2_index(PS2_N,           '0', '0') => mo5_output('0', '0', MO5_N),
	ps2_index(PS2_O,           '0', '0') => mo5_output('0', '0', MO5_O),
	ps2_index(PS2_P,           '0', '0') => mo5_output('0', '0', MO5_P),
	ps2_index(PS2_Q,           '0', '0') => mo5_output('0', '0' ,MO5_Q),
	ps2_index(PS2_R,           '0', '0') => mo5_output('0', '0', MO5_R),
	ps2_index(PS2_S,           '0', '0') => mo5_output('0', '0', MO5_S),
	ps2_index(PS2_T,           '0', '0') => mo5_output('0', '0', MO5_T),
	ps2_index(PS2_U,           '0', '0') => mo5_output('0', '0', MO5_U),
	ps2_index(PS2_V,           '0', '0') => mo5_output('0', '0', MO5_V),
	ps2_index(PS2_W,           '0', '0') => mo5_output('0', '0', MO5_W),
	ps2_index(PS2_X,           '0', '0') => mo5_output('0', '0', MO5_X),
	ps2_index(PS2_Y,           '0', '0') => mo5_output('0', '0', MO5_Y),
	ps2_index(PS2_Z,           '0', '0') => mo5_output('0', '0', MO5_Z),

	-- letters shifted
	ps2_index(PS2_A,           '0', '1') => mo5_output('0', '1', MO5_A),
	ps2_index(PS2_B,           '0', '1') => mo5_output('0', '1', MO5_B),
	ps2_index(PS2_C,           '0', '1') => mo5_output('0', '1', MO5_C),
	ps2_index(PS2_D,           '0', '1') => mo5_output('0', '1', MO5_D),
	ps2_index(PS2_E,           '0', '1') => mo5_output('0', '1', MO5_E),
	ps2_index(PS2_F,           '0', '1') => mo5_output('0', '1', MO5_F),
	ps2_index(PS2_G,           '0', '1') => mo5_output('0', '1', MO5_G),
	ps2_index(PS2_H,           '0', '1') => mo5_output('0', '1', MO5_H),
	ps2_index(PS2_I,           '0', '1') => mo5_output('0', '1', MO5_I),
	ps2_index(PS2_J,           '0', '1') => mo5_output('0', '1', MO5_J),
	ps2_index(PS2_K,           '0', '1') => mo5_output('0', '1', MO5_K),
	ps2_index(PS2_L,           '0', '1') => mo5_output('0', '1', MO5_L),
	ps2_index(PS2_M,           '0', '1') => mo5_output('0', '1', MO5_M),
	ps2_index(PS2_N,           '0', '1') => mo5_output('0', '1', MO5_N),
	ps2_index(PS2_O,           '0', '1') => mo5_output('0', '1', MO5_O),
	ps2_index(PS2_P,           '0', '1') => mo5_output('0', '1', MO5_P),
	ps2_index(PS2_Q,           '0', '1') => mo5_output('0', '1' ,MO5_Q),
	ps2_index(PS2_R,           '0', '1') => mo5_output('0', '1', MO5_R),
	ps2_index(PS2_S,           '0', '1') => mo5_output('0', '1', MO5_S),
	ps2_index(PS2_T,           '0', '1') => mo5_output('0', '1', MO5_T),
	ps2_index(PS2_U,           '0', '1') => mo5_output('0', '1', MO5_U),
	ps2_index(PS2_V,           '0', '1') => mo5_output('0', '1', MO5_V),
	ps2_index(PS2_W,           '0', '1') => mo5_output('0', '1', MO5_W),
	ps2_index(PS2_X,           '0', '1') => mo5_output('0', '1', MO5_X),
	ps2_index(PS2_Y,           '0', '1') => mo5_output('0', '1', MO5_Y),
	ps2_index(PS2_Z,           '0', '1') => mo5_output('0', '1', MO5_Z),

	-- numbers non shifted
	ps2_index(PS2_0,           '0', '0') => mo5_output('0', '0', MO5_0),
	ps2_index(PS2_1,           '0', '0') => mo5_output('0', '0', MO5_1),
	ps2_index(PS2_2,           '0', '0') => mo5_output('0', '0', MO5_2),
	ps2_index(PS2_3,           '0', '0') => mo5_output('0', '0', MO5_3),
	ps2_index(PS2_4,           '0', '0') => mo5_output('0', '0', MO5_4),
	ps2_index(PS2_5,           '0', '0') => mo5_output('0', '0', MO5_5),
	ps2_index(PS2_6,           '0', '0') => mo5_output('0', '0', MO5_6),
	ps2_index(PS2_7,           '0', '0') => mo5_output('0', '0', MO5_7),
	ps2_index(PS2_8,           '0', '0') => mo5_output('0', '0', MO5_8),
	ps2_index(PS2_9,           '0', '0') => mo5_output('0', '0', MO5_9),

	-- numbers shifted
	ps2_index(PS2_0,           '0', '1') => mo5_output('0', '1', MO5_9),
	ps2_index(PS2_1,           '0', '1') => mo5_output('0', '1', MO5_1),
	ps2_index(PS2_2,           '0', '1') => mo5_output('0', '0', MO5_AROBASE),
	ps2_index(PS2_3,           '0', '1') => mo5_output('0', '1', MO5_3),
	ps2_index(PS2_4,           '0', '1') => mo5_output('0', '1', MO5_4),
	ps2_index(PS2_5,           '0', '1') => mo5_output('0', '1', MO5_5),
	ps2_index(PS2_6,           '0', '1') => mo5_output('0', '1', MO5_AROBASE),
	ps2_index(PS2_7,           '0', '1') => mo5_output('0', '1', MO5_6),
	ps2_index(PS2_8,           '0', '1') => mo5_output('0', '0', MO5_MULTIPLY),
	ps2_index(PS2_9,           '0', '1') => mo5_output('0', '1', MO5_8),

	-- numbers accentuated
--	ps2_index(PS2_0,           '0', '0') => mo5_output('1', '0', MO5_0),
--	ps2_index(PS2_6,           '0', '0') => mo5_output('1', '0', MO5_6),
--	ps2_index(PS2_7,           '0', '0') => mo5_output('1', '0', MO5_7),
--	ps2_index(PS2_8,           '0', '0') => mo5_output('1', '0', MO5_8),
--	ps2_index(PS2_9,           '0', '0') => mo5_output('1', '0', MO5_9),
	
	-- decimal keypad
	ps2_index(PS2_KP_0,        '0', '0') => mo5_output('0', '0', MO5_0),
	ps2_index(PS2_KP_1,        '0', '0') => mo5_output('0', '0', MO5_1),
	ps2_index(PS2_KP_2,        '0', '0') => mo5_output('0', '0', MO5_2),
	ps2_index(PS2_KP_3,        '0', '0') => mo5_output('0', '0', MO5_3),
	ps2_index(PS2_KP_4,        '0', '0') => mo5_output('0', '0', MO5_4),
	ps2_index(PS2_KP_5,        '0', '0') => mo5_output('0', '0', MO5_5),
	ps2_index(PS2_KP_6,        '0', '0') => mo5_output('0', '0', MO5_6),
	ps2_index(PS2_KP_7,        '0', '0') => mo5_output('0', '0', MO5_7),
	ps2_index(PS2_KP_8,        '0', '0') => mo5_output('0', '0', MO5_8),
	ps2_index(PS2_KP_9,        '0', '0') => mo5_output('0', '0', MO5_9),
	ps2_index(PS2_KP_DECIMAL,  '0', '0') => mo5_output('0', '0', MO5_PERIOD),
	ps2_index(PS2_KP_PLUS,     '0', '0') => mo5_output('0', '0', MO5_PLUS),
	ps2_index(PS2_KP_MINUS,    '0', '0') => mo5_output('0', '0', MO5_MINUS),
	ps2_index(PS2_KP_MULTIPLY, '0', '0') => mo5_output('0', '0', MO5_MULTIPLY),
	ps2_index(PS2_KP_DIVIDE,   '1', '0') => mo5_output('0', '0', MO5_DIVIDE),
	ps2_index(PS2_KP_ENTER,    '1', '0') => mo5_output('0', '0', MO5_ENT),

	-- function key remapped to numbers 0..9
	ps2_index(PS2_F1,          '0', '0') => mo5_output('0', '0', MO5_1),
	ps2_index(PS2_F2,          '0', '0') => mo5_output('0', '0', MO5_2),
	ps2_index(PS2_F3,          '0', '0') => mo5_output('0', '0', MO5_3),
	ps2_index(PS2_F4,          '0', '0') => mo5_output('0', '0', MO5_4),
	ps2_index(PS2_F5,          '0', '0') => mo5_output('0', '0', MO5_5),
	ps2_index(PS2_F6,          '0', '0') => mo5_output('0', '0', MO5_6),
	ps2_index(PS2_F7,          '0', '0') => mo5_output('0', '0', MO5_7),
	ps2_index(PS2_F8,          '0', '0') => mo5_output('0', '0', MO5_8),
	ps2_index(PS2_F9,          '0', '0') => mo5_output('0', '0', MO5_9),
	ps2_index(PS2_F10,         '0', '0') => mo5_output('0', '0', MO5_0),
	
	-- navigation keys	
	ps2_index(PS2_LEFT_WIN,    '0', '0') => mo5_output('0', '0', MO5_BASIC),
	ps2_index(PS2_RIGHT_WIN,   '0', '0') => mo5_output('0', '0', MO5_BASIC),
	ps2_index(PS2_END,         '1', '0') => mo5_output('0', '0', MO5_RAZ),
	ps2_index(PS2_LEFT_SHIFT,  '0', '0') => mo5_output('0', '0', MO5_SHIFT),
	ps2_index(PS2_RIGHT_SHIFT, '0', '0') => mo5_output('0', '0', MO5_SHIFT),
	ps2_index(PS2_LEFT_CTRL,   '0', '0') => mo5_output('0', '0', MO5_CNT),
	ps2_index(PS2_RIGHT_CTRL,  '1', '0') => mo5_output('0', '0', MO5_CNT),
	ps2_index(PS2_LEFT_ALT,    '0', '0') => mo5_output('0', '0', MO5_ACC),
	ps2_index(PS2_RIGHT_ALT,   '1', '0') => mo5_output('0', '0', MO5_ACC),
	ps2_index(PS2_HOME,        '1', '0') => mo5_output('0', '0', MO5_MERGE),
	ps2_index(PS2_INSERT,      '1', '0') => mo5_output('0', '0', MO5_INS),
	ps2_index(PS2_DELETE,      '1', '0') => mo5_output('0', '0', MO5_EFF),
	ps2_index(PS2_LEFT_ARROW,  '1', '0') => mo5_output('0', '0', MO5_CSRL),
	ps2_index(PS2_RIGHT_ARROW, '1', '0') => mo5_output('0', '0', MO5_CSRR),
	ps2_index(PS2_UP_ARROW,    '1', '0') => mo5_output('0', '0', MO5_CSRU),
	ps2_index(PS2_DOWN_ARROW,  '1', '0') => mo5_output('0', '0', MO5_CSRD),
	ps2_index(PS2_BACKSPACE,   '0', '0') => mo5_output('0', '0', MO5_CSRL),
	ps2_index(PS2_SPACEBAR,    '0', '0') => mo5_output('0', '0', MO5_SPACE),
	ps2_index(PS2_TAB,         '0', '0') => mo5_output('0', '0', MO5_STOP),
	ps2_index(PS2_ENTER,       '0', '0') => mo5_output('0', '0', MO5_ENT),

	-- shifted navigation keys	
	ps2_index(PS2_LEFT_WIN,    '0', '1') => mo5_output('0', '0', MO5_BASIC),
	ps2_index(PS2_RIGHT_WIN,   '0', '1') => mo5_output('0', '0', MO5_BASIC),
	ps2_index(PS2_END,         '1', '1') => mo5_output('0', '0', MO5_RAZ),
	ps2_index(PS2_LEFT_SHIFT,  '0', '1') => mo5_output('0', '0', MO5_SHIFT),
	ps2_index(PS2_RIGHT_SHIFT, '0', '1') => mo5_output('0', '0', MO5_SHIFT),
	ps2_index(PS2_LEFT_CTRL,   '0', '1') => mo5_output('0', '0', MO5_CNT),
	ps2_index(PS2_RIGHT_CTRL,  '1', '1') => mo5_output('0', '0', MO5_CNT),
	ps2_index(PS2_LEFT_ALT,    '0', '1') => mo5_output('0', '0', MO5_ACC),
	ps2_index(PS2_RIGHT_ALT,   '1', '1') => mo5_output('0', '0', MO5_ACC),
	ps2_index(PS2_HOME,        '1', '1') => mo5_output('0', '0', MO5_MERGE),
	ps2_index(PS2_INSERT,      '1', '1') => mo5_output('0', '0', MO5_INS),
	ps2_index(PS2_DELETE,      '1', '1') => mo5_output('0', '0', MO5_EFF),
	ps2_index(PS2_LEFT_ARROW,  '1', '1') => mo5_output('0', '0', MO5_CSRL),
	ps2_index(PS2_RIGHT_ARROW, '1', '1') => mo5_output('0', '0', MO5_CSRR),
	ps2_index(PS2_UP_ARROW,    '1', '1') => mo5_output('0', '0', MO5_CSRU),
	ps2_index(PS2_DOWN_ARROW,  '1', '1') => mo5_output('0', '0', MO5_CSRD),
	ps2_index(PS2_BACKSPACE,   '0', '1') => mo5_output('0', '0', MO5_CSRL),
	ps2_index(PS2_SPACEBAR,    '0', '1') => mo5_output('0', '0', MO5_SPACE),
	ps2_index(PS2_TAB,         '0', '1') => mo5_output('0', '0', MO5_STOP),
	ps2_index(PS2_ENTER,       '0', '1') => mo5_output('0', '0', MO5_ENT),
	
	
	-- special keys non shifted
	ps2_index(PS2_COMMA,       '0', '0') => mo5_output('0', '0', MO5_COMMA),
	ps2_index(PS2_PERIOD,      '0', '0') => mo5_output('0', '0', MO5_PERIOD),
	ps2_index(PS2_SLASH,       '0', '0') => mo5_output('0', '0', MO5_DIVIDE),
	ps2_index(PS2_APOSTROPHE,  '0', '0') => mo5_output('0', '1', MO5_7),
	ps2_index(PS2_SEMICOLON,   '0', '0') => mo5_output('0', '1', MO5_PLUS),
	ps2_index(PS2_EQUALS,      '0', '0') => mo5_output('0', '1', MO5_MINUS),
	ps2_index(PS2_MINUS,       '0', '0') => mo5_output('0', '0', MO5_MINUS),

	-- special keys shifted
	ps2_index(PS2_COMMA,       '0', '1') => mo5_output('0', '0', MO5_COMMA),
	ps2_index(PS2_PERIOD,      '0', '1') => mo5_output('0', '1', MO5_PERIOD),
	ps2_index(PS2_SLASH,       '0', '1') => mo5_output('0', '1', MO5_DIVIDE),
	ps2_index(PS2_APOSTROPHE,  '0', '1') => mo5_output('0', '1', MO5_2),
	ps2_index(PS2_SEMICOLON,   '0', '1') => mo5_output('0', '1', MO5_MULTIPLY),
	ps2_index(PS2_EQUALS,      '0', '1') => mo5_output('0', '0', MO5_PLUS),
--	ps2_index(PS2_MINUS,       '0', '1') => mo5_output('0', '0', MO5_MINUS), DEAD KEY

	others => (others => '1')
);

begin

	output <= table(index);

end Behavioral;