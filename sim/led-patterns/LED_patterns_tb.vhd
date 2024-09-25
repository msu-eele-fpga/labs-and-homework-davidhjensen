library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LED_patterns_tb is
end entity LED_patterns_tb;

architecture testbench of LED_patterns_tb is

  constant CLK_PERIOD : time := 20 ns;
  constant PATTERN_TEST_PERIOD : time := 1 sec;

  component LED_patterns is
    generic (
      system_clock_period : time
    );
    port (
      clk             : in std_ulogic;
      rst             : in std_ulogic;
      push_button     : in std_ulogic;
      switches        : in std_ulogic_vector(3 downto 0);
      hps_led_control : in boolean;
      base_period     : in unsigned(7 downto 0);
      led_reg         : in std_ulogic_vector(7 downto 0);
      led             : out std_ulogic_vector(7 downto 0)
    );
  end component led_patterns;

  signal clk_tb             : std_ulogic                    := '0';
  signal rst_tb             : std_ulogic                    := '0';
  signal push_button_tb     : std_ulogic                    := '0';
  signal switches_tb        : std_ulogic_vector(3 downto 0) := "000";
  signal hps_led_control_tb : boolean                       := false;
  signal base_period_tb     : unisgned(7 downto 0)          := x"00";
  signal led_reg_tb         : std_ulogic_vector(7 downto 0) := x"00";
  signal led_tb             : std_ulogic_vector(7 downto 0) := x"00";

begin

  dut : led_patterns
  generic map(
    system_clock_period <= CLK_PERIOD
  )
  port map
  (
    clk             => clk_tb,
    rst             => rst_tb,
    push_button     => push_button_tb,
    switches        => switches_tb,
    hps_led_control => hps_led_control_tb,
    base_period     => base_period,
    led_reg         => led_reg_tb,
    led             => led_tb
  );

  clk_gen : process is
  begin
    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;
  end process clk_gen;

  -- test is desgned to see NUM_CLK_PERIODS per pattern


end architecture testbench;