library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mc6821_par is
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        rs          : in  std_logic;  							
        data_in     : in  std_logic_vector(7 downto 0);  
        data_out    : out std_logic_vector(7 downto 0); 
        rw          : in  std_logic;                 
        cs_n        : in  std_logic;
        port_in     : in  std_logic_vector(7 downto 0);  
        port_out    : out std_logic_vector(7 downto 0);  
        ddr         : out std_logic_vector(7 downto 0);
        cr          : out std_logic_vector(7 downto 0);
		  irq1_flag   : in  std_logic;
		  irq2_flag   : in  std_logic
    );
end entity mc6821_par;

architecture rtl of mc6821_par is
    signal ddr_reg      : std_logic_vector(7 downto 0) := (others => '0'); 
    signal output_reg   : std_logic_vector(7 downto 0); 
    signal cr_reg       : std_logic_vector(7 downto 0); 
    
    signal port_read    : std_logic_vector(7 downto 0);
    
begin
    ddr <= ddr_reg;    -- expose ddr for debug / extension
    cr <= cr_reg;      -- expose cd  for debug / extension    
	 
    port_out <= output_reg;
    
    read_mux: process(ddr_reg, output_reg, port_in)
    begin
        for i in 0 to 7 loop
            if ddr_reg(i) = '0' then
                port_read(i) <= port_in(i);
            else
                port_read(i) <= output_reg(i);
            end if;
        end loop;
    end process;
    
    -- Main register process
    reg_process: process(clk, reset_n)
    begin
        if reset_n = '0' then
            ddr_reg    <= (others => '0');
            output_reg <= (others => '0');
            cr_reg     <= (others => '0');
        elsif rising_edge(clk) then
            if cs_n = '0' then
                if rw = '0' then
                    case rs is
                        when '0' =>
                            if cr_reg(2) = '0' then
                                ddr_reg <= data_in;
                            else
                                output_reg <= data_in;
                            end if;
                        when '1' =>
                            cr_reg <= data_in;
                        when others =>
                            null;
                    end case;
                elsif rw = '1' then
                    case rs is
                        when '0' =>
                            if cr_reg(2) = '1' then
                            end if;
                        when others =>
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    output_mux: process(rs, cs_n, rw, cr_reg, ddr_reg, output_reg, port_read, irq1_flag, irq2_flag)
    begin
        data_out <= (others => '0');
        
        if cs_n = '0' and rw = '1' then
            case rs is
                when '0' =>
                    if cr_reg(2) = '0' then
                        data_out <= ddr_reg;
                    else
                        data_out <= port_read;  
                    end if;
                when '1' =>  
                    data_out <= irq1_flag & irq2_flag & cr_reg(5 downto 0);
                when others =>
                    data_out <= (others => '0');
            end case;
        end if;
    end process;
    
end architecture rtl;