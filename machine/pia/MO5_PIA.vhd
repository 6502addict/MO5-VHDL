library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity declaration for MO5_PIA
entity MO5_PIA IS
    port    (
        reset_n      : in  std_logic := '1';
        cpu_clk      : in  std_logic;
        address      : in  std_logic_vector(15 downto 0);
        data_in      : in  std_logic_vector(7 downto 0);
        data_out     : out std_logic_vector(7 downto 0);
        rw           : in  std_logic;
        cs_n         : in  std_logic;
        irq_n        : out std_logic := '1';
        firq_n       : out std_logic := '1';
        border_color : out std_logic_vector(3 downto 0);
        forme        : out std_logic;
        kbd_row      : out std_logic_vector(2 downto 0);
        kbd_col      : out std_logic_vector(2 downto 0);
        kbd_data     : in  std_logic;
        sound        : out std_logic;
        lep_in       : in  std_logic;
        lep_out      : out std_logic;
        lep_mtr      : out std_logic;
        synlt_clock  : in  std_logic;
        lightpen_btn : in std_logic;
        lightpen_sig : in  std_logic;
        incrust      : out std_logic
    );
end MO5_PIA;

-- Architecture for MO5_PIA
architecture rtl of MO5_PIA is
component mc6821 is
    port (
        -- Clock and reset
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        rs          : in  std_logic_vector(1 downto 0);  
        data_in     : in  std_logic_vector(7 downto 0); 
        data_out    : out std_logic_vector(7 downto 0);  
        rw          : in  std_logic;                    
        cs_n        : in  std_logic;         
        
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
end component;

    -- Port A interface signals
    signal pa_in             : std_logic_vector(7 downto 0);
    signal pa_out            : std_logic_vector(7 downto 0);
    signal ddra              : std_logic_vector(7 downto 0);
    signal cra               : std_logic_vector(7 downto 0);
    -- Port B interface signals
    signal pb_in             : std_logic_vector(7 downto 0);
    signal pb_out            : std_logic_vector(7 downto 0);
    signal ddrb              : std_logic_vector(7 downto 0);
    signal crb               : std_logic_vector(7 downto 0);

	 signal ca2_in            : std_logic := '0';
	 signal ca2_out           : std_logic;
	 signal ca2_oe            : std_logic;
	 signal cb2_in            : std_logic := '0';
	 signal cb2_out           : std_logic;
	 signal cb2_oe            : std_logic;
	 
	 signal rs                : std_logic_vector(1 downto 0);
    
begin
	
    pia_inst: mc6821    port map (clk         => cpu_clk,
											 reset_n     => reset_n,
											 cs_n        => cs_n,
                                  rw          => rw,
                                  rs          => rs,
                                  data_in     => data_in,
                                  data_out    => data_out,
		                            pa_in       => pa_in,
		                            pa_out      => pa_out,
								 		    ca1         => '1', --lightpen_sig,
		                            ca2_in      => ca2_in,
   		                         ca2_out     => ca2_out,
		                            ca2_oe      => ca2_oe,
		                            irqa_n      => firq_n,
		                            pb_in       => pb_in,
		                            pb_out      => pb_out,
								 		    cb1         => synlt_clock,
		                            cb2_in      => cb2_in,
   		                         cb2_out     => cb2_out,
		                            cb2_oe      => cb2_oe,
		                            irqb_n      => irq_n,
		                            ddra        => ddra,
		                            ddrb        => ddrb);

   -- it's not an error ont he thomson these fucking lines are inverted
   rs(0) <= address(1);
	rs(1) <= address(0);
    
	-- PORT A
	ca2_in            <= '0';
	pa_in(0)          <= '0';  
   pa_in(4 downto 1) <= (others => '0');  
   pa_in(5)          <= lightpen_btn;
   pa_in(6)          <= '0';  
   pa_in(7)          <= lep_in;
   forme             <= pa_out(0)          when ddra(0)          = '1'    else '0';
   border_color      <= pa_out(4 downto 1) when ddra(4 downto 1) = "1111" else (others => '0');
   lep_out           <= pa_out(6)          when ddra(6)          = '1'    else '0';
   lep_mtr           <= ca2_out when ca2_oe = '1' else '0';

	-- PORT B
	cb2_in            <= '0';
	pb_in(0)          <= '0';  
   pb_in(3 downto 1) <= (others => '0');  
   pb_in(6 downto 4) <= (others => '0'); 
   pb_in(7)          <= kbd_data;
   sound             <= pb_out(0)          when ddrb(0)          = '1'   else '0';
   kbd_row           <= pb_out(3 downto 1) when ddrb(3 downto 1) = "111" else (others => '0');
   kbd_col           <= pb_out(6 downto 4) when ddrb(6 downto 4) = "111" else (others => '0');
   incrust           <= cb2_out when cb2_oe = '1' else '0';
	

end architecture rtl;