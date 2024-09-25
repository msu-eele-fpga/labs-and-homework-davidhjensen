library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_gen_tb is
end entity clock_gen_tb;

architecture testbench of clock_gen_tb is

  constant CLK_PERIOD : time := 20 ns;

  component clock_gen is
    generic (
      sys_clk_period : time
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
  end component clock_gen;

  signal clk_tb       : std_ulogic := '0';
  signal rst_tb       : std_ulogic := '0';
  signal base_rate_tb : unsigned(7 downto 0) := "00010000";
  signal div_1_tb     : std_ulogic;
  signal div_2_tb     : std_ulogic;
  signal div_4_tb     : std_ulogic;
  signal div_8_tb     : std_ulogic;
  signal mult_2_tb    : std_ulogic;
  signal mult_4_tb    : std_ulogic;

begin

  dut : component clock_gen
    generic map
    (
      sys_clk_period => CLK_PERIOD
    )
    port map
    (
      sys_clk   => clk_tb,
      rst       => rst_tb,
      base_rate => base_rate_tb,
      div_1     => div_1_tb,
      div_2     => div_2_tb,
      div_4     => div_4_tb,
      div_8     => div_8_tb,
      mult_2    => mult_2_tb,
      mult_4    => mult_4_tb
    );

    clk_gen : process is
    begin
      clk_tb <= not clk_tb;
      wait for CLK_PERIOD / 2;
    end process clk_gen;

    stim : process is
    begin
        rst_tb <= '1';
        wait for 2*CLK_PERIOD;
        base_rate_tb <= "00000001";
        rst_tb <= '0';
        wait;
    end process stim;

end architecture testbench;
