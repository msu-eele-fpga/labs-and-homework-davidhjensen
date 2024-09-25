library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pat_gen_4_tb is
end entity pat_gen_4_tb;

architecture testbench of pat_gen_4_tb is

  constant CLK_PERIOD : time := 20 ns;

  component pat_gen_4 is
    port (
      clk_div4  : in std_ulogic;
      clk_mult4 : in std_ulogic;
      rst       : in std_ulogic;
      LED       : out std_ulogic_vector(6 downto 0)
    );
  end component pat_gen_4;

  signal clk_div4_tb  : std_ulogic := '0';
  signal clk_mult4_tb : std_ulogic := '0';
  signal rst_tb       : std_ulogic := '0';
  signal LED_tb       : std_ulogic_vector(6 downto 0);

begin

  dut : component pat_gen_4
    port map
    (
      clk_div4  => clk_div4_tb,
      clk_mult4 => clk_mult4_tb,
      rst       => rst_tb,
      LED       => LED_tb
    );

    clk_div_4_gen : process is
    begin
      clk_div4_tb <= not clk_div4_tb;
      wait for CLK_PERIOD / 2;
    end process clk_div_4_gen;

    clk_mult_4_gen : process is
    begin
      clk_mult4_tb <= not clk_mult4_tb;
      wait for CLK_PERIOD * 8;
    end process clk_mult_4_gen;

    stim : process is
    begin
      rst_tb <= '1';
      wait for 2 * CLK_PERIOD;
      rst_tb <= '0';
      wait;
    end process stim;

  end architecture testbench;
