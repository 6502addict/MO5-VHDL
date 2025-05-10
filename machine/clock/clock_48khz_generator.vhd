library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_48khz_generator is
    Port (
        clk_24mhz   : in  STD_LOGIC;  -- Input 24MHz clock
        reset_n     : in  STD_LOGIC;  -- Active low reset
        clk_48khz   : out STD_LOGIC   -- Output 48kHz clock
    );
end clock_48khz_generator;

architecture Behavioral of clock_48khz_generator is
    -- For 24MHz: 24,000,000 / 48,000 = 500 exactly
    constant DIV_VALUE : integer := 500;
    constant HALF_DIV  : integer := 250;
    
    -- Counter for division (9 bits can count to 512, more than enough for our divisor of 500)
    signal counter : unsigned(8 downto 0) := (others => '0');
    
    -- Output clock signal
    signal clk_out : STD_LOGIC := '0';
    
begin
    -- Clock divider process
    DIV_PROC: process(clk_24mhz, reset_n)
    begin
        if reset_n = '0' then
            counter <= (others => '0');
            clk_out <= '0';
        elsif rising_edge(clk_24mhz) then
            if counter = DIV_VALUE - 1 then
                counter <= (others => '0');
                clk_out <= '0';
            elsif counter = HALF_DIV - 1 then
                counter <= counter + 1;
                clk_out <= '1';
            else
                counter <= counter + 1;
            end if;
        end if;
    end process DIV_PROC;
    
    -- Assign output clock
    clk_48khz <= clk_out;
    
end Behavioral;