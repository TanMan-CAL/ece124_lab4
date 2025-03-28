-- Members: Naman Biyani and Tanmay Shah
-- LS206_T20_LAB4

-- imports
library ieee;
use ieee.std_logic_1164.all;

-- Define Entity for PB_Inverters
entity PB_inverters is port (
	rst_n				: in	std_logic; -- reset (active low) is passed in here as it needs the same logic applied as our physicals PB's
	rst				: out std_logic; -- reset (active high) output after logic applied
 	pb_n_filtered	: in  std_logic_vector (3 downto 0); -- all 4 push buttons passed in as they are active low
	pb					: out	std_logic_vector(3 downto 0) -- outputted push buttons after logic are active high
	); 
end PB_inverters;

-- architecture definition
architecture ckt of PB_inverters is

begin
-- negating the active low reset to make it active high
rst <= NOT(rst_n);
-- negating the active low pb vector to make it active high
pb <= NOT(pb_n_filtered);


end ckt;