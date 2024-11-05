library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity top is
  port (
    ----------------------------------------
    --  Clock inputs
    --  See DE10 Nano User Manual page 23
    ----------------------------------------
    fpga_clk1_50 : in std_ulogic;
    fpga_clk2_50 : in std_ulogic;
    fpga_clk3_50 : in std_ulogic;

    ----------------------------------------
    --  Push button inputs (KEY[0] and KEY[1])
    --  See DE10 Nano User Manual page 24
    --  The KEY push button inputs produce a '0'
    --  when pressed (asserted)
    --  and produce a '1' in the rest (non-pushed) state
    ----------------------------------------
    push_button_n : in std_ulogic_vector(1 downto 0);

    ----------------------------------------
    --  Slide switch inputs (SW)
    --  See DE10 Nano User Manual page 25
    --  The slide switches produce a '0' when
    --  in the down position
    --  (towards the edge of the board)
    ----------------------------------------
    sw : in std_ulogic_vector(3 downto 0);

    ----------------------------------------
    --  LED outputs
    --  See DE10 Nano User Manual page 26
    --  Setting LED to 1 will turn it on
    ----------------------------------------
    led : out std_ulogic_vector(7 downto 0);

    ----------------------------------------
    --  GPIO expansion headers (40-pin)
    --  See DE10 Nano User Manual page 27
    --  Pin 11 = 5V supply (1A max)
    --  Pin 29 = 3.3 supply (1.5A max)
    --  Pins 12, 30 = GND
    ----------------------------------------
    gpio_0 : inout std_ulogic_vector(35 downto 0);
    gpio_1 : inout std_ulogic_vector(35 downto 0)
  );
end entity top;
architecture top_arch of top is

  component pwm_controller is
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

begin


  pwm_ctrl : component pwm_controller
    port map
	 (
		clk => fpga_clk1_50,
		rst => not push_button_n(0),
		period => "000001000000000000000000000",
		duty_cycle => "01000000000",
		output => gpio_0(0)
	  );
	  
end architecture top_arch;
