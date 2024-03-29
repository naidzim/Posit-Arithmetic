--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This is a 2to1 multiplexer for one bit
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2to1Simple is
	port(
		x0: in std_logic;
		x1: in std_logic;
		ctrl: in std_logic;
		z: out std_logic
	);
end mux2to1Simple;

architecture estr of mux2to1Simple is

  --Signals
  signal a1: std_logic;
  signal a2: std_logic;

begin
  
  a1 <= x0 and not(ctrl);
  a2 <= x1 and ctrl;
  
  z <= a1 or a2;
    
end estr;