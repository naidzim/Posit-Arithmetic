library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LOD_tb is
end entity;

architecture sim of LOD_tb is 
		signal d:  std_logic_vector(7 downto 0);
		signal z:  std_logic_vector(7 downto 0);
begin 
	UUT : entity work.LOD(estr)
		  generic map(8,3)
		  port map (d,z);
	
	TEST : process
		 begin
			d <= "00000000"; wait for 10 ns;
			d <= "11111111"; wait for 10 ns;
			d <= "00111000"; wait for 10 ns;
			d <= "00000001"; wait for 10 ns;
			wait;
		end process;
end architecture;