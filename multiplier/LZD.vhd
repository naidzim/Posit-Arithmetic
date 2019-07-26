Library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity lzd is 
	generic(
		N: integer;
		LOG_N: integer
	);
	
	port(
		d_in : in std_logic_vector( N-1 downto 0);
		d_out : out std_logic_vector(N-1 downto 0)
	);
end entity;

architecture estr of lzd is 

	-- components 
	component lod is
		generic(
			N: integer;
			LOG_N: integer
		);	
		port(
			d: in std_logic_vector((N-1) downto 0);
			z: out std_logic_vector((N-1) downto 0)
		);
	end component;
	
	-- signals
	signal inter : std_logic_vector (N-1 downto 0);
	
begin
	inter <= not d_in;
	
	L1D : LOD   generic map(N,LOG_N)   --leading one detector 
				port map( inter, d_out);
end architecture;