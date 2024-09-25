library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.standard;

entity led_patterns is
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
end entity led_patterns;

architecture arch of LED_patterns is

  constant DISPLAY_COUNT_LIMIT : natural := ((1 sec/system_clock_period));

  -- intermediate signals to hold clocks on
  signal clk_base  : std_ulogic := '0';
  signal clk_pat_0 : std_ulogic := '0';
  signal clk_pat_1 : std_ulogic := '0';
  signal clk_pat_2 : std_ulogic := '0';
  signal clk_pat_3 : std_ulogic := '0';
  signal clk_pat_4 : std_ulogic := '0';

  -- intermediate signals to store individual patterns on
  signal led_pat_0 : std_ulogic_vector(6 downto 0) := "0000000";
  signal led_pat_1 : std_ulogic_vector(6 downto 0) := "0000000";
  signal led_pat_2 : std_ulogic_vector(6 downto 0) := "0000000";
  signal led_pat_3 : std_ulogic_vector(6 downto 0) := "0000000";
  signal led_pat_4 : std_ulogic_vector(6 downto 0) := "0000000";

  -- intermediate signal to hold active pattern on
  signal led_active : std_ulogic_vector(7 downto 0) := "00000000";

  -- signal for conditioned push button
  signal pb_conditioned : std_ulogic := '0';

  -- signals for showing switch status for a second
  signal display_bool       : std_ulogic := '0';
  signal display_count_bool : std_ulogic := '0';
  signal display_count      : natural range 0 to (DISPLAY_COUNT_LIMIT - 1);

  -- custom var and signal for states
  type pattern_state is (idle, activate_timer, display, zero, one, two, three, four);
  signal state      : pattern_state := idle;
  signal prev_state : pattern_state := display;

  -- declare clock gen
  component clock_gen is
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
  end component;

  -- declare async conditioner
  component async_conditioner is
    port (
      clk   : in std_ulogic;
      rst   : in std_ulogic;
      async : in std_ulogic;
      sync  : out std_ulogic
    );
  end component;

  -- declare pattern generator components
  component pat_gen_0 is
    port (
      clk : in std_logic;
      rst : in std_logic;
      LED : out std_ulogic_vector(6 downto 0)
    );
  end component;

  component pat_gen_1 is
    port (
      clk : in std_logic;
      rst : in std_logic;
      LED : out std_ulogic_vector(6 downto 0)
    );
  end component;

  component pat_gen_2 is
    port (
      clk : in std_logic;
      rst : in std_logic;
      LED : out std_ulogic_vector(6 downto 0)
    );
  end component;

  component pat_gen_3 is
    port (
      clk : in std_logic;
      rst : in std_logic;
      LED : out std_ulogic_vector(6 downto 0)
    );
  end component;

  component pat_gen_4 is
    port (
      clk_div4 : in std_logic;
      clk_mult4 : in std_logic;
      rst : in std_logic;
      LED : out std_ulogic_vector(6 downto 0)
    );
  end component;

begin

  clk_gen_comp : clock_gen
  port map
  (
    sys_clk   => clk,
    rst       => rst,
    base_rate => base_period,
    div_1     => clk_base,
    div_2     => clk_pat_0,
    div_4     => clk_pat_1,
    div_8     => clk_pat_3,
    mult_2    => clk_pat_2,
    mult_4    => clk_pat_4
  );

  conditioner : async_conditioner
  port map
  (
    clk   => clk,
    rst   => rst,
    async => push_button,
    sync  => pb_conditioned
  );

  pat0 : pat_gen_0
  port map
  (
    clk => clk_pat_0,
    rst => rst,
    LED => led_pat_0
  );

  pat1 : pat_gen_1
  port map
  (
    clk => clk_pat_1,
    rst => rst,
    LED => led_pat_1
  );

  pat2 : pat_gen_2
  port map
  (
    clk => clk_pat_2,
    rst => rst,
    LED => led_pat_2
  );

  pat3 : pat_gen_3
  port map
  (
    clk => clk_pat_3,
    rst => rst,
    LED => led_pat_3
  );

  pat4 : pat_gen_4
  port map
  (
    clk_div4 => clk_pat_1,
    clk_mult4 => clk_pat_4,
    rst => rst,
    LED => led_pat_4
  );

  LED_7_FLIPPER : process (rst, clk_base)
  begin
    if (rst = '1') then
      led(7) <= '0';
      elsif (rising_edge(clk_base)) then
      led(7) <= not led(7);
    end if;
  end process LED_7_FLIPPER;

  STATE_LOGIC : process (rst, clk)
  begin
    if (rst = '1') then
      state              <= idle;
      prev_state         <= idle;
      display_count_bool <= '0';
      elsif (rising_edge(clk)) then
      case state is
        when idle =>
          if(pb_conditioned = '1') then
            state <= activate_timer;
            display_count_bool <= '1';
          else
            state <= idle;
            display_count_bool <= '0';
          end if;
        
        when activate_timer =>
          state <= display;
          
        when display =>
          if(display_bool = '1') then
            state <= display;
          elsif(switches = "0000" ) then
            state <= zero;
          elsif(switches = "0001" ) then
            state <= one;
          elsif(switches = "0010" ) then
            state <= two;
          elsif(switches = "0011" ) then
            state <= three;
          elsif(switches = "0100" ) then
            state <= four;
          else
            state <= prev_state;  
          end if;

        when zero =>
          display_count_bool <= '0';
          prev_state         <= state;
          if(pb_conditioned = '1') then
            state <= activate_timer;
            display_count_bool <= '1';
          else 
            state <= zero;
          end if;

        when one =>
          display_count_bool <= '0';
          prev_state         <= state;
          if(pb_conditioned = '1') then
            state <= activate_timer;
            display_count_bool <= '1';
          else 
            state <= one;
          end if;

        when two =>
          display_count_bool <= '0';
          prev_state         <= state;
          if(pb_conditioned = '1') then
            state <= activate_timer;
            display_count_bool <= '1';
          else 
            state <= two;
          end if;

        when three =>
          display_count_bool <= '0';
          prev_state         <= state;
          if(pb_conditioned = '1') then
            state <= activate_timer;
            display_count_bool <= '1';
          else 
            state <= three;
          end if;

        when four =>
          display_count_bool <= '0';
          prev_state         <= state;
          if(pb_conditioned = '1') then
            state <= activate_timer;
            display_count_bool <= '1';
          else 
            state <= four;
          end if;

        when others =>
          display_count_bool <= '0';
          state              <= idle;
      end case;
    end if;
  end process STATE_LOGIC;

  OUTPUT_LOGIC : process(rst, clk)
  begin
    if (rst = '1') then
      led(6 downto 0) <= "0000000";
      elsif (rising_edge(clk)) then
      case state is
        when idle =>
          led(6 downto 0) <= "0000000";
        when display =>
          led(6 downto 4) <= "000";
          led(3 downto 0) <= switches;
        when zero =>
          led(6 downto 0) <= led_pat_0;
        when one =>
          led(6 downto 0) <= led_pat_1;
        when two =>
          led(6 downto 0) <= led_pat_2;
        when three =>
          led(6 downto 0) <= led_pat_3;
        when four =>
          led(6 downto 0) <= led_pat_4;
        when others =>
          led(6 downto 0) <= "0000000";
      end case;
    end if;
  end process OUTPUT_LOGIC;

  DISPLAY_TIMER : process (clk, rst)
  begin
    if (rst = '1') then
      display_count <= 0;
      display_bool  <= '0';
    elsif (rising_edge(clk)) then
      if (display_count_bool = '1' and (display_count < DISPLAY_COUNT_LIMIT)) then
        display_count <= display_count + 1;
        display_bool  <= '1';
      else
        display_count <= 0;
        display_bool  <= '0';
      end if;
    end if;
  end process DISPLAY_TIMER;

end architecture;