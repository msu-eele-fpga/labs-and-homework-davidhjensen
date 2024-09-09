library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;


entity timed_counter is

generic (
	clk_period : time;
	count_time : time
);

port (
	clk	: in	std_ulogic;
	enable	: in	boolean;
	done	: out	boolean
);

end entity timed_counter;

architecture timed_counter_arch of timed_counter is

	constant COUNTER_LIMIT : natural := ((count_time/clk_period));
	
	signal count : natural range 0 to COUNTER_LIMIT := 0;

begin

-- counter starts at zero to get full timer length
-- counter resets to 1 so that clock period while done is asserted is counted
-- counter resets to zero when it is killed
COUNTER: process(clk)

	begin

		if(rising_edge(clk)) then
			if(enable) then

				if(count < COUNTER_LIMIT) then
					count <= count + 1;
					done <= false;
				else
					count <= 1;
					done <= true;
				end if;
			else
				count <= 0;
				done <= false;
			end if;
		end if;

end process COUNTER;

end architecture timed_counter_arch;
