--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This is a barrel shifter with left shift
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity barrelShifter is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
	  shiftAm: in std_logic_vector((LOG_N-1) downto 0);
	  shX: out std_logic_vector((N-1) downto 0)
	);
end barrelShifter;

architecture estr of barrelShifter is
  
  --Components
  component mux2to1Simple is
	 port(
		  x0: in std_logic;
		  x1: in std_logic;
		  ctrl: in std_logic;
		  z: out std_logic
	 );
  end component;

  --Types
  
  type matrix is array(0 to LOG_N) of std_logic_vector((N-1) downto 0);
  
  --Signals
  
  signal muxMat: matrix;
  signal zero1: std_logic;
  
begin
  
  zero1 <= '0';
  
  --Stage 0
  muxMat(0) <= x;   
   
  --StagesI
  genStagesI:
  for i in 1 to LOG_N generate
     genStageI:
     for j in 0 to (N-1) generate
        ifgenCte:
        if (j < 2**(i-1)) generate
           muxMat(i)(j) <= muxMat(i-1)(j) and not(shiftAm(i-1));
        end generate ifgenCte;
        ifgenSh:
        if (j >= 2**(i-1)) generate
          muxSh: mux2to1Simple port map(muxMat(i-1)(j),muxMat(i-1)(j-2**(i-1)),
              shiftAm(i-1),muxMat(i)(j));  
        end generate ifgenSh;
     end generate genStageI;
  end generate genStagesI;
  
  shX <= muxMat(LOG_N);
  
end estr;