-- Members: Naman Biyani and Tanmay Shah
-- LS206_T20_LAB4

-- imports
library ieee;
use ieee.std_logic_1164.all;

-- entity declaration for holding register which holds pb inputs until certain conditions are met
entity holding_register is port (

			clk					: in std_logic; -- input clock
			reset				: in std_logic; -- input reset bool
			register_clr		: in std_logic; -- register clear input
			din					: in std_logic; -- data input bit
			dout				: out std_logic -- output for data output
  );
 end holding_register;

-- architecture definition for holding register containing logic
 architecture circuit of holding_register is
	-- holds register values
	Signal sreg				: std_logic;


BEGIN
	
	
	PROCESS(clk)
	BEGIN
		-- only activate logic on the rising edge, then proceed with holding register logic
		IF (rising_edge(clk)) THEN
			-- if reset is '1', set the holding register back to '0'
			IF (reset = '1') THEN
				sreg <= '0';
			ELSE 
				-- uses the input and logic expression to assign it to the register signal
				sreg <= ((sreg OR din) AND NOT (register_clr OR reset));
			END IF;

		END IF;
	END PROCESS;
		 -- assign the register signal to the data output bit
		 dout <= sreg;
	
END;
