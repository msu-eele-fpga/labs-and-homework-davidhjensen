library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity pat_gen_0 is
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    LED : out std_ulogic_vector(6 downto 0)
  );
end entity pat_gen_0;

architecture arch of pat_gen_0 is

  signal internal_led : std_ulogic_vector(6 downto 0) := "0000001";

begin

  LED_6to0 : process (rst, clk)
  begin
    if (rst = '1') then
      internal_led <= "0000001";
    elsif (rising_edge(clk)) then
      internal_led <= internal_led(0) & internal_led(6 downto 1);
    end if;
  end process LED_6to0;

  LED <= internal_led;

end architecture arch;