library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity generic_debouncer is -- eher ein generic delay
    generic (   signal_amount : integer;
                signal_eq_len : integer;        -- wie viele aufeinanderfolgende Signale gleich sein sollen
                delay : integer := 25000000);   -- 20 Mio Zyklen, bei 100 MHz --> 5 Hz --> 200 ms 
    port(
        Clk : in std_logic;
        input : in std_logic_vector(signal_amount-1 downto 0);
        output: out std_logic_vector(signal_amount-1 downto 0));
end generic_debouncer;


architecture Behavioral of generic_debouncer is
    type internal_array_type is array (signal_amount-1 downto 0) of unsigned(signal_eq_len-1 downto 0);
    signal Reg_new : internal_array_type;
    signal Reg_old : internal_array_type;

begin    
--for loop außerhalb eines Prozesses    
--für jedes Bit eine eigene debouncer Instanz mit Delay und Schieberegister
GenDeb : for i in signal_amount-1 downto 0 generate
    LastSig: process(Clk) 
        variable clock_counter : integer range 0 to delay := 0;
        begin
        if rising_edge(Clk) then
            Reg_new(i) <= input(i) & Reg_new(i)(signal_eq_len-1 downto 1);
              
            if (clock_counter < delay) then         -- wenn delay noch nicht vergangen, warten
                clock_counter := clock_counter + 1;
                Reg_old(i) <= Reg_new(i);           -- hier werden schon die vergangenen Signale aufgezeichnet
            elsif (Reg_new(i) = Reg_old(i)) then    -- wenn delay vorbei und kein Rauschen
                output(i) <= input(i);              
                clock_counter := 0;
            else 
            Reg_old(i) <= Reg_new(i);               -- wenn delay vorbei aber das Signal immer noch rauscht
            end if;
        end if;
    end process LastSig;
end generate;
end Behavioral;  
