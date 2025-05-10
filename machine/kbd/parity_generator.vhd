library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity parity_generator is
    Port ( 
        input     : in  std_logic_vector(8 downto 0) := "000000000";
        even      : out std_logic;                
        odd       : out std_logic               
    );
end parity_generator;

architecture Behavioral of parity_generator is
    signal parity : std_logic;
begin
    process(input)
        variable t : std_logic;
    begin
        t := '0';
        for i in 0 to 8 loop
            t := t xor input(i);
        end loop;
        parity <= t;
    end process;

    even <= not parity;  
    odd  <=     parity;  

end Behavioral;