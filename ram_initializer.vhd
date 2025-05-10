library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ram_initializer is
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        clock_ready: in  std_logic;
        reset_out  : in  std_logic;  -- Add reset_out input for CTRL-ALT-DEL
        ram_address: out std_logic_vector(18 downto 0);
        ram_data   : out std_logic_vector(7 downto 0);
        ram_cs_n   : out std_logic;
        ram_rw     : out std_logic;
        init_done  : out std_logic;
        cpu_reset_n: out std_logic
    );
end entity;
architecture rtl of ram_initializer is
    type state_type is (IDLE, SETUP, WAIT_STATE, NEXT_ADDR, DELAY, DONE, CPU_RESET, CPU_RESET_DELAY);
    signal state        : state_type := IDLE;
    signal addr_counter : unsigned(15 downto 0) := (others => '0');
    signal delay_counter: unsigned(7 downto 0) := (others => '0');
    signal reset_delay  : unsigned(7 downto 0) := (others => '0');
    signal mem_init_done: std_logic := '0';  -- Flag to track if memory was initialized
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
            addr_counter <= (others => '0');
            delay_counter <= (others => '0');
            reset_delay <= (others => '0');
            ram_cs_n <= '1'; 
            ram_rw <= '1';    
            ram_data <=  (others => '0');
            ram_address <= (others => '0');
            init_done <= '0';
            cpu_reset_n <= '0';
            mem_init_done <= '0';
            
        elsif rising_edge(clk) then
            -- Check for CTRL-ALT-DEL reset request when in DONE state
            if state = DONE and reset_out = '1' then
                state <= CPU_RESET;
                cpu_reset_n <= '0';
                reset_delay <= (others => '0');
            else
                case state is
                    when IDLE =>
                        if clock_ready = '1' then
                            -- Only initialize memory if it hasn't been done yet
                            if mem_init_done = '0' then
                                state <= SETUP;
                                addr_counter <= (others => '0');
                            else
                                state <= DONE;
                                init_done <= '1';
                            end if;
                        end if;
                        
                    when SETUP =>
                        ram_address <= "000" & std_logic_vector(addr_counter);
                        ram_data <= (others => '0');  
                        ram_rw <= '0';                
                        ram_cs_n <= '0';              
                        state <= WAIT_STATE;
                        
                    when WAIT_STATE =>
                        state <= NEXT_ADDR;
                        
                    when NEXT_ADDR =>
                        ram_cs_n <= '1';  
                        ram_rw <= '1';  
                        if addr_counter = x"9FFF" then
                            state <= DELAY;
                        else
                            addr_counter <= addr_counter + 1;
                            state <= SETUP;
                        end if;
                        
                    when DELAY =>
                        if delay_counter = 255 then
                            state <= DONE;
                            init_done <= '1';
                            mem_init_done <= '1';  -- Mark memory initialization as complete
                        else
                            delay_counter <= delay_counter + 1;
                        end if;
                        
                    when DONE =>
                        cpu_reset_n <= '1';
                        
                    -- New states for handling CTRL-ALT-DEL reset
                    when CPU_RESET =>
                        -- Keep CPU in reset for some time
                        if reset_delay = 255 then
                            state <= CPU_RESET_DELAY;
                        else
                            reset_delay <= reset_delay + 1;
                        end if;
                        
                    when CPU_RESET_DELAY =>
                        -- Wait for reset_out to go back to 0 before releasing CPU reset
                        if reset_out = '0' then
                            state <= DONE;
                            cpu_reset_n <= '1';
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;