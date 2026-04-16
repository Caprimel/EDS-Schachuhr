library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity Test_Anzeige is
end Test_Anzeige;

architecture Behavioral of Test_Anzeige is

component schachuhr_displ is
port (  Reg_out     : in unsigned (12 downto 0);
        Display_clk : in std_logic;
        Seconds_clk : in std_logic;
        Out_7_seg   : out std_logic_vector(7 downto 0));
end component;

-- testbench internal signals
signal t_Reg_out    : unsigned (12 downto 0):= "0000000001010"; --300 s
signal t_Display_clk: std_logic;
signal t_Out_7_seg  : std_logic_vector(7 downto 0);
signal t_Seconds_Clk: std_logic;   

begin
-- connect DUT to testbench
-- Bild: DUT => Testbench ("DUT wird mit seinen Pins auf die BEnch gesteckt")
DUT: schachuhr_displ port map (
        Reg_out => t_Reg_out, 
        Display_clk => t_Display_clk, 
        Seconds_clk => t_Seconds_clk,
        Out_7_seg => t_Out_7_seg);

-- run tests -- done in processes
internal_Clk: process
begin
    t_Seconds_clk <= '0';
    wait for 1 us;
    t_Seconds_clk <= '1';
    wait for 1 us;
end process internal_Clk;

generate_Reg_out : process(t_Seconds_clk) begin
    if (rising_edge(t_Seconds_clk) and (t_Reg_out > "0")) then
    t_Reg_out <= (t_Reg_out - 1);
    end if;
end process generate_Reg_out;

internal_display_clock : process begin
    t_Display_clk <= '0';
    wait for 10 ns;
    t_Display_clk <= '1';
    wait for 10 ns;
end process internal_display_clock;

end Behavioral;