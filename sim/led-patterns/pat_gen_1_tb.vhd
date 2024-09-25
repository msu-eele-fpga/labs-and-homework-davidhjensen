library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pat_gen_1_tb is
end entity pat_gen_1_tb;

architecture testbench of pat_gen_1_tb is

  constant CLK_PERIOD : time := 20 ns;

  component pat_gen_1 is
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      LED : out std_ulogic_vector(6 downto 0)
    );
  end component pat_gen_1;

  signal clk_tb : std_ulogic := '0';
  signal rst_tb : std_ulogic := '0';
  signal LED_tb : std_ulogic_vector(6 downto 0);

begin

  dut : component pat_gen_1
    port map
    (
      clk => clk_tb,
      rst => rst_tb,
      LED => LED_tb
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
      rst_tb <= '0';
      wait;
    end process stim;
    
  end architecture testbench;
