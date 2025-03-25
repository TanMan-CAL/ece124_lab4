library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity moore_machine IS Port
(
-- switch : IN std_logic;
 clk_input, reset, enable, blink_sig	: IN std_logic;
 NSrequest, EWrequest : IN std_logic;
 red, yellow, green					: OUT std_logic;
 redEW, yellowEW, greenEW : OUT std_logic;
 NSCrossing, EWCrossing, NSClear, EWClear : OUT std_logic;
 CurrentState : OUT std_logic_vector(3 downto 0)
 );
END ENTITY;
 

 Architecture MM of moore_machine is
 
 

 
 TYPE STATE_NAMES IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15);   -- list all the STATE_NAMES values
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


 BEGIN
 

 -------------------------------------------------------------------------------
 --State Machine:
 -------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS EXAMPLE
 
Register_Section: PROCESS (clk_input)  -- this process updates with a clock
BEGIN
	IF(rising_edge(clk_input)) THEN
		IF (reset = '1') THEN
			current_state <= s0;
		ELSIF (reset = '0' AND enable = '1') THEN
			current_state <= next_state;
		END IF;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS EXAMPLE

Transition_Section: PROCESS (EWrequest, NSrequest, current_state) 

BEGIN
	CASE current_state IS
		WHEN s0 =>
			if (EWrequest = '1' and NSrequest = '0') then
				next_state <= s6;
			else
				next_state <= s1;
			end if;
				
		WHEN s1 =>		
			if (EWrequest = '1' and NSrequest = '0') then
				next_state <= s6;
			else
				next_state <= s2;
			end if;
				
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
				
		WHEN s8 =>		
			if (EWrequest = '0' and NSrequest = '1') then
				next_state <= s14;
			else
				next_state <= s9;
			end if;
			
		WHEN s9 =>		
			if (EWrequest = '0' and NSrequest = '1') then
				next_state <= s14;
			else
				next_state <= s10;
			end if;
				
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
--			IF(switch = '1') THEN
--				next_state <= s15;
--			ELSE
				next_state <= s0;
--			END IF;
		WHEN OTHERS =>
			next_state <= s0;
	
	  END CASE;
 END PROCESS;
 

-- DECODER SECTION PROCESS EXAMPLE (MOORE FORM SHOWN)

Decoder_Section: PROCESS (blink_sig, current_state)

BEGIN
		NSClear <= '0';
		EWClear <= '0';

     CASE current_state IS
	  
         WHEN s0 =>		
				red <= '0';
				yellow <= '0';
				green <= blink_sig;
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0000";
				
			WHEN s1 =>		
				red <= '0';
				yellow <= '0';
				green <= blink_sig;
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0001";
				
			WHEN s2 =>		
				red <= '0';
				yellow <= '0';
				green <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0010";
				
			WHEN s3 =>
				red <= '0';
				yellow <= '0';
				green <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0011";
									
			WHEN s4 =>		
				red <= '0';
				yellow <= '0';
				green <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0100";
									
			WHEN s5 =>		
				red <= '0';
				yellow <= '0';
				green <= '1';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '1';
				EWCrossing <= '0';
				CurrentState <= "0101";
								
			WHEN s6 =>		
				red <= '0';
				yellow <= '1';
				green <= '0';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0110";
				
				NSClear <= '1';
				EWClear <= '0';
									
			WHEN s7 =>		
				red <= '0';
				yellow <= '1';
				green <= '0';
				
				redEW <= '1';
				yellowEW <= '0';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "0111";
									
			WHEN s8 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= blink_sig;
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1000";
								
			WHEN s9 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= blink_sig;
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1001";
									
			WHEN s10 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1010";
									
			WHEN s11 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1011";
							
			WHEN s12 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1100";
								
			WHEN s13 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '1';
				
				NSCrossing <= '0';
				EWCrossing <= '1';
				CurrentState <= "1101";
									
			WHEN s14 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '1';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1110";
				
				NSClear <= '0';
				EWClear <= '1';
									
			WHEN s15 =>		
				red <= '1';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '1';
				greenEW <= '0';
				
				NSCrossing <= '0';
				EWCrossing <= '0';
				CurrentState <= "1111";
				
			WHEN others =>
				red <= '0';
				yellow <= '0';
				green <= '0';
				
				redEW <= '0';
				yellowEW <= '0';
				greenEW <= '0';
			
		END CASE;
 END PROCESS;

 END ARCHITECTURE MM;
