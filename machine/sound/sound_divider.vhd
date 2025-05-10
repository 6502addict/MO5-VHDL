library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sound_divider is
    Port ( 
        clk         : in  STD_LOGIC;  -- System clock (10MHz)
        reset_n     : in  STD_LOGIC;  -- Active low reset
        sound_in    : in  STD_LOGIC;  -- Input sound signal
        sound_select: in  STD_LOGIC;  -- '0' for pass-through, '1' for time-stretched output
        sound_out   : out STD_LOGIC   -- Output sound signal
    );
end sound_divider;

architecture Behavioral of sound_divider is
    -- Memory to store 0.1s of samples (at 10MHz that's 1,000,000 samples)
    -- Using a more practical smaller buffer with decimation
    constant BUFFER_SIZE : integer := 1024;
    type memory_array is array(0 to BUFFER_SIZE-1) of STD_LOGIC;
    signal sample_buffer : memory_array := (others => '0');
    
    -- Counters and control signals
    signal write_addr    : unsigned(9 downto 0) := (others => '0');  -- 10 bits for 1024 locations
    signal read_addr     : unsigned(9 downto 0) := (others => '0');
    signal decimation_counter : unsigned(9 downto 0) := (others => '0');  -- Reduce sampling rate
    signal playback_counter   : unsigned(3 downto 0) := (others => '0');  -- Slow down playback
    
    -- State machine
    type state_type is (RECORDING, PLAYING);
    signal current_state : state_type := RECORDING;
    
    -- Buffer control
    signal buffer_full   : STD_LOGIC := '0';
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset all signals
            write_addr <= (others => '0');
            read_addr <= (others => '0');
            decimation_counter <= (others => '0');
            playback_counter <= (others => '0');
            buffer_full <= '0';
            current_state <= RECORDING;
        elsif rising_edge(clk) then
            
            case current_state is
                when RECORDING =>
                    -- Decimate input to fit in buffer (store 1 sample every 1000 clock cycles)
                    if decimation_counter = 999 then
                        decimation_counter <= (others => '0');
                        
                        -- Store the sample
                        sample_buffer(to_integer(write_addr)) <= sound_in;
                        
                        -- Increment write address
                        if write_addr = BUFFER_SIZE-1 then
                            write_addr <= (others => '0');
                            buffer_full <= '1';  -- Buffer is now full
                            current_state <= PLAYING;  -- Switch to playback
                            read_addr <= (others => '0');  -- Start reading from beginning
                        else
                            write_addr <= write_addr + 1;
                        end if;
                    else
                        decimation_counter <= decimation_counter + 1;
                    end if;
                
                when PLAYING =>
                    -- Play each sample for 10x longer (10 clock cycles)
                    playback_counter <= playback_counter + 1;
                    
                    if playback_counter = 9 then
                        playback_counter <= (others => '0');
                        
                        -- Increment read address
                        if read_addr = BUFFER_SIZE-1 then
                            read_addr <= (others => '0');
                            current_state <= RECORDING;  -- Switch back to recording
                            buffer_full <= '0';  -- Start refilling the buffer
                        else
                            read_addr <= read_addr + 1;
                        end if;
                    end if;
            end case;
        end if;
    end process;
    
    -- Output selection
    sound_out <= sound_in when sound_select = '0' else 
                 sample_buffer(to_integer(read_addr)) when current_state = PLAYING else
                 '0';  -- Default to silence when not playing
    
end Behavioral;