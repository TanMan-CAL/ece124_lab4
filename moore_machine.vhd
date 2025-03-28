-- Members: Naman Biyani and Tanmay Shah
-- LS206_T20_LAB4
-- Moore State Machine for Traffic Light Controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity defines the traffic light controller inputs and outputs
Entity moore_machine IS Port
(
 offline_mode : IN std_logic;  -- offline_mode input
 clk_input    : IN std_logic;  -- global clock
 reset        : IN std_logic;  -- asynchronous reset input
 enable       : IN std_logic;  -- state machine enable control
 blink_sig    : IN std_logic;  -- blinking signal for certain lights

 -- traffic request inputs for pedestrian crossing from different directions (NS & EW)
 NSrequest  : IN std_logic;  
 EWrequest  : IN std_logic;  

 -- traffic light outputs for North-South direction as single bits
 redNS, yellowNS, greenNS : OUT std_logic;

 -- traffic light outputs for East-West direction as single bits
 redEW, yellowEW, greenEW : OUT std_logic;

 -- crossing and reset outputs for pedestrian crossing requests
 NSCrossing, EWCrossing : OUT std_logic;
 NSClear, EWClear       : OUT std_logic; 

 -- current state of machine as a 4 bit vector
 CurrentState : OUT std_logic_vector(3 downto 0)
 );
END ENTITY;
 
-- architecture implements the Moore State Machine logic
Architecture MM of moore_machine is 
 
 -- define possible states for different phases for the traffic light controller
 TYPE STATE_NAMES IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15);   

 -- internal signals to manage state transitions from one to another
 SIGNAL current_state, next_state : STATE_NAMES;     	


 BEGIN 
 -------------------------------------------------------------------------------
 --State Machine:
 -------------------------------------------------------------------------------

-- REGISTER_LOGIC PROCESS 
-- manages state updates on clock edge, accounts for reset and enable for state progression

Register_Section: PROCESS (clk_input)  -- synchronous process triggered by clock
BEGIN
	IF(rising_edge(clk_input)) THEN
		-- reset condition: force machine to initial state
		IF (reset = '1') THEN
			current_state <= s0;
		-- normal operation: update state when enabled
		ELSIF (reset = '0' AND enable = '1') THEN
			current_state <= next_state;
		END IF;
	END IF;
END PROCESS;	




-- TRANSITION LOGIC PROCESS EXAMPLE
-- defines state machine's next state logic for traffic light sequence and prioritization of requests
Transition_Section: PROCESS (EWrequest, NSrequest, current_state) 
BEGIN
	CASE current_state IS
		WHEN s0 => -- state s0: initial state
			-- prioritize East-West traffic request if active (skip from state 0 to 6)
			-- else move to state 1
			if (EWrequest = '1' and NSrequest = '0') then
				next_state <= s6;
			else
				next_state <= s1;
			end if;
				
		WHEN s1 => -- state s1: prioritize East-West traffic request if active (skip from state 1 to 6)
			   -- else move to state 2
			if (EWrequest = '1' and NSrequest = '0') then
				next_state <= s6;
			else
				next_state <= s2;
			end if;
		
		-- states (s2-s7): progression through traffic light sequence
		WHEN s2 =>		
			next_state <= s3;
			
		WHEN s3 =>
			next_state <= s4;
				
		WHEN s4 =>		
			next_state <= s5;
				
		WHEN s5 =>		
			next_state <= s6;
		
		WHEN s6 =>		
			next_state <= s7;
				
		WHEN s7 =>		
			next_state <= s8;
		
		WHEN s8 => -- state s8: prioritize North-South traffic request if active (skip from state 8 to 14)
			   -- else move to state 9
			if (EWrequest = '0' and NSrequest = '1') then
				next_state <= s14;
			else
				next_state <= s9;
			end if;
			
		WHEN s9 => -- state s9: prioritize North-South traffic request if active (skip from state 9 to 14)
			   -- else move to state 10	
			if (EWrequest = '0' and NSrequest = '1') then
				next_state <= s14;
			else
				next_state <= s10;
			end if;
		
		-- states s10-s14: continue traffic light sequence
		WHEN s10 =>		
			next_state <= s11;
				
		WHEN s11 =>		
			next_state <= s12;
		
		WHEN s12 =>		
			next_state <= s13;
			
		WHEN s13 =>		
			next_state <= s14;
				
		WHEN s14 =>		
			next_state <= s15;
				
		WHEN s15 =>
			-- state s15: handling offline mode
			IF (offline_mode = '1') THEN
				-- stay in current state when in offline mode
				next_state <= s15;
			ELSE
				-- return to initial state when not in offline mode
				next_state <= s0;
			END IF;
			
		WHEN OTHERS => -- fallback to state s0
			next_state <= s0;
	
	  END CASE;
 END PROCESS;
 

-- DECODER SECTION PROCESS EXAMPLE (MOORE FORM SHOWN)
-- process handles the state transitions and output logic for a traffic light controller
-- uses a 16-state (s0-s15) state machine to manage North-South and East-West traffic signals and pedestrian signals

Decoder_Section: PROCESS (blink_sig, current_state)

BEGIN
    -- initialization of clear signals for pedestrians
    NSClear <= '0';
    EWClear <= '0';

    CASE current_state IS -- CurrentState updates in each state to represent the binary representation of the current state from 0 to 15
	  
        		WHEN s0 => -- green light blinking for NS and solid red for EW, and crossing is prohibited
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= blink_sig;
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0000";
				
			WHEN s1 => -- green light blinking for NS and solid red for EW, and crossing is prohibited
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= blink_sig;
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0001";
				
			WHEN s2 => -- solid green light for NS and solid red for EW, and NS crossing signal activated			
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0010";
				
			WHEN s3 => -- solid green light for NS and solid red for EW, and NS crossing signal activated
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0011";
									
			WHEN s4 => -- solid green light for NS and solid red for EW, and NS crossing signal activated		
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0100";
									
			WHEN s5 => -- solid green light for NS and solid red for EW, and NS crossing signal activated	
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0101";
								
			WHEN s6 => -- solid amber light for NS and solid red for EW, and activates NS request clear for pedestrian walk
				   -- crossing is prohibited
				redNS <= '0';
				yellowNS <= '1';
				greenNS <= '0';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0110";
				
				NSClear <= '1';
				EWClear <= '0';
									
			WHEN s7 => -- solid amber light for NS and solid red for EW, and crossing is prohibited
				redNS <= '0';
				yellowNS <= '1';
				greenNS <= '0';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0111";
									
			WHEN s8 => -- green light blinking for EW and solid red for NS, and crossing prohibited
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= blink_sig;
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1000";
								
			WHEN s9 => -- green light blinking for EW and solid red for NS, and crossing prohibited
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= blink_sig;
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1001";
									
			WHEN s10 => -- solid green light for EW and solid red for NS with EW crossing signal activated
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1010";
									
			WHEN s11 => -- solid green light for EW and solid red for NS with EW crossing signal activated
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1011";
							
			WHEN s12 => -- solid green light for EW and solid red for NS with EW crossing signal activated	
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1100";
								
			WHEN s13 => -- solid green light for EW and solid red for NS with EW crossing signal activated
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1101";
									
			WHEN s14 => -- amber green light for EW and solid red for NS with crossing prohibited, and EW crossing request cleared
				redNS <= '1';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '1';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1110";
				
				NSClear <= '0';
				EWClear <= '1';
									
			WHEN s15 => -- final state with offline mode handling, and crossing is prohibited
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				greenEW <= '0';			
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1111";

				IF (offline_mode = '1') THEN -- red NS and yellow EW blinking if stuck in state 15
				redNS <= blink_sig;
				yellowEW <= blink_sig;

				ELSE -- solid red for NS and solid yellow for EW
				redNS <= '1';
				yellowEW <= '1';
				END IF;

				
			WHEN others => -- no lights on otherwise, if other state
				redNS <= '0';
				yellowNS <= '0';
				greenNS <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '0';
			
		END CASE;
 END PROCESS;

 END ARCHITECTURE MM;
