library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_controller is
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
end i2c_controller;

architecture Behavioral of i2c_controller is
    -- I2C bus speed configuration
    constant INPUT_CLK_FREQ  : integer := 50_000_000; -- 50 MHz input clock
    constant I2C_FREQ        : integer := 400_000;    -- 400 kHz I2C speed
    constant CLK_DIV         : integer := (INPUT_CLK_FREQ / (I2C_FREQ * 4)) - 1;
    
    -- I2C state machine
    type state_type is (IDLE, I2CSTART, COMMAND, SLAVEACK1, WRITE, SLAVEACK2, 
                        READ, MASTERACK, STOP);
    signal state : state_type := IDLE;
    
    -- I2C timing signals
    signal clk_count : integer range 0 to CLK_DIV := 0;
    signal clk_en    : std_logic := '0';
    signal scl_clk   : std_logic := '0';
    signal scl_ena   : std_logic := '0';
    signal sda_int   : std_logic := '1';
    signal sda_ena_n : std_logic := '1';
    
    -- I2C data/addressing
    signal bit_cnt   : integer range 0 to 7 := 7;
    signal addr_rw   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_tx   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_rx   : std_logic_vector(7 downto 0) := (others => '0');
    signal ack_error_int : std_logic := '0';
    
    -- Internal control signals
    signal busy_int  : std_logic := '0';
    signal command_restart : std_logic := '0';
    
begin
    -- Generate the timing for I2C clock and data
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            clk_count <= 0;
            clk_en <= '0';
        elsif rising_edge(clk) then
            if clk_count = CLK_DIV then
                clk_count <= 0;
                clk_en <= '1';
            else
                clk_count <= clk_count + 1;
                clk_en <= '0';
            end if;
        end if;
    end process;
    
    -- I2C state machine
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
            busy_int <= '0';
            scl_ena <= '0';
            sda_int <= '1';
            bit_cnt <= 7;
            data_rd <= (others => '0');
            ack_error_int <= '0';
        elsif rising_edge(clk) then
            if clk_en = '1' then
                case state is
                    when IDLE =>
                        if start = '1' then
                            busy_int <= '1';
                            addr_rw <= address & rw;
                            data_tx <= data_wr;
                            state <= I2CSTART;
                        else
                            busy_int <= '0';
                            state <= IDLE;
                        end if;
                        
                        scl_ena <= '0';
                        sda_int <= '1';
                        ack_error_int <= '0';
                        
                    when I2CSTART =>
                        busy_int <= '1';
                        state <= COMMAND;
                        scl_ena <= '1';
                        sda_int <= '0';
                    
                    when COMMAND =>
                        busy_int <= '1';
                        if bit_cnt = 0 then
                            bit_cnt <= 7;
                            state <= SLAVEACK1;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;
                        sda_int <= addr_rw(bit_cnt);
                    
                    when SLAVEACK1 =>
                        busy_int <= '1';
                        if addr_rw(0) = '0' then
                            state <= WRITE;
                        else
                            state <= READ;
                        end if;
                        sda_int <= '1';
                        bit_cnt <= 7;
                        if sda /= '0' then
                            ack_error_int <= '1';
                        end if;
                    
                    when WRITE =>
                        busy_int <= '1';
                        if bit_cnt = 0 then
                            bit_cnt <= 7;
                            state <= SLAVEACK2;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;
                        sda_int <= data_tx(bit_cnt);
                    
                    when SLAVEACK2 =>
                        busy_int <= '1';
                        if command_restart = '1' then
                            state <= I2CSTART;
                        else
                            state <= STOP;
                        end if;
                        sda_int <= '1';
                        if sda /= '0' then
                            ack_error_int <= '1';
                        end if;
                    
                    when READ =>
                        busy_int <= '1';
                        if bit_cnt = 0 then
                            bit_cnt <= 7;
                            state <= MASTERACK;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;
                        data_rx(bit_cnt) <= sda;
                        sda_int <= '1';
                    
                    when MASTERACK =>
                        busy_int <= '1';
                        if command_restart = '1' then
                            state <= I2CSTART;
                        else
                            state <= STOP;
                        end if;
                        data_rd <= data_rx;
                        sda_int <= '1';  -- Send NACK to indicate last byte
                    
                    when STOP =>
                        busy_int <= '0';
                        state <= IDLE;
                        scl_ena <= '0';
                        sda_int <= '0';
                    
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
    -- Generate SCL clock
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_en = '1' then
                if scl_ena = '1' then
                    scl_clk <= not scl_clk;
                else
                    scl_clk <= '1';
                end if;
            end if;
        end if;
    end process;
    
    -- Control SDA output
    process(sda_int)
    begin
        if sda_int = '1' then
            sda_ena_n <= '1';  -- Disable SDA output buffer (high-impedance)
        else
            sda_ena_n <= '0';  -- Enable SDA output buffer
        end if;
    end process;
    
    -- Connect internal signals to outputs
    busy <= busy_int;
    scl <= '0' when (scl_clk = '0' and scl_ena = '1') else 'Z';
    sda <= '0' when sda_ena_n = '0' else 'Z';
    ack_error <= ack_error_int;
    
end Behavioral;