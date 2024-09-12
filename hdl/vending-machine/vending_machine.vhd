library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity vending_machine is
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		nickel : in std_ulogic;
		dime : in std_ulogic;
		dispense : out std_ulogic;
		amount : out natural range 0 to 15
	);
end entity vending_machine;

architecture arch of vending_machine is

	type vending_state is (zero, five, ten, fifteen);
	signal state : vending_state;

begin
	
	state_logic : process(clk, rst)
	begin
		if rst = '1' then
			state <= zero;
		elsif rising_edge(clk) then
			case state is
				when zero =>
					state <= ten when dime = '1' else
						 five when nickel = '1' else
						 zero;
				when five =>
					state <= fifteen when dime = '1' else
						 ten when nickel = '1' else
						 five;
				when ten =>
					state <= fifteen when dime = '1' else
						 fifteen when nickel = '1' else
						 ten;
				when fifteen =>
					state <= zero;
				when others =>
					state <= zero;
			end case;
		end if;
	end process state_logic;

	output_logic : process(state, nickel, dime)
	begin
		case state is
			when zero =>
				dispense <= '0';
				amount <= 0;
			when five =>
				dispense <= '0';
				amount <= 5;
			when ten =>
				dispense <= '0';
				amount <= 10;
			when fifteen =>
				dispense <= '1';
				amount <= 15;
			when others =>
				dispense <= '0';
				amount <= 0;
		end case;
	end process output_logic;
end architecture arch;
