library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity pat_gen_4 is
  port
  (
    clk_div4  : in std_ulogic;
    clk_mult4 : in std_ulogic;
    rst       : in std_ulogic;
    LED       : out std_ulogic_vector(6 downto 0)
  );
end entity pat_gen_4;

architecture arch of pat_gen_4 is

  signal internal_left : std_ulogic_vector(6 downto 0) := "0000001";
  signal internal_right : std_ulogic_vector(6 downto 0) := "1000000";

begin

  LED_RIGHT : process (rst, clk_div4)
  begin
    if (rst = '1') then
      internal_right <= "1000000";
    elsif (rising_edge(clk_div4)) then
      internal_right <= internal_right(0) & internal_right(6 downto 1);
    end if;
  end process LED_RIGHT;

  LED_LEFT : process (rst, clk_mult4)
  begin
    if (rst = '1') then
      internal_left <= "0000001";
    elsif (rising_edge(clk_mult4)) then
      internal_left <= internal_left(5 downto 0) & internal_left(6);
    end if;
  end process LED_LEFT;

  COMB_LED : process(rst, clk_div4)
  begin
    if (rst = '1') then
      LED <= "0000000";
    elsif (rising_edge(clk_div4)) then
      LED <= internal_left or internal_right;
    end if;
  end process COMB_LED;

end architecture arch;