
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
	 rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	 pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
	 sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic;		-- seg7 digi selectors
	
	blinky_sig : out std_logic;
	EW_a : out std_logic;
	EW_g : out std_logic;
	EW_d : out std_logic;
	NS_a : out std_logic;
	NS_g : out std_logic;
	NS_d : out std_logic;
	
	sm_clken123 : out std_logic
	--STATE : out std_logic_vector(3 downto 0)
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
             clk     : in std_logic := '0';
			 DIN2 		: in std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 		: in std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
            clkin      		    : in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	    : out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	    : out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				    : out	std_logic;							 
			pb_n_filtered	    : in  std_logic_vector (3 downto 0);
			pb					: out	std_logic_vector(3 downto 0)							 
  );
   end component;
	
	component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;

  component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;
  
  component moore_machine port (
--	 switch : IN std_logic;
	 clk_input, reset, enable, blink_sig	: IN std_logic;
	 NSrequest, EWrequest : IN std_logic;
	 red, yellow, green					: OUT std_logic;
	 redEW, yellowEW, greenEW : OUT std_logic;
	 NSCrossing, EWCrossing, NSClear, EWClear : OUT std_logic;
	 CurrentState : OUT std_logic_vector(3 downto 0)
  );
  end component;
			
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode										: boolean := TRUE;  -- set to FALSE for LogicalStep board downloads																						-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			: std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0);
	SIGNAL sync_out 	 									: std_logic_vector(1 downto 0);
	SIGNAL sync_out_final 	 							: std_logic_vector(1 downto 0);
	SIGNAL NSCrossingDisplay, EWCrossingDisplay 	: std_logic;
	
	SIGNAL red, yellow, green : std_logic;
	SIGNAL redEW, yellowEW, greenEW : std_logic;
	
	SIGNAL EWClear, NSClear : std_logic;
	
	SIGNAL light, lightEW : std_logic_vector(6 downto 0);
	
	SIGNAL switch : std_logic;
	
BEGIN
----------------------------------------------------------------------------------------------------
leds(0) <= NSCrossingDisplay; -- sm_clken;
leds(1) <= sync_out_final(0);

leds(2) <= EWCrossingDisplay; -- blink_sig;
leds(3) <= sync_out_final(1);

light <= yellow & "00" & green & "00" & red;
lightEW <= yellowEW & "00" & greenEW & "00" & redEW;

--switch <= sw(0);


blinky_sig <= blink_sig;
NS_a <= red;
NS_g <= yellow;
NS_d <= green;
EW_a <= redEW;
EW_g <= yellowEW;
EW_d <= greenEW;
sm_clken123 <= sm_clken;

INST0: pb_filters			port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);
INST2: synchronizer     port map (clkin_50,'0', rst, synch_rst);	
INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig); -- leds here

INST4: synchronizer 		port map (clkin_50, synch_rst, pb(0), sync_out(0));
INST5: holding_register port map (clkin_50, synch_rst, NSClear, sync_out(0), sync_out_final(0)); --ns
 
INST6: synchronizer 		port map (clkin_50, synch_rst, pb(1), sync_out(1));
INST7: holding_register port map (clkin_50, synch_rst, EWClear, sync_out(1), sync_out_final(1)); --ew

INST8: moore_machine 	port map (clkin_50, synch_rst, sm_clken, blink_sig, sync_out_final(0), sync_out_final(1), red, yellow, green, redEW, yellowEW, greenEW, NSCrossingDisplay, EWCrossingDisplay, NSClear, EWClear, leds(7 downto 4));

INST9: segment7_mux		port map (clkin_50, lightEW, light, seg7_data, seg7_char1, seg7_char2);


END SimpleCircuit;