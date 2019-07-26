library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_extract_tb is
end entity;

architecture sim of data_extract_tb is 
constant N: integer := 16;
constant LOG_N: integer := 4;
constant es : integer := 3;

		signal input :  std_logic_vector(N-1 downto 0);
		signal rc:  std_logic;
		signal regime :  std_logic_vector(LOG_N-1 downto 0);
		signal exp : std_logic_vector(es-1 downto 0);
		signal mant :  std_logic_vector(N - es -1 downto 0);
		signal lshift :  std_logic_vector(LOG_N-1 downto 0);
begin 
	UUT : entity work.data_extract(extr)
		  generic map (N,LOG_N,es)
		  port map(input,rc,regime,exp,mant,lshift);
	TEST : process 
		begin 
			input <= "0000110111011101"; wait for 10 ns;
			input <= "0000000000000010"; wait for 10 ns;
			wait;
		end process;
end architecture;
