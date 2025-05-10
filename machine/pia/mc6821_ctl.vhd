library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mc6821_ctl is
    generic (
        PORT_NAME : string := "A" 
    );
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;
		  clr_n      : in  std_logic;
		  set_n      : in  std_logic;
        cr         : in  std_logic_vector(7 downto 0);
        c1         : in  std_logic;
        c2_in      : in  std_logic;
        c2_out     : out std_logic;
        c2_oe      : out std_logic;
        irq_n      : out std_logic;
        irq1_flag  : out std_logic;
        irq2_flag  : out std_logic
    );
end entity mc6821_ctl;

architecture rtl of mc6821_ctl is
    signal c1_prev_reg       : std_logic := '0';
    signal c2_prev_reg       : std_logic := '0';
    signal c2_dir_reg        : std_logic := '1'; 
	 signal c2_reg            : std_logic := '0';
    signal irq1_flag_reg     : std_logic := '0';
    signal irq2_flag_reg     : std_logic := '0';
    signal c1_trig           : std_logic := '0';
    signal e_trig            : std_logic := '0';

begin

	process(clk, reset_n)
   begin
		if reset_n = '0' then
			c1_prev_reg   <= '0';
         c2_prev_reg   <= '0';
         irq1_flag_reg <= '0';
         irq2_flag_reg <= '0';
			c1_trig       <= '0';
			e_trig        <= '0';
		elsif rising_edge(clk) then
			c1_prev_reg <= c1;
			c2_prev_reg <= c2_in;
			
			-- process C1 
            
			if (cr(1) = '0') and (c1_prev_reg = '1') and (c1 = '0') then
				irq1_flag_reg <= '1';
			end if;
			if (cr(1) = '1') and (c1_prev_reg = '0') and (c1 = '1') then
				irq1_flag_reg <= '1';
			end if;

			-- IRQ flag clear
			if clr_n = '0' then
				irq1_flag_reg <= '0';
				irq2_flag_reg <= '0';
			end if;

			-- process C2
			if c1_trig = '1' and c1_prev_reg = '0' and c1 = '1' then
				c2_reg  <= '1';
				c1_trig <= '0';
			end if;
		
			if e_trig = '1' then
				c2_reg  <= '1';
				e_trig <= '0';
			end if;
			
            
			if cr(5) = '0' then
				if cr(4)= '0' then
					if c2_prev_reg = '1' and c2_in = '0' then	
						irq2_flag_reg <= '1';
					end if;
				else
					if c2_prev_reg = '0' and c2_in = '1' then	
						irq2_flag_reg <= '1';
					end if;
				end if;
			else
				if cr(4) = '0' then
					if cr(3) = '0' then
						if set_n = '0' then 
							c2_reg  <= '0';
							c1_trig <= '1';
							irq2_flag_reg <= '1';
						end if;
					else
						if set_n = '0' then 
							c2_reg  <= '0';
							e_trig <= '1';
							irq2_flag_reg <= '1';
						end if;
					end if;
				else
					c2_reg <= cr(3);
				end if;
			end if;
		end if;
    end process;

    irq_n <= '0' when ((cr(0) = '1') and (irq1_flag_reg = '1'))  or  ((cr(5) = '0') and (cr(3) = '1') and (irq2_flag_reg = '1'))  else '1';
            
    c2_out <= c2_reg;
    c2_oe  <= cr(5);
    irq1_flag <= irq1_flag_reg;
    irq2_flag <= irq2_flag_reg;
    
end architecture rtl;