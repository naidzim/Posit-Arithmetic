
-- This Barrel-Shifter supports:
--
-- * shifting and rotating
-- * right and left operations
-- * arithmetic and logic mode (only valid for shift operations)

library IEEE;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.NUMERIC_STD.all;



entity arith_shifter_barrel is
	generic (
		N				: integer;
		LOG_N				: integer
	);
  port (
		Input						: in	std_logic_vector(N - 1 downto 0);
		ShiftAmount			: in	std_logic_vector(LOG_N - 1 downto 0);
		ShiftRotate			: in	std_logic; -- 0:shift 1:rotate
		LeftRight				: in	std_logic; -- 0:left 1:right
		ArithmeticLogic	: in	std_logic;
		Output					: out	std_logic_vector(N - 1 downto 0)
	);
end entity;


architecture rtl of arith_shifter_barrel is
	constant STAGES		: integer		:= LOG_N;

	subtype	T_INTERMEDIATE_RESULT is std_logic_vector(N - 1 downto 0);
	type		T_INTERMEDIATE_VECTOR is array (natural range <>) of T_INTERMEDIATE_RESULT;

	signal IntermediateResults	: T_INTERMEDIATE_VECTOR(STAGES downto 0);

begin
	IntermediateResults(0)	<= Input;
	Output									<= IntermediateResults(STAGES);

	genStage : for i in 0 to STAGES - 1 generate
		process(IntermediateResults(i), ShiftRotate, LeftRight, ArithmeticLogic, ShiftAmount)
		begin
			if (ShiftAmount(i) = '0') then
				IntermediateResults(i + 1) <= IntermediateResults(i);																																														-- NOP
			else
				if (ShiftRotate = '0') then
					if (LeftRight = '0') then
						IntermediateResults(i + 1) <= IntermediateResults(i)((N - 2**i - 1) downto 0) & ((2**i - 1) downto 0 => '0');														-- SLA, SLL
					else
						if (ArithmeticLogic = '0') then
							IntermediateResults(i + 1) <= ((2**i - 1) downto 0 => IntermediateResults(i)(N - 1)) & IntermediateResults(i)(N - 1 downto 2**i);		-- SRA
						else
							IntermediateResults(i + 1) <= ((2**i - 1) downto 0 => '0') & IntermediateResults(i)(N - 1 downto 2**i);																-- SRL
						end if;
					end if;
				else
					if (LeftRight = '0') then
						IntermediateResults(i + 1) <= IntermediateResults(i)((N - 2**i - 1) downto 0) & IntermediateResults(i)(N - 1 downto (N - 2**i));		-- RL
					else
						IntermediateResults(i + 1) <= IntermediateResults(i)((2**i - 1) downto 0) & IntermediateResults(i)(N - 1 downto 2**i);						-- RR
					end if;
				end if;
			end if;
		end process;
	end generate;
end;