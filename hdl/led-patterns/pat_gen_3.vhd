library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity pat_gen_3 is
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    LED : out std_ulogic_vector(6 downto 0)
  );
end entity pat_gen_3;

architecture arch of pat_gen_3 is

  signal count : integer range 0 to 127 := 127;

begin

  LED_6to0 : process (rst, clk)
  begin
    if (rst = '1') then
      count <= 127;
      LED   <= "1111111";
    elsif (rising_edge(clk)) then
      if (count > 0) then
        count <= count - 1;
        LED   <= std_ulogic_vector(to_unsigned(count, 7));
      else
        count <= 127;
      end if;
    end if;
  end process LED_6to0;

end architecture arch;