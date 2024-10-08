-- altera vhdl_input_version vhdl_2008

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity led_patterns_avalon is
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    -- avalon memory-mapped slave interface
    avs_read      : in std_logic;
    avs_write     : in std_logic;
    avs_address   : in std_logic_vector(1 downto 0);
    avs_readdata  : out std_logic_vector(31 downto 0);
    avs_writedata : in std_logic_vector(31 downto 0);
    -- external I/O; export to top-level
    push_button : in std_ulogic;
    switches    : in std_ulogic_vector(3 downto 0);
    led         : out std_ulogic_vector(7 downto 0)
  );
end entity led_patterns_avalon;

architecture arch of led_patterns_avalon is

  signal reg_hps_led_control  : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_led_reg          : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_base_period      : std_logic_vector(31 downto 0) := (1 => '1', others => '0');
  signal bool_hps_led_control : boolean                        := false;

  component led_patterns is
    generic (
      system_clock_period : time := 20 ns
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

begin

  LED_PAT : led_patterns
  port map
  (
    clk             => clk,
    rst             => rst,
    push_button     => push_button,
    switches        => switches,
    hps_led_control => bool_hps_led_control,
    base_period     => unsigned(reg_base_period(7 downto 0)),
    led_reg         => std_ulogic_vector(reg_led_reg(7 downto 0)),
    led             => led
  );

  avalon_register_read : process (clk)
  begin
    if rising_edge(clk) and avs_read = '1' then
      case avs_address is
        when "00" => avs_readdata   <= reg_hps_led_control;
        when "01" => avs_readdata   <= reg_led_reg;
        when "10" => avs_readdata   <= reg_base_period;
        when others => avs_readdata <= (others => '0');
      end case;
    end if;
  end process;

  avalon_register_write : process (clk, rst)
  begin
    if rst = '1' then
      reg_hps_led_control <= (others => '0');
      reg_led_reg         <= (others => '0');
      reg_base_period     <= (1 => '1', others => '0');
    elsif rising_edge(clk) and avs_write = '1' then
      case avs_address is
        when "00"   => reg_hps_led_control <= avs_writedata(31 downto 0);
        when "01"   => reg_led_reg         <= avs_writedata(31 downto 0);
        when "10"   => reg_base_period     <= avs_writedata(31 downto 0);
        when others => null; -- ignore writes to unused registers
      end case;
    end if;
  end process;

  bool_hps_led_control <= false when reg_hps_led_control(0) = '0' else
    true;

end architecture arch;