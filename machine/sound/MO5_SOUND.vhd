library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MO5_SOUND is
    Port ( 
        CLOCK_50     : in  std_logic;                     -- 50MHz system clock
        clock_48Khz  : in  std_logic;                     -- 48 Khz clock
        sound        : in  std_logic;                     -- 1 bit sound signal                
        reset_n      : in  std_logic;
        I2C_SCLK     : out STD_LOGIC;                     -- I2C Clock
        I2C_SDAT     : inout STD_LOGIC;                   -- I2C Data
        AUD_ADCLRCK  : out STD_LOGIC;                     -- ADC LR Clock
        AUD_ADCDAT   : in  STD_LOGIC;                     -- ADC Data
        AUD_DACLRCK  : out STD_LOGIC;                     -- DAC LR Clock
        AUD_DACDAT   : out STD_LOGIC;                     -- DAC Data
        AUD_XCK      : out STD_LOGIC;                     -- Codec Master Clock
        AUD_BCLK     : out STD_LOGIC                      -- Bit-Stream Clock
    );
end MO5_SOUND;

architecture Behavioral of MO5_SOUND is
    component i2c_controller is
        port (
            clk         : in    std_logic;
            reset_n     : in    std_logic;
            start       : in    std_logic;
            address     : in    std_logic_vector(6 downto 0);
            rw          : in    std_logic;
            data_wr     : in    std_logic_vector(7 downto 0);
            busy        : out   std_logic;
            data_rd     : out   std_logic_vector(7 downto 0);
            ack_error   : out   std_logic;
            sda         : inout std_logic;
            scl         : out   std_logic
        );
    end component;
    
    constant WM8731_ADDR : std_logic_vector(6 downto 0) := "0011010"; -- Device address
    type reg_array is array (natural range <>) of std_logic_vector(15 downto 0);
    constant CONFIG_REGS : reg_array(0 to 9) := (
        -- Reset control
        x"1E00", -- R15: Reset
        -- Power control
        x"0C00", -- R6: Power down control (all powered up)
        -- Digital audio path control
        x"0817", -- R4: Digital audio path control (DAC enabled, no HPF)
        -- Analog audio path control
        x"1000", -- R8: Analog audio path control (DAC selected, line in muted)
        -- Digital audio interface format
        x"0A02", -- R5: Digital audio interface format (I2S, 16-bit, master mode)
        -- Sampling control
        x"0E01", -- R7: Sampling control (normal mode, 48kHz)
        -- Active control
        x"1201", -- R9: Active control (active)
        -- Left and right headphone out
        x"0279", -- R1: Left headphone out (volume level)
        x"0479", -- R2: Right headphone out (volume level)
        -- Line In
        x"0000" -- R0: Left/right line in (muted)
    );
    
    -- I2C signals
    signal i2c_reset_n   : std_logic;
    signal i2c_start     : std_logic := '0';
    signal i2c_busy      : std_logic;
    signal i2c_data_wr   : std_logic_vector(7 downto 0);
    signal i2c_data_rd   : std_logic_vector(7 downto 0);
    signal i2c_ack_error : std_logic;
    
    signal aud_clock_cnt : unsigned(1 downto 0) := (others => '0');
    signal aud_xck_reg   : std_logic := '0';
    
    type config_state_type is (IDLE, START_CONFIG, SEND_ADDR_HIGH, WAIT_ACK1, 
                            SEND_ADDR_LOW, WAIT_ACK2, CONFIG_DONE);
    signal config_state   : config_state_type := IDLE;
    signal config_counter : integer range 0 to CONFIG_REGS'length := 0;
    
    -- Audio signals
    signal audio_sample   : signed(15 downto 0);
    signal sound_reg      : std_logic;
    signal sound_sample   : signed(15 downto 0);
    signal bit_counter    : unsigned(4 downto 0) := (others => '0');
    signal bclk_div       : unsigned(2 downto 0) := (others => '0');
    signal bclk_reg       : std_logic := '0';
    signal lrclk_reg      : std_logic := '0';
    signal dacdat_reg     : std_logic := '0';
    
begin
    i2c_inst: i2c_controller
    port map (
        clk       => CLOCK_50,
        reset_n   => i2c_reset_n,
        start     => i2c_start,
        address   => WM8731_ADDR,
        rw        => '0',  -- Always write
        data_wr   => i2c_data_wr,
        busy      => i2c_busy,
        data_rd   => i2c_data_rd,
        ack_error => i2c_ack_error,
        sda       => I2C_SDAT,
        scl       => I2C_SCLK
    );
    
    -- Audio master clock generation (12.5MHz from 50MHz)
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            aud_clock_cnt <= aud_clock_cnt + 1;
            if aud_clock_cnt = "11" then
                aud_xck_reg <= not aud_xck_reg;
                aud_clock_cnt <= "00";
            end if;
        end if;
    end process;
    
    AUD_XCK <= aud_xck_reg;
    
    -- WM8731 I2C Configuration
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            i2c_reset_n <= reset_n;
            
            if reset_n = '0' then
                config_state <= IDLE;
                config_counter <= 0;
                i2c_start <= '0';
            else
                case config_state is
                    when IDLE =>
                        if config_counter = 0 then
                            config_state <= START_CONFIG;
                        end if;
                        
                    when START_CONFIG =>
                        if i2c_busy = '0' then
                            i2c_data_wr <= CONFIG_REGS(config_counter)(15 downto 8);
                            i2c_start <= '1';
                            config_state <= SEND_ADDR_HIGH;
                        end if;
                        
                    when SEND_ADDR_HIGH =>
                        if i2c_busy = '1' then
                            i2c_start <= '0';
                            config_state <= WAIT_ACK1;
                        end if;
                        
                    when WAIT_ACK1 =>
                        if i2c_busy = '0' then
                            i2c_data_wr <= CONFIG_REGS(config_counter)(7 downto 0);
                            i2c_start <= '1';
                            config_state <= SEND_ADDR_LOW;
                        end if;
                        
                    when SEND_ADDR_LOW =>
                        if i2c_busy = '1' then
                            i2c_start <= '0';
                            config_state <= WAIT_ACK2;
                        end if;
                        
                    when WAIT_ACK2 =>
                        if i2c_busy = '0' then
                            if config_counter < CONFIG_REGS'length - 1 then
                                config_counter <= config_counter + 1;
                                config_state <= START_CONFIG;
                            else
                                config_state <= CONFIG_DONE;
                            end if;
                        end if;
                        
                    when CONFIG_DONE =>
                        -- Stay in this state, configuration is done
                        
                    when others =>
                        config_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
    -- Sample the incoming 1-bit sound signal at 48 KHz
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if clock_48Khz = '1' then
                sound_reg <= sound;
                
                -- Convert 1-bit sound to 16-bit audio sample
                -- When sound is '1', output maximum positive value
                -- When sound is '0', output maximum negative value
                if sound_reg = '1' then
                    sound_sample <= x"3FFF";  -- Maximum positive value
                else
                    sound_sample <= x"C000";  -- Maximum negative value
                end if;
            end if;
        end if;
    end process;
    
    -- Audio clock generation
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            -- BCLK generation (bit clock)
            bclk_div <= bclk_div + 1;
            if bclk_div = "011" then
                bclk_reg <= not bclk_reg;
            end if;
            
            -- LRCLK generation (left/right clock, 48kHz)
            if bclk_div = "111" and bclk_reg = '1' then
                if bit_counter = "11111" then
                    lrclk_reg <= not lrclk_reg;
                    bit_counter <= (others => '0');
                else
                    bit_counter <= bit_counter + 1;
                end if;
            end if;
            
            -- Set audio sample on LR clock transition
            if lrclk_reg = '1' and bit_counter = "00000" then
                audio_sample <= sound_sample;
            end if;
            
            -- Transmit audio sample bits
            if bclk_div = "111" and bclk_reg = '1' then
                if bit_counter < "10000" then
                    dacdat_reg <= audio_sample(15 - to_integer(bit_counter(3 downto 0)));
                else
                    dacdat_reg <= '0';  -- Set data line to zero during inactive bits
                end if;
            end if;
        end if;
    end process;
    
    -- Connect generated signals to outputs
    AUD_BCLK <= bclk_reg;
    AUD_DACLRCK <= lrclk_reg;
    AUD_ADCLRCK <= lrclk_reg;
    AUD_DACDAT <= dacdat_reg;
    
end Behavioral;