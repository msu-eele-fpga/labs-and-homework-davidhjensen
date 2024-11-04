library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_gen_tb is
end entity clock_gen_tb;

architecture testbench of clock_gen_tb is

  constant CLK_PERIOD : time := 20 ns;

  component pwm_controller is
    generic (
      CLK_PERIOD : time := 20 ns
    );
    port (
      clk : in std_logic;
      rst : in std_logic; -- active high
      -- PWM repetition period in milliseconds;
      -- datatype (W.F) (27.21) is individually assigned
      period : in unsigned(26 downto 0);
      -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
      -- datatype (W.F) (11.10) is individually assigned;
      duty_cycle : in std_logic_vector(10 downto 0);
      output     : out std_logic
    );
  end component pwm_controller;

  signal clk_tb     : std_ulogic            := '0';
  signal rst_tb     : std_ulogic            := '0';
  signal period_tb     : unsigned(26 downto 0) := "000001000000000000000000000";
  signal duty_cycle_tb : std_logic_vector(10 downto 0) := "01000000000";
  signal output_tb     : std_ulogic;

begin

  dut : component pwm_controller
    generic map
    (
      CLK_PERIOD => CLK_PERIOD
    )
    port map
    (
      clk   => clk_tb,
      rst       => rst_tb,
      period => period_tb,
      duty_cycle => duty_cycle_tb,
      output => output_tb
    );


    clk_gen : process is
    begin
      clk_tb <= not clk_tb;
      wait for CLK_PERIOD / 2;
    end process clk_gen;

    stim : process is
    begin
      rst_tb <= '1';
      wait for 2 * CLK_PERIOD;
      rst_tb       <= '0';
      wait for 2 ms;
      duty_cycle_tb <= "00100000000";
      wait for 2 ms;
      duty_cycle_tb <= "01100000000";
    end process stim;

  end architecture testbench;

