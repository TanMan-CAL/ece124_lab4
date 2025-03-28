-- Members: Naman Biyani and Tanmay Shah
-- LS206_T20_LAB4

-- imports
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- top level entity for traffic control system
ENTITY LogicalStep_Lab4_top IS
   PORT (
    clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
    rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
    pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
    sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
    
    seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
    seg7_char1  : out	std_logic;							-- seg7 digi selectors
    seg7_char2  : out	std_logic;		-- seg7 digi selectors
);
END LogicalStep_Lab4_top;

-- architecture for top including component declarations
ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

   -- 7-segment display multiplexer component
   component segment7_mux 
   port (
        clk     : in std_logic;
        DIN2    : in std_logic_vector(6 downto 0); -- data input for second digit
        DIN1    : in std_logic_vector(6 downto 0); -- data input for first digit
        DOUT    : out std_logic_vector(6 downto 0); -- output segment data
        DIG2    : out std_logic;
        DIG1    : out std_logic
   );
   end component;

   -- clock generator component for timing
   component clock_generator 
   port (
        sim_mode : in boolean; -- simulation mode flag
        reset    : in std_logic;
        clkin    : in std_logic;
        sm_clken : out std_logic; -- clock enable for moore machine
        blink    : out std_logic  -- blinking signal output
   );
   end component;

   -- push-button filter component
   component pb_filters 
   port (
        clkin          : in std_logic;
        rst_n          : in std_logic;
        rst_n_filtered : out std_logic;
        pb_n           : in std_logic_vector(3 downto 0);
        pb_n_filtered  : out std_logic_vector(3 downto 0)    
   );
   end component;

   -- push button inverter to convert active-low signals to active-high
   component pb_inverters 
   port (
        rst_n         : in std_logic; -- reset active low
        rst           : out std_logic; -- reset active high
        pb_n_filtered : in std_logic_vector(3 downto 0); -- pb's in an active low vector input
        pb            : out std_logic_vector(3 downto 0) -- pb's in an active high vector output
   );
   end component;
   
   -- synchronizer to prevent metastability from asynchronous inputs
   component synchronizer 
   port (
        clk  : in std_logic;
        reset : in std_logic;
        din  : in std_logic; -- flip flop input
        dout : out std_logic -- final output from the two flip flops
   );
   end component;

   -- holding register component to store button press states
   component holding_register 
   port (
        clk           : in std_logic;
        reset         : in std_logic;
        register_clr  : in std_logic;
        din           : in std_logic;
        dout          : out std_logic
   );
   end component;
  
   -- moore machine for controlling traffic light sequencing
   component moore_machine 
   port (
        switch : in std_logic;
        clk_input  : in std_logic;
        reset      : in std_logic;
        enable     : in std_logic; -- simple enable
        blink_sig  : in std_logic; -- blinking signal timing
        NSrequest  : in std_logic; -- request from NS pedestrian
        EWrequest  : in std_logic; -- request from EW pedestrian
        red        : out std_logic; -- red NW bool
        yellow     : out std_logic; -- yellow NW bool
        green      : out std_logic; -- green NW bool
        redEW      : out std_logic; -- red EW bool
        yellowEW   : out std_logic; -- yellow EW bool
        greenEW    : out std_logic; -- green EW bool
        NSCrossing : out std_logic; -- NS safe crossing bool
        EWCrossing : out std_logic; -- EW safe crossing bool
        NSClear    : out std_logic; -- NS clear functionality
        EWClear    : out std_logic; -- EW clear functionality
        CurrentState : out std_logic_vector(3 downto 0) -- current state for debugging purposes
   );
   end component;

-- INTERNAL SIGNALS
----------------------------------------------------------------------------------------------------
CONSTANT sim_mode : boolean := FALSE; -- Set to FALSE for FPGA, TRUE for simulations

-- reset signals
SIGNAL rst, rst_n_filtered, synch_rst : std_logic;

-- clock and timing signals
SIGNAL sm_clken, blink_sig : std_logic;

-- push button signals
SIGNAL pb_n_filtered, pb : std_logic_vector(3 downto 0);

-- synchronization signals
SIGNAL sync_out, sync_out_final : std_logic_vector(1 downto 0);

-- pedestrian safe crossing indicators
SIGNAL NSCrossingDisplay, EWCrossingDisplay : std_logic;

-- traffic light control signals
SIGNAL red, yellow, green : std_logic; -- for EW
SIGNAL redEW, yellowEW, greenEW : std_logic;

-- clear signals for crossings
SIGNAL EWClear, NSClear : std_logic;

-- 7-segment display signals
SIGNAL light, lightEW : std_logic_vector(6 downto 0);

-- switch for offline mode functionality
SIGNAL switch : std_logic;

BEGIN

-- VARIABLE ASSIGNMENTS
----------------------------------------------------------------------------------------------------
leds(0) <= NSCrossingDisplay; -- show NS crossing status
leds(1) <= sync_out_final(0); -- NS pedestrian is waiting

leds(2) <= EWCrossingDisplay; -- show EW crossing status
leds(3) <= sync_out_final(1); -- EW pedestrian is waiting

-- formatting traffic light signals for 7-segment display
light   <= yellow & "00" & green & "00" & red;
lightEW <= yellowEW & "00" & greenEW & "00" & redEW;

-- offline mode switch connected to switch 0
switch <= sw(0);


-- COMPONENT INSTANCES
----------------------------------------------------------------------------------------------------
-- push button filtering
INST0: pb_filters        port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters      port map (rst_n_filtered, rst, pb_n_filtered, pb);

-- synchronizer and clock generator
INST2: synchronizer      port map (clkin_50, '0', rst, synch_rst); 
INST3: clock_generator   port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

-- synchronizing and storing button presses
INST4: synchronizer      port map (clkin_50, synch_rst, pb(0), sync_out(0));
INST5: holding_register  port map (clkin_50, synch_rst, NSClear, sync_out(0), sync_out_final(0)); 

INST6: synchronizer      port map (clkin_50, synch_rst, pb(1), sync_out(1));
-- holding register to hold pedestrian inputs
INST7: holding_register  port map (clkin_50, synch_rst, EWClear, sync_out(1), sync_out_final(1)); 

-- traffic light moore state machine with all needed input and outputs
INST8: moore_machine     port map (switch, clkin_50, synch_rst, sm_clken, blink_sig, sync_out_final(0), sync_out_final(1),
                                   red, yellow, green, redEW, yellowEW, greenEW, NSCrossingDisplay, EWCrossingDisplay, 
                                   NSClear, EWClear, leds(7 downto 4));

-- 7-segment display multiplexer
INST9: segment7_mux      port map (clkin_50, lightEW, light, seg7_data, seg7_char1, seg7_char2);

END SimpleCircuit;
