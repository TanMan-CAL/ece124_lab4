-- Members: Naman Biyani and Tanmay Shah
-- LS206_T20_LAB4
-- synchronizer.vhd

library ieee;
use ieee.std_logic_1164.all;

-- Entity declaration for the synchronizer (to get an asynchronous input signal to a synchronous domain) 
-- Helps reduce metastability
entity synchronizer is 
    port (
        clk     : in std_logic;   -- system clock input
        reset   : in std_logic;   -- async reset
        din     : in std_logic;   -- async input data signal 
        dout    : out std_logic   -- synchronized output signal
    );
end synchronizer;
 
-- architecture defining the synchronization behavior
architecture circuit of synchronizer is
    -- Internal signal to create a two-stage shift register
    -- Helps reduce metastability by providing multiple sampling stages
    Signal sreg : std_logic_vector(1 downto 0);

BEGIN
    process(clk) -- sensitivity list contains clk, hence the process is sensitive to clock edges
    begin
        -- trigger on rising edge of the clock
        if(rising_edge(clk)) then -- trigger on rising edge of the clock
            
            if(reset = '1') then -- reset condition
                sreg(0) <= '0';   -- clear first stage
                sreg(1) <= '0';   -- clear second stage
                dout <= sreg(1);  -- set output to second stage (which is now '0')
            else
                -- normal operation
                sreg(0) <= din;     -- first stage gets input signal
                sreg(1) <= sreg(0); -- second stage gets first stage value
                dout <= sreg(1);    -- output follows second stage
            end if;
        end if;
    end process;
end;
