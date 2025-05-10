library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity MO5_CPU IS
	port	(
		cpu_reset_n  : in  std_logic := '1';
		cpu_clk      : in  std_logic;
		address      : out std_logic_vector(15 downto 0);
		data_in      : in  std_logic_vector(7 downto 0);
		data_out     : out std_logic_vector(7 downto 0);
		nmi_n        : in  std_logic;
		irq_n        : in  std_logic;
		firq_n       : in  std_logic;
		vma          : out std_logic;
		rw           : out std_logic;
		halt_n       : in  std_logic
	);
end MO5_CPU;

architecture rtl of MO5_CPU is

component cpu09 is
	port (	
		clk      : in  std_logic;
		rst      : in  std_logic;
		vma      : out std_logic;
		addr     : out std_logic_vector(15 downto 0);
		rw       : out std_logic;
	   data_out : out std_logic_vector(7 downto 0);
	   data_in  : in  std_logic_vector(7 downto 0);
		irq      : in  std_logic;
		firq     : in  std_logic;
		nmi      : in  std_logic;
		halt     : in  std_logic;
		hold     : in  std_logic
		);
end component;

begin

	cp: cpu09				port map(clk      => cpu_clk,
											rst      => not cpu_reset_n,
											vma      => vma,
											addr     => address,
											rw       => rw,
											data_out => data_out,
											data_in  => data_in,
											irq      => not irq_n,
											firq     => not firq_n,
											nmi      => '0',
											halt     => '0',
											hold     => '0');

end rtl;

