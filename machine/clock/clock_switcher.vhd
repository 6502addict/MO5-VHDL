library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_switcher is
    Port ( 
        clk_1mhz     : in  STD_LOGIC;
        clk_10mhz    : in  STD_LOGIC;
        clock_select : in  STD_LOGIC;  -- '0' for 1MHz, '1' for 10MHz (from physical switch)
        reset_n      : in  STD_LOGIC;
        cpu_clock    : out STD_LOGIC
    );
end clock_switcher;

architecture Behavioral of clock_switcher is
    -- Debounce constants (adjust based on your specific switch characteristics)
    constant DEBOUNCE_LIMIT : integer := 50000; -- For 10MHz clock (~5ms debounce time)
    
    -- Debounce signals
    signal debounce_counter : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal switch_stable    : STD_LOGIC := '0';
    signal last_switch_state : STD_LOGIC := '0';
    signal debounced_select : STD_LOGIC := '0';
    
    -- Synchronizer signals for debounced_select in both domains
    signal select_sync_1mhz  : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal select_sync_10mhz : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    
    -- Clock domain state signals
    signal clk_1mhz_active   : STD_LOGIC := '1';
    signal clk_10mhz_active  : STD_LOGIC := '0';
    
    -- Edge detection signals
    signal last_1mhz_edge    : STD_LOGIC := '0';
    signal last_10mhz_edge   : STD_LOGIC := '0';
    
    -- Handshake signals for safe switching
    signal request_switch_to_1mhz  : STD_LOGIC := '0';
    signal request_switch_to_10mhz : STD_LOGIC := '0';
    signal safe_to_switch_1mhz     : STD_LOGIC := '0';
    signal safe_to_switch_10mhz    : STD_LOGIC := '0';
    
    -- Clock multiplexer control 
    signal use_1mhz_clock    : STD_LOGIC := '1';
    
    -- State machine states
    type switch_state_t is (STABLE_1MHZ, STABLE_10MHZ, SWITCHING_TO_1MHZ, SWITCHING_TO_10MHZ);
    signal switch_state : switch_state_t := STABLE_1MHZ;
    
begin
    -- Debouncing process for clock_select (runs on 10MHz clock for faster response)
    process(clk_10mhz, reset_n)
    begin
        if reset_n = '0' then
            debounce_counter <= 0;
            switch_stable <= '0';
            last_switch_state <= '0';
            debounced_select <= '0';
        elsif rising_edge(clk_10mhz) then
            -- Check if the switch has changed
            if clock_select /= last_switch_state then
                last_switch_state <= clock_select;
                debounce_counter <= 0;
                switch_stable <= '0';
            elsif debounce_counter = DEBOUNCE_LIMIT then
                -- Switch has been stable for DEBOUNCE_LIMIT cycles
                switch_stable <= '1';
            else
                debounce_counter <= debounce_counter + 1;
            end if;
            
            -- Update debounced value when switch is stable
            if switch_stable = '1' then
                debounced_select <= last_switch_state;
            end if;
        end if;
    end process;
    
    -- Triple-synchronize debounced_select to both clock domains
    process(clk_1mhz, reset_n)
    begin
        if reset_n = '0' then
            select_sync_1mhz <= (others => '0');
        elsif rising_edge(clk_1mhz) then
            select_sync_1mhz <= select_sync_1mhz(1 downto 0) & debounced_select;
        end if;
    end process;
    
    process(clk_10mhz, reset_n)
    begin
        if reset_n = '0' then
            select_sync_10mhz <= (others => '0');
        elsif rising_edge(clk_10mhz) then
            select_sync_10mhz <= select_sync_10mhz(1 downto 0) & debounced_select;
        end if;
    end process;
    
    -- Edge detection for clock completion in 1MHz domain
    process(clk_1mhz, reset_n)
    begin
        if reset_n = '0' then
            last_1mhz_edge <= '0';
            safe_to_switch_1mhz <= '0';
            request_switch_to_10mhz <= '0';
        elsif rising_edge(clk_1mhz) then
            last_1mhz_edge <= '1';  -- Mark completion of 1MHz cycle
            
            -- Detect request to switch to 10MHz
            if select_sync_1mhz(2) = '1' and clk_1mhz_active = '1' then
                request_switch_to_10mhz <= '1';
            elsif clk_1mhz_active = '0' then
                request_switch_to_10mhz <= '0';
            end if;
            
            -- Signal that it's safe to switch away from 1MHz clock
            -- Only allow switching at a completed clock cycle
            if request_switch_to_10mhz = '1' and last_1mhz_edge = '1' then
                safe_to_switch_1mhz <= '1';
            else
                safe_to_switch_1mhz <= '0';
            end if;
        end if;
    end process;
    
    -- Edge detection for clock completion in 10MHz domain
    process(clk_10mhz, reset_n)
    begin
        if reset_n = '0' then
            last_10mhz_edge <= '0';
            safe_to_switch_10mhz <= '0';
            request_switch_to_1mhz <= '0';
        elsif rising_edge(clk_10mhz) then
            last_10mhz_edge <= '1';  -- Mark completion of 10MHz cycle
            
            -- Detect request to switch to 1MHz
            if select_sync_10mhz(2) = '0' and clk_10mhz_active = '1' then
                request_switch_to_1mhz <= '1';
            elsif clk_10mhz_active = '0' then
                request_switch_to_1mhz <= '0';
            end if;
            
            -- Signal that it's safe to switch away from 10MHz clock
            -- Only allow switching at a completed clock cycle
            if request_switch_to_1mhz = '1' and last_10mhz_edge = '1' then
                safe_to_switch_10mhz <= '1';
            else
                safe_to_switch_10mhz <= '0';
            end if;
        end if;
    end process;
    
    -- Clock switching state machine (runs on faster clock)
    process(clk_10mhz, reset_n)
    begin
        if reset_n = '0' then
            switch_state <= STABLE_1MHZ;
            clk_1mhz_active <= '1';
            clk_10mhz_active <= '0';
            use_1mhz_clock <= '1';
        elsif rising_edge(clk_10mhz) then
            case switch_state is
                when STABLE_1MHZ =>
                    -- Check if we need to switch to 10MHz
                    if select_sync_10mhz(2) = '1' and safe_to_switch_1mhz = '1' then
                        switch_state <= SWITCHING_TO_10MHZ;
                        clk_10mhz_active <= '1';
                        use_1mhz_clock <= '0';  -- Switch to 10MHz
                    end if;
                    
                when STABLE_10MHZ =>
                    -- Check if we need to switch to 1MHz
                    if select_sync_10mhz(2) = '0' and safe_to_switch_10mhz = '1' then
                        switch_state <= SWITCHING_TO_1MHZ;
                        clk_1mhz_active <= '1';
                        use_1mhz_clock <= '1';  -- Switch to 1MHz
                    end if;
                    
                when SWITCHING_TO_10MHZ =>
                    -- Complete the transition
                    clk_1mhz_active <= '0';
                    switch_state <= STABLE_10MHZ;
                    
                when SWITCHING_TO_1MHZ =>
                    -- Complete the transition
                    clk_10mhz_active <= '0';
                    switch_state <= STABLE_1MHZ;
                    
                when others =>
                    -- Recover from invalid state
                    switch_state <= STABLE_1MHZ;
                    clk_1mhz_active <= '1';
                    clk_10mhz_active <= '0';
                    use_1mhz_clock <= '1';
            end case;
        end if;
    end process;
    
    -- Clock multiplexer
    cpu_clock <= clk_1mhz when use_1mhz_clock = '1' else clk_10mhz;
    
end Behavioral;