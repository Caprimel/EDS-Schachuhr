----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity schachuhr is
port( 
player_select, start_stop : in std_logic;
Reset: in std_logic;
Clk: in std_logic;
LED1,LED2: out std_logic;
Mux_7_seg: out std_logic_vector(3 downto 0);
Out_7_seg: out std_logic_vector(7 downto 0)
);
end schachuhr;

architecture Behavioral of schachuhr is
-- internal signals and variables

signal Display_clk : std_logic := '0'; -- display clock 
signal Seconds_clk: std_logic := '0'; -- clock in seconds
signal D1, D2, D3, D4, DOut : std_logic_vector (3 downto 0):= (others => '0');

signal Reg_0: std_logic_vector(12 downto 0):= "0000100101100";
signal Reg_1: std_logic_vector(12 downto 0):= "0000100101100";
signal Reg_out: std_logic_vector(12 downto 0);
signal ink0 : std_logic_vector(7 downto 0):= "00000011";
signal ink1 : std_logic_vector(7 downto 0):= "00000011";


begin
-- ZEIT
-- player reg-> 300 s
-- wenn start_stop =1 -> 300 - zeit
-- wenn zeit=300 -> player reg=0 -> blink whole mux

-- ANZEIGE
-- anzeige:
-- anfang:  1 0 0 0
-- 1 s:     0 9 5 9


end Behavioral;
