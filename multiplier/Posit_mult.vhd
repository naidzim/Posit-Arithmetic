Library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	


entity Posit_mult is
	
	generic (
		N : integer;
		LOG_N: integer;
		es: integer
		);	
	port( 
		--INPUTS
			start : in std_logic;
			IN1   : in std_logic_vector (N-1 downto 0);
			IN2   : in std_logic_vector (N-1 downto 0);
		-- OUTPUTS
			sout  : out std_logic_vector (N-1 downto 0);
			inf   : out std_logic;
			zero  : out std_logic;
			rdy   : out std_logic
		);
end Posit_mult;

Architecture multiply of Posit_mult is 


-- compenents : 
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
	
	component data_extract is
		generic (
				N : integer ;
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
	end component;


-- functions
	
	--or bit reduction
	function or_br(bit_in: in std_logic_vector) return std_logic is
		variable res_b : std_logic := '0'; 
	begin
		for i in bit_in'range loop
			res_b := res_b or bit_in(i);
		end loop;
		return res_b;
	end function or_br;
	   
	   
	

	signal zero1: std_logic;
	signal zero2: std_logic;
	
	signal inf1 : std_logic;
	signal inf2 : std_logic;
	
	signal zero_tmp1: std_logic;
	signal zero_tmp2: std_logic;
	
	signal S1 : std_logic;
	signal S2 : std_logic;
	signal temp : std_logic_vector (N-1 downto 0);
	
	signal XIN1 : std_logic_vector (N-1 downto 0);
	signal XIN2 : std_logic_vector (N-1 downto 0);
	
	signal RC1 : std_logic;
	signal RC2 : std_logic;
	
	signal regime1: std_logic_vector(LOG_N -1 downto 0);
	signal regime2: std_logic_vector(LOG_N -1 downto 0);
	signal Lshift1: std_logic_vector(LOG_N -1 downto 0);
	signal Lshift2: std_logic_vector(LOG_N -1 downto 0);
	
	signal e1: std_logic_vector( es-1 downto 0);
	signal e2: std_logic_vector( es-1 downto 0);
	
	signal mant1: std_logic_vector( (N-es-1) downto 0);
	signal mant2: std_logic_vector( (N-es-1) downto 0);

	signal m1 : std_logic_vector ( N-es downto 0);
	signal m2 : std_logic_vector ( N-es downto 0);
	
	signal mult_s :std_logic;
	signal mult_m : std_logic_vector (2*(N-es) +1 downto 0);
	signal mult_m_ovf : std_logic;
	
	signal r1 : std_logic_vector (LOG_N+1 downto 0);
	signal r2 : std_logic_vector (LOG_N+1 downto 0);
	signal mult_e : std_logic_vector (LOG_N + es + 1 downto 0);
begin
--sign bit
	S1 <= IN1(N-1);
	S2 <= IN2(N-1);
	
-- check for zero and infinity 
	zero_tmp1 <= OR_BR( IN1(N-2 DOWNTO 0) );
	zero_tmp2 <= OR_BR( IN2(N-2 DOWNTO 0) );
	
	zero1 <= NOT ( IN1(N - 1) OR zero_tmp1);
    zero2 <= NOT ( IN2(N - 1) OR zero_tmp2);
	
	inf1 <= IN1(N-1) and (not zero_tmp1);
	inf2 <= IN2(N-1) and (not zero_tmp2);
	
	zero <= zero1 and zero2;
	inf <= inf1 or inf2;
	
-- data exctarction
	XIN1 <= IN1 when S1 ='0' 
			else std_logic_vector( unsigned(not IN1) + 1); --2's complement
	XIN2 <= IN2 when S2 ='0' 
			else std_logic_vector( unsigned(not IN2) + 1); --2's complement
		
	extract1 : data_extract generic map(N,LOG_N,es)
							port map(XIN1,rc1,regime1,e1,mant1,Lshift1);
							
	extract2 : data_extract generic map(N,LOG_N,es)
							port map(XIN2,rc2,regime2,e2,mant2,Lshift2);
	
	m1 <= zero_tmp1 & mant1;
	m2 <= zero_tmp2 & mant2;
	
-- Sign, Exponent and Mantissa Computation
mult_s <= s1 xor s2;
mult_m <= std_logic_vector( signed(m1) * signed(m2) );
mult_m_ovf <= mult_m(2 * (N-es) +1);


r1 <= "00" & regime1 when rc1 = '1'
	else std_logic_vector( unsigned(not regime1) + 1); --2's complement
r2 <= "00" & regime2 when rc2 = '1'
	else std_logic_vector( unsigned(not regime2) + 1); --2's complement
	
mult_e <= std_logic_vector( signed(r1 & e1) + signed(r2 & e2) );

-- exponent and regime computation 

	
		
		
end architecture;