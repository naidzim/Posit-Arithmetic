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
	
	component arith_shifter_barrel is
		generic (
			N				: integer;
			LOG_N				: integer
		);
	  port (
			Input			: in	std_logic_vector(N - 1 downto 0);
			ShiftAmount		: in	std_logic_vector(LOG_N - 1 downto 0);
			ShiftRotate		: in	std_logic; -- 0:shift 1:rotate
			LeftRight		: in	std_logic; -- 0:left 1:right
			ArithmeticLogic	: in	std_logic;
			Output			: out	std_logic_vector(N - 1 downto 0)
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
	
	-- repeat bit value
	function repeat(N: natural; B: std_logic) return std_logic_vector is
		variable result: std_logic_vector(1 to N);
	begin
		for i in 1 to N loop
			result(i) := B;
		end loop;
		return result;
	end function;
	   
	   
	

	signal zero1: std_logic;
	signal zero2: std_logic;
	signal zero_inter : std_logic;
	
	signal inf1 : std_logic;
	signal inf2 : std_logic;
	signal inf_inter : std_logic; -- to be used in final output
	
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
	signal mult_mN : std_logic_vector (2*(N-es) +1 downto 0);
	
	signal r1 : std_logic_vector (LOG_N+1 downto 0);
	signal r2 : std_logic_vector (LOG_N+1 downto 0);
	signal mult_e : std_logic_vector (LOG_N + es + 1 downto 0);
	signal mult_eN : std_logic_vector (LOG_N + es + 1 downto 0);
	
	signal e_o : std_logic_vector (es - 1 downto 0);
	signal r_o : std_logic_vector (LOG_N downto 0);
	signal tmp_o : std_logic_vector(2*N - 1 downto 0);
	signal tmp1_o : std_logic_vector (2*N - 1 downto 0);
	signal tmp1_oN : std_logic_vector (2*N - 1 downto 0);
	
	signal output_z : std_logic_vector (N-2 downto 0) := (others => '0');
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
	
	zero_inter <= zero1 and zero2;
	zero <= zero_inter;
	inf_inter <= inf1 or inf2; 
	inf <= inf_inter;
	
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
mult_m <= std_logic_vector( unsigned(m1) * unsigned(m2) );
mult_m_ovf <= mult_m(2 * (N-es) +1);  --overflow test

mult_mN <= mult_m when mult_m_ovf = '1' 
		   else mult_m(2*(N-es) downto 0) & '0';-- 1 bit left shift


r1 <= "00" & regime1 when rc1 = '1'
	else "00" & std_logic_vector( unsigned(not regime1) + 1); --2's complement
r2 <= "00" & regime2 when rc2 = '1'
	else "00" & std_logic_vector( unsigned(not regime2) + 1); --2's complement
	
mult_e <= std_logic_vector( signed(r1 & e1) + signed(r2 & e2) + to_signed(1,LOG_N+es+1) ) when mult_m_ovf = '1'
			else std_logic_vector( unsigned(r1 & e1) + unsigned(r2 & e2) );

-- exponent and regime computation 
mult_eN <= mult_e when  mult_e( LOG_N + es + 1) = '0' else	
			std_logic_vector( unsigned(not mult_e) + 1); --2's complement
			
e_o <= mult_e(es-1 downto 0) when ( mult_e(es+LOG_N+1) and or_br(mult_eN(es-1 downto 0))) = '1'
		else mult_eN(es-1 downto 0);
		
r_o <= std_logic_vector( unsigned( mult_eN(LOG_N+es downto es) ) + 1)   when ( (not mult_e(LOG_N + es + 1)) or ( mult_e(LOG_N + es + 1) and or_br(mult_eN(es-1 downto 0)) ) ) = '1'
		else mult_eN( LOG_N + es downto es);

-- Exponent and mantissa packing 
tmp_o <= repeat(N,not mult_e(LOG_N+es+1)) & mult_e(LOG_N+es+1) & e_o & mult_mN(2*(N-es) downto N-es + 2);

-- including regime bits in exponent and mantissa packing
right_shifting : arith_shifter_barrel generic map(2*N, LOG_N+1) 
					   port map (tmp_o, r_o,'0','1','0',tmp1_o);
-- final output

tmp1_oN <= tmp1_o when mult_s = '0' else 
		 std_logic_vector( unsigned(not tmp1_o) + 1);

sout <= (inf_inter & output_z ) when (inf_inter or zero_inter or (not mult_mN(2*(N-es)+1))) = '1' 
		else mult_s & tmp1_oN(N-1 downto 1);
		
		
end architecture;