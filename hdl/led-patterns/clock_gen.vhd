library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity clock_gen is
  generic (
    sys_clk_period : time := 20 ns
  );
  port (
    sys_clk   : in std_ulogic;
    rst       : in std_ulogic;
    base_rate : in unsigned(7 downto 0);
    div_1     : out std_ulogic;
    div_2     : out std_ulogic;
    div_4     : out std_ulogic;
    div_8     : out std_ulogic;
    mult_2    : out std_ulogic;
    mult_4    : out std_ulogic
  );
end entity clock_gen;

architecture arch of clock_gen is

  -- constant to multiply 8.4 (N.i) by 50 million
  -- it is 50,000,000 converted to binary
  -- shifted right 4 to account for the decimal multiplication
  -- shifted right 1 to have each clock flip half way through the period
  constant MULT_50MIL_SHIFTED : unsigned := "101111101011110000100";

  -- max values for counts (half of period)
  signal max_div_1  : unsigned(28 downto 0);
  signal max_div_2  : unsigned(28 downto 0);
  signal max_div_4  : unsigned(28 downto 0);
  signal max_div_8  : unsigned(28 downto 0);
  signal max_mult_2 : unsigned(29 downto 0);
  signal max_mult_4 : unsigned(30 downto 0);

  -- counts
  signal cnt_div_1  : integer := 0;
  signal cnt_div_2  : integer := 0;
  signal cnt_div_4  : integer := 0;
  signal cnt_div_8  : integer := 0;
  signal cnt_mult_2 : integer := 0;
  signal cnt_mult_4 : integer := 0;

  -- clocks
  signal internal_div_1 : std_ulogic := '0';
  signal internal_div_2 : std_ulogic := '0';
  signal internal_div_4 : std_ulogic := '0';
  signal internal_div_8 : std_ulogic := '0';
  signal internal_mult_2 : std_ulogic := '0';
  signal internal_mult_4 : std_ulogic := '0';

begin

  COUNT_SETTER : process(sys_clk)
  begin
    -- be better
    max_div_1  <= base_rate * MULT_50MIL_SHIFTED;
    max_div_2  <= shift_right(base_rate * MULT_50MIL_SHIFTED, 1);
    max_div_4  <= shift_right(base_rate * MULT_50MIL_SHIFTED, 2);
    max_div_8  <= shift_right(base_rate * MULT_50MIL_SHIFTED, 3);
    max_mult_2 <= (base_rate * MULT_50MIL_SHIFTED) & "0";
    max_mult_4 <= (base_rate * MULT_50MIL_SHIFTED) & "00";
  end process COUNT_SETTER;

  DIV_1_CLK : process(rst, sys_clk)
  begin
    if(rst = '1') then
      internal_div_1 <= '0';
      cnt_div_1 <= 0;
    elsif(rising_edge(sys_clk)) then
      if(cnt_div_1 < to_integer(max_div_1)) then
        cnt_div_1 <= cnt_div_1 + 1;
      else
        cnt_div_1 <= 0;
        internal_div_1 <= not internal_div_1;
      end if;
    end if;
  end process DIV_1_CLK;
  div_1 <= internal_div_1;

  DIV_2_CLK : process(rst, sys_clk)
  begin
    if(rst = '1') then
      internal_div_2 <= '0';
      cnt_div_2 <= 0;
    elsif(rising_edge(sys_clk)) then
      if(cnt_div_2 < to_integer(max_div_2)) then
        cnt_div_2 <= cnt_div_2 + 1;
      else
        cnt_div_2 <= 0;
        internal_div_2 <= not internal_div_2;
      end if;
    end if;
  end process DIV_2_CLK;
  div_2 <= internal_div_2;

  DIV_4_CLK : process(rst, sys_clk)
  begin
    if(rst = '1') then
      internal_div_4 <= '0';
      cnt_div_4 <= 0;
    elsif(rising_edge(sys_clk)) then
      if(cnt_div_4 < to_integer(max_div_4)) then
        cnt_div_4 <= cnt_div_4 + 1;
      else
        cnt_div_4 <= 0;
        internal_div_4 <= not internal_div_4;
      end if;
    end if;
  end process DIV_4_CLK;
  div_4 <= internal_div_4;

  DIV_8_CLK : process(rst, sys_clk)
  begin
    if(rst = '1') then
      internal_div_8 <= '0';
      cnt_div_8 <= 0;
    elsif(rising_edge(sys_clk)) then
      if(cnt_div_8 < to_integer(max_div_8)) then
        cnt_div_8 <= cnt_div_8 + 1;
      else
        cnt_div_8 <= 0;
        internal_div_8 <= not internal_div_8;
      end if;
    end if;
  end process DIV_8_CLK;
  div_8 <= internal_div_8;

  MULT_2_CLK : process(rst, sys_clk)
  begin
    if(rst = '1') then
      internal_mult_2 <= '0';
      cnt_mult_2 <= 0;
    elsif(rising_edge(sys_clk)) then
      if(cnt_mult_2 < to_integer(max_mult_2)) then
        cnt_mult_2 <= cnt_mult_2 + 1;
      else
        cnt_mult_2 <= 0;
        internal_mult_2 <= not internal_mult_2;
      end if;
    end if;
  end process MULT_2_CLK;
  mult_2 <= internal_mult_2;

  MULT_4_CLK : process(rst, sys_clk)
  begin
    if(rst = '1') then
      internal_mult_4 <= '0';
      cnt_mult_4 <= 0;
    elsif(rising_edge(sys_clk)) then
      if(cnt_mult_4 < to_integer(max_mult_4)) then
        cnt_mult_4 <= cnt_mult_4 + 1;
      else
        cnt_mult_4 <= 0;
        internal_mult_4 <= not internal_mult_4;
      end if;
    end if;
  end process MULT_4_CLK;
  mult_4 <= internal_mult_4;

end architecture arch;