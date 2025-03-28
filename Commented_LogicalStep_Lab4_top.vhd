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
        clk     : in std_logic;    -- system clock
        reset   : in std_logic;    -- reset input
        din     : in std_logic;    -- asynchronous input signal
        dout    : out std_logic    -- synchronized, stable output signal
   );
   end component;

   -- holding register component to store button press states
   component holding_register 
   port (
        clk           : in std_logic;   -- system clock
        reset         : in std_logic;   -- reset input
        register_clr  : in std_logic;   -- clear signal to reset stored state
        din           : in std_logic;   -- input signal to be stored
        dout          : out std_logic   -- stored output signal
   );
   end component;
  
   -- moore machine for controlling traffic light sequencing
   component moore_machine 
   port (
        offline_mode : in std_logic;  -- Offline/alternative mode switch
        clk_input  : in std_logic;    -- Clock input for state transitions
        reset      : in std_logic;    -- System reset input
        enable     : in std_logic;    -- Clock enable for state progression
        blink_sig  : in std_logic;    -- Blinking timing signal for visual indicators
        NSrequest  : in std_logic;    -- North-South pedestrian crossing request
        EWrequest  : in std_logic;    -- East-West pedestrian crossing request
        redNS        : out std_logic;   -- North-West red light state
        yellowNS     : out std_logic;   -- North-West yellow light state
        greenNS      : out std_logic;   -- North-West green light state
        redEW      : out std_logic;   -- East-West red light state
        yellowEW   : out std_logic;   -- East-West yellow light state
        greenEW    : out std_logic;   -- East-West green light state
        NSCrossing : out std_logic;   -- North-South safe crossing indicator
        EWCrossing : out std_logic;   -- East-West safe crossing indicator
        NSClear    : out std_logic;   -- North-South crossing clearance signal
        EWClear    : out std_logic;   -- East-West crossing clearance signal
        CurrentState : out std_logic_vector(3 downto 0) -- Current state for debugging
   );
   end component;

-- INTERNAL SIGNALS
----------------------------------------------------------------------------------------------------
-- Simulation mode configuration: FALSE for FPGA implementation, TRUE for simulation environments
CONSTANT sim_mode : boolean := FALSE;

-- reset signals for system initialization and synchronization
SIGNAL rst, rst_n_filtered, synch_rst : std_logic;

-- clock control signals
SIGNAL sm_clken, blink_sig : std_logic;

-- push-button input processing signals
SIGNAL pb_n_filtered, pb : std_logic_vector(3 downto 0);

-- synchronization signals
SIGNAL sync_out, sync_out_final : std_logic_vector(1 downto 0);

-- pedestrian safe crossing indicators
SIGNAL NSCrossingDisplay, EWCrossingDisplay : std_logic;

-- traffic light control signals for both traffic directions
SIGNAL redNS, yellowNS, greenNS : std_logic; 
SIGNAL redEW, yellowEW, greenEW : std_logic;

-- crossing clearance signals to reset pedestrian requests
SIGNAL EWClear, NSClear : std_logic;

-- 7-segment display data signals for traffic light status
SIGNAL light, lightEW : std_logic_vector(6 downto 0);

-- switch for offline mode functionality
SIGNAL offline_mode : std_logic;

BEGIN

-- VARIABLE ASSIGNMENTS
----------------------------------------------------------------------------------------------------
leds(0) <= NSCrossingDisplay; -- show NS crossing status
leds(1) <= sync_out_final(0); -- NS pedestrian is waiting

leds(2) <= EWCrossingDisplay; -- show EW crossing status
leds(3) <= sync_out_final(1); -- EW pedestrian is waiting

-- formatting traffic light signals for 7-segment display
-- [Yellow][Spacing][Green][Spacing][Red]
light   <= yellowNS & "00" & greenNS & "00" & redNS;
lightEW <= yellowEW & "00" & greenEW & "00" & redEW;

-- offline mode switch connected to switch 0
offline_mode <= sw(0);


-- COMPONENT INSTANCES
----------------------------------------------------------------------------------------------------
-- push-button input processing chain
-- filters and converts push-button signals
INST0: pb_filters        port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters      port map (rst_n_filtered, rst, pb_n_filtered, pb);

-- synchronizer and clock generator
INST2: synchronizer      port map (clkin_50, '0', rst, synch_rst); 
INST3: clock_generator   port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

-- Pedestrian crossing request synchronization
-- Handles North-South pedestrian button
INST4: synchronizer      port map (clkin_50, synch_rst, pb(0), sync_out(0));
INST5: holding_register  port map (clkin_50, synch_rst, NSClear, sync_out(0), sync_out_final(0)); 

-- Handles East-West pedestrian button
INST6: synchronizer      port map (clkin_50, synch_rst, pb(1), sync_out(1));
INST7: holding_register  port map (clkin_50, synch_rst, EWClear, sync_out(1), sync_out_final(1)); 

-- graffic light Moore state machine
-- central logic for managing traffic light sequences and pedestrian crossings
INST8: moore_machine     port map (offline_mode, clkin_50, synch_rst, sm_clken, blink_sig, sync_out_final(0), sync_out_final(1),
                                   redNS, yellowNS, greenNS, redEW, yellowEW, greenEW, NSCrossingDisplay, EWCrossingDisplay, 
                                   NSClear, EWClear, leds(7 downto 4));

-- 7-segment display multiplexer for the NS and EW colour signals on display
INST9: segment7_mux      port map (clkin_50, lightEW, light, seg7_data, seg7_char1, seg7_char2);

END SimpleCircuit;
