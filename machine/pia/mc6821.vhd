library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mc6821 is
    port (
        -- Clock and reset
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        rs          : in  std_logic_vector(1 downto 0);  -- Register Select 
        data_in     : in  std_logic_vector(7 downto 0); 
        data_out    : out std_logic_vector(7 downto 0); 
        rw          : in  std_logic;              
        cs_n        : in  std_logic;                     -- Chip select
        
        -- Port A interface
        pa_in       : in  std_logic_vector(7 downto 0);  -- Port A inputs
        pa_out      : out std_logic_vector(7 downto 0);  -- Port A outputs
		  ca1         : in  std_logic;
		  ca2_in      : in  std_logic;
		  ca2_out     : out std_logic;
		  ca2_oe      : out std_logic;
		  irqa_n      : out std_logic;
        
        -- Port B interface
        pb_in       : in  std_logic_vector(7 downto 0);  -- Port B inputs
        pb_out      : out std_logic_vector(7 downto 0);  -- Port B outputs
		  cb1         : in  std_logic;
		  cb2_in      : in  std_logic;
		  cb2_out     : out std_logic;
		  cb2_oe      : out std_logic;
		  irqb_n      : out std_logic;
        
        -- Direct register access (for external monitoring/control)
        ddra        : out std_logic_vector(7 downto 0);  -- Data Direction Register A
        ddrb        : out std_logic_vector(7 downto 0)   -- Data Direction Register B
    );
end entity mc6821;

architecture rtl of mc6821 is

    component mc6821_par is
        port (
            -- Clock and reset
            clk         : in  std_logic;
            reset_n     : in  std_logic;
            rs          : in  std_logic;
            data_in     : in  std_logic_vector(7 downto 0);  
            data_out    : out std_logic_vector(7 downto 0); 
            rw          : in  std_logic;                    
            cs_n        : in  std_logic;                    
            
            -- External interface (8-bit separated input/output ports)
            port_in     : in  std_logic_vector(7 downto 0);  -- Port inputs
            port_out    : out std_logic_vector(7 downto 0);  -- Port outputs
            
            -- Direct register access (for external monitoring/control)
            ddr         : out std_logic_vector(7 downto 0);  -- Data Direction Register
            cr          : out std_logic_vector(7 downto 0);  -- Control Register
				irq1_flag   : in  std_logic;
				irq2_flag   : in  std_logic
        );
    end component;
	 
	 component mc6821_ctl is
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
	end component;
	 
    
    -- Chip select signals for the individual ports
    signal cs_pa_n : std_logic;
    signal cs_pb_n : std_logic;
    
    -- Data output from each port
    signal data_out_pa : std_logic_vector(7 downto 0);
    signal data_out_pb : std_logic_vector(7 downto 0);
    
	 signal cr_a   : std_logic_vector(7 downto 0);
	 signal cr_b   : std_logic_vector(7 downto 0);
	 
	 signal data_read_a   : std_logic;
	 signal data_write_a  : std_logic;
	 signal data_read_b   : std_logic;
	 signal data_write_b  : std_logic;
	 
	 signal irq1_flag_a   : std_logic;
	 signal irq2_flag_a   : std_logic;
	 signal irq1_flag_b   : std_logic;
	 signal irq2_flag_b   : std_logic;
	 
	 
	 signal clr_a_n       : std_logic;
	 signal clr_b_n       : std_logic;
	 signal set_a_n       : std_logic;
	 signal set_b_n       : std_logic;

  begin
    -- Decode the register select and chip select for each port
    cs_pa_n <= '0' when cs_n = '0' and rs(1) = '0' else '1';
    cs_pb_n <= '0' when cs_n = '0' and rs(1) = '1' else '1';
	 
	 clr_a_n <= '0' when cs_n = '0' and rs = "00" and rw = '1' else '1';
	 clr_b_n <= '0' when cs_n = '0' and rs = "10" and rw = '1' else '1';
	
	 set_a_n <= '0' when cs_n = '0' and rs(1) = '0' and rs(0) = '0' and (rw = '1')  else '1'; 
	 set_b_n <= '0' when cs_n = '0' and rs(1) = '1' and rs(0) = '0' and (rw = '0')  else '1'; 
    	
    port_a: mc6821_par 		port map(clk        => clk,
												reset_n    => reset_n,
												cs_n       => cs_pa_n,
												rw         => rw,
												rs         => rs(0),
												data_in    => data_in,
												data_out   => data_out_pa,
												port_in    => pa_in,
												port_out   => pa_out,
												ddr        => ddra,
												cr         => cr_a,
												irq1_flag  => irq1_flag_a,
												irq2_flag  => irq2_flag_a);
    
    port_b: mc6821_par       port map(clk        => clk,
												reset_n    => reset_n,
												cs_n       => cs_pb_n,
												rw         => rw,		
												rs         => rs(0),
												data_in    => data_in,
												data_out   => data_out_pb,
												port_in    => pb_in,
												port_out   => pb_out,
												ddr        => ddrb,
												cr         => cr_b,
												irq1_flag  => irq1_flag_b,
												irq2_flag  => irq2_flag_b);
    
	ctrl_a: mc6821_ctl   generic map(PORT_NAME  => "A") 
								   port map(clk        => clk,
												reset_n    => reset_n,
												clr_n      => clr_a_n,
												set_n      => set_a_n,
												cr         => cr_a,
												c1         => ca1,
												c2_in      => ca2_in,
												c2_out     => ca2_out,
												c2_oe      => ca2_oe,
												irq_n      => irqa_n,
												irq1_flag  => irq1_flag_a,
												irq2_flag  => irq2_flag_a);

	ctrl_b: mc6821_ctl   generic map(PORT_NAME  => "B")
								   port map(clk        => clk,
												reset_n    => reset_n,
												clr_n      => clr_b_n,
												set_n      => set_b_n,
												cr         => cr_b,
												c1         => cb1,
												c2_in      => cb2_in,
												c2_out     => cb2_out,
												c2_oe      => cb2_oe,
												irq_n      => irqb_n,
												irq1_flag  => irq1_flag_b,
												irq2_flag  => irq2_flag_b);

    
    data_out <= data_out_pa when rs(1) = '0' else 
                data_out_pb when rs(1) = '1' else
                (others => '0');
end architecture rtl;