library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_tb is
end entity;

architecture sim of encoder_tb is 
		signal x:  std_logic_vector(7 downto 0);
		signal enc:  std_logic_vector(2 downto 0);
begin 
	UUT : entity work.encoder(estr)
		  generic map(8,3)
		  port map (x,enc);
	
	TEST : process
		 begin
			x <= "10000000"; wait for 10 ns;
			x <= "00001000"; wait for 10 ns;
			x <= "11111111"; wait for 10 ns;
			x <= "00000001"; wait for 10 ns;
			wait;
		end process;
end architecture;