Library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity LZD_tb is 
end entity;

architecture tb of LZD_tb is
	signal d_in :  std_logic_vector (7 downto 0);
	signal d_out:  std_logic_vector(7 downto 0);
	
begin 
	UUT: entity work.LZD(estr)
		 generic map (8,3)
		 port map (d_in,d_out);
	TEST : process
			begin 
			   d_in <= "11101111"; wait for 5 ns;
			   d_in <= "00001111"; wait for 5 ns;
			   d_in <= "10001111"; wait for 5 ns;
			   d_in <= "11001011"; wait for 5 ns;
			   wait;
			end process;
end architecture;
		   