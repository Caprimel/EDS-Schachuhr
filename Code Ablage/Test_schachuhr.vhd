library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity Test_schachuhr is
end Test_schachuhr;

architecture Behavioural of Test_schachuhr is

component schachuhr is
port( 
player_select, start_stop : in std_logic;
Reset: in std_logic;
Clk: in std_logic;
LED0,LED1: out std_logic;
Mux_7_seg: out std_logic_vector(3 downto 0);
Out_7_seg: out std_logic_vector(7 downto 0)
);
end component;

signal t_player_select, t_start_stop, t_Reset, t_Clk: std_logic; 

begin

system_clk: process
begin
    t_Clk <= '0';
    wait for 10 ns;
    t_Clk <= '1';
    wait for 10 ns;
end process system_clk;

play_situation: process
begin
    t_player_select <= '0';
    wait for 3 us;
    t_player_select <= '1';
    wait for 3 us;
end process play_situation;

stop_situation: process
begin 
    t_Reset <= '0';
    t_start_stop <= '0';
    wait for 11 us;
    t_start_stop <= '1';
    wait for 2 us;
    t_Reset <= '1';
    wait for 2us;
    t_start_stop <= '0';
end process stop_situation;

end ;
