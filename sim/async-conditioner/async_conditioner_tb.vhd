library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity async_conditioner_tb is
end entity async_conditioner_tb;

architecture testbench of async_conditioner_tb is

  -- components
  component async_conditioner is
    port
    (
        clk   : in std_ulogic;
        rst   : in std_ulogic;
        async : in std_ulogic;
        sync  : out std_ulogic
    );
  end component async_conditioner;

  -- types

  -- signals
  signal clk_tb   : std_ulogic := '0';
  signal rst_tb   : std_ulogic := '1';
  signal async_tb : std_ulogic := '0';
  signal sync_tb : std_ulogic := '0';

  signal expected : std_ulogic := '0';

  -- constants

  -- procedures

begin

  -- component to test
  dut : component async_conditioner
    port map
    (
      clk   => clk_tb,
      rst   => rst_tb,
      async => async_tb,
      sync => sync_tb
    );

    -- tb clock generation
    clk_gen : process is
    begin
      clk_tb <= not clk_tb;
      wait for CLK_PERIOD / 2;
    end process clk_gen;

    -- stimuli for input
    stimuli : process is
    begin
      -- wait for reset to drop low
      wait for 2 * CLK_PERIOD;
      rst_tb <= '0';

      async_tb <= '0';
      wait for 0.7 * CLK_PERIOD;

      async_tb <= '1';
      wait for 1 * CLK_PERIOD;

      async_tb <= '0';
      wait for 1 * CLK_PERIOD;

      async_tb <= '1';
      wait for 1 * CLK_PERIOD;
      
      async_tb <= '0';
      wait for 8 * CLK_PERIOD;

      async_tb <= '1';
      wait for 4 * CLK_PERIOD;

      async_tb <= '0';

      wait;

    end process stimuli;

    -- expected output
    expected_pulse : process is
    begin
      -- wait for reset to drop low
      wait for 2 * CLK_PERIOD;

      expected <= '0';
      wait for 4 * CLK_PERIOD;

      expected <= '1';
      wait for 1 * CLK_PERIOD;

      expected <= '0';
      wait for 10 * CLK_PERIOD;

      expected <= '1';
      wait for 1 * CLK_PERIOD;

      expected <= '0';

      wait;

    end process expected_pulse;

    check_output : process is

      variable failed : boolean := false;

    begin
      -- wait for reset to drop low
      wait for 2 * CLK_PERIOD;

      for i in 0 to 17 loop

        assert expected = sync_tb
        report "Error on clock cycle " & to_string(i) & ": pulse expected = " & to_string(expected) & " | pulse = " & to_string(sync_tb)
          severity warning;

        if expected /= sync_tb then
          failed := true;
        end if;

        wait for CLK_PERIOD;

      end loop;

      if failed then
        report "tests failed!"
          severity failure;
      else
        report "all tests passed!";
      end if;

      std.env.finish;

    end process check_output;

  end architecture testbench;