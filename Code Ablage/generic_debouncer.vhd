library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity generic_debouncer is -- eher ein generic delay
    generic (   input_signal : integer;
                output_signal : integer;
                delay : integer := 2000000); -- 2 Mio Zyklen    
    port(
        Clk : in std_logic;
        input : in unsigned(input_signal-1 downto 0);
        output: out unsigned(output_signal-1 downto 0));
end generic_debouncer;


architecture Behavioral of generic_debouncer is
    signal Reg : unsigned( input_signal-1 downto 0);
begin
    LastSig: process(Clk) 
        variable clock_counter : integer range 0 to delay := 0;
        begin
        if (rising_edge(Clk) and (clock_counter < delay)) then -- 2 000 000 clock_cycles
            clock_counter := clock_counter + 1;      
        else
            output <= input;
            clock_counter := 0;
        end if;
    end process LastSig;
end Behavioral;  