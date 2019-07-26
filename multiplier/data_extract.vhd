Library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity data_extract is
	generic (
			N : integer range 0 to 16 ;
			LOG_N: integer ;
			es: integer  
		);
	port( 
		-- INPUTS
		input : in std_logic_vector(N -1 downto 0);
		-- OUTPUTS
		rc: out std_logic;
		regime : out std_logic_vector(LOG_N -1 downto 0);
		exp : out std_logic_vector(es-1 downto 0);
		mant : out std_logic_vector(N - es -1 downto 0);
		lshift : out std_logic_vector((LOG_N -1) downto 0)
	);
end entity;

architecture extr of data_extract is

-- COMPONENTS 
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
	
	component lzd is 
		generic(
			N: integer;
			LOG_N: integer
		);
		
		port(
			d_in : in std_logic_vector( N-1 downto 0);
			d_out : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
component barrelShifter is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
	  shiftAm: in std_logic_vector((LOG_N-1) downto 0);
	  shX: out std_logic_vector((N-1) downto 0)
	);
end component;

component encoder is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
		enc: out std_logic_vector((LOG_N-1) downto 0)
	);
end component;


-- SIGNALS
	signal xin : std_logic_vector(N -1 downto 0);
	signal xin_cat0 :std_logic_vector(N -1 downto 0);
	signal xin_cat1 :std_logic_vector(N -1 downto 0);
	signal xin_tmp : std_logic_vector(N -1 downto 0);
	
	signal k0 : std_logic_vector(LOG_N-1  downto 0);
	signal k0_tmp : std_logic_vector(N -1 downto 0);
	
	
	signal k1 : std_logic_vector(LOG_N-1  downto 0);
	signal k1_tmp : std_logic_vector(N -1 downto 0);
	signal k1_inc : std_logic_vector(LOG_N-1  downto 0);
	
	signal lshift_tmp : std_logic_vector((LOG_N -1) downto 0);
	
	
begin 
	lshift <= lshift_tmp;
	
	xin <= input;
	rc <= xin(N-2);
	xin_cat0 <= xin(N-2 downto 0) & '0';
	xin_cat1 <= xin(N-3 downto 0) & "00";
	
	
	L1D : LOD   generic map(N,LOG_N)   --leading one detector 
				port map( xin_cat0, k0_tmp);
	enc0 : encoder generic map (N,LOG_N)
					port map (k0_tmp,k0);
	
	
	L0D : LZD   generic map(N,LOG_N)   --leading one detector 
				port map( xin_cat1, k1_tmp);
	enc1 : encoder generic map (N,LOG_N)
					port map (k1_tmp,k1);
					
	
	
	k1_inc <= std_logic_vector( unsigned(k1) + 1 );
	

			
	regime <= std_logic_vector(to_unsigned(15,LOG_N) - unsigned (k1)) when xin(N-2) = '1' 
			  else std_logic_vector(to_unsigned(15,LOG_N) - unsigned (k0));
	
	lshift_tmp <= std_logic_vector(to_unsigned(15,LOG_N) - unsigned (k1_inc)) when xin(N-2) = '1' 
				else std_logic_vector(to_unsigned(15,LOG_N) - unsigned (k0));
	
	DS : barrelShifter generic map(N, LOG_N) 
					   port map (xin_cat1, lshift_tmp, xin_tmp);
		
			
	exp <= xin_tmp(N-1 downto N-es);
	mant <= xin_tmp(N - es - 1 downto 0);
	
end architecture;
	