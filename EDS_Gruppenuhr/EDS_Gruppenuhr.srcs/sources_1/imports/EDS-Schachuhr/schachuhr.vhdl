library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity schachuhr is
port( 
player_select, start_stop, input_select : in std_logic;
Reset: in std_logic;
min_plus, min_minus, sek_plus, sek_minus: in std_logic;
Clk: in std_logic;
LED0,LED1,LED2,LED3: out std_logic;
Mux_7_seg: out std_logic_vector(3 downto 0);
Out_7_seg: out std_logic_vector(7 downto 0)
);
end schachuhr;

architecture Behavioral of schachuhr is

--Debouncer : aus Delay und Schieberegister
component generic_debouncer is -- Instanziierung
    generic (   signal_amount : integer;
                signal_eq_len : integer;        -- wie viele aufeinanderfolgende Signale gleich sein sollen
                delay : integer := 2000000);   -- 20 Mio Zyklen, bei 100 MHz --> 5 Hz --> 200 ms 
    port(
        Clk : in std_logic;
        input : in std_logic_vector(signal_amount-1 downto 0);
        output: out std_logic_vector(signal_amount-1 downto 0));
end component;
--Signale für Debouncer 
signal min_plus_deb     : std_logic;
signal min_minus_deb    : std_logic; 
signal sek_plus_deb     : std_logic; 
signal sek_minus_deb    : std_logic; 
signal player_select_deb : std_logic; 
--signal deb_input        : std_logic_vector (4 downto 0);
--signal deb_output       : std_logic_vector (4 downto 0); --Hilfssignal


-- internal signals and variables
constant sekunde_trigger :  integer := 50000000; -- 100 MHz -> 0,5s -> 1s pro Periode
constant display_trigger :  integer := 100000; -- 100 MHz -> 1ms 
constant Blink_trigger : integer := 20000000; -- 100 MHz -> 0,2s -> 0,4s pro Periode 
signal Blink_en     : std_logic := '1';
signal Blink_cnt    : integer range 0 to Blink_trigger - 1 := 0;

signal Display_clk : std_logic := '0'; -- display clock 
signal Seconds_clk: std_logic := '0'; -- clock in seconds
signal Seconds_clk_last: std_logic := '0';
signal player_last: std_logic:='0';
signal D1, D2, D3, D4, DOut : unsigned (3 downto 0):= (others => '0');

signal reg0_const : unsigned (12 downto 0):= "0000100101100";   -- 5 min
signal reg1_const : unsigned (12 downto 0):= "0000100101100";
signal Reg_0: unsigned (12 downto 0):= reg0_const;
signal Reg_1: unsigned (12 downto 0):= reg1_const;
signal Reg_out: unsigned (12 downto 0);
signal ink0 : unsigned(12 downto 0):= "0000000000011";          -- 3 sek
signal ink1 : unsigned(12 downto 0):= "0000000000011";

signal MUX  : unsigned (1 downto 0):= (others=>'0');

begin

GenDeb : generic_debouncer --Deklaration
    generic map(
        signal_amount => 5,
        signal_eq_len => 32      
    )    
    port map (
    --component => entity_signals
    input => player_select & min_plus & min_minus & sek_plus & sek_minus,
--    output => player_select & min_plus_deb & min_minus_deb & sek_plus_deb & sek_minus_deb, --concatination kann kein Ziel sein.
--    input => deb_input,
--    output => deb_output,
    output(4) => player_select_deb,
    output(3) => min_plus_deb,
    output(2) => min_minus_deb,
    output(1) => sek_plus_deb,
    output(0) => sek_minus_deb,
    Clk => Clk
    );

--DebSignals : process (player_select, min_plus, min_minus, sek_plus, sek_minus, deb_output)
--begin
--    deb_input           <= player_select & min_plus & min_minus & sek_plus & sek_minus;
--    player_select_deb   <= deb_output(4);
--    min_plus_deb        <= deb_output(3);
--    min_minus_deb       <= deb_output(2);
--    sek_plus_deb        <= deb_output(1);
--    sek_minus_deb       <= deb_output(0);
--end process Debsignals;

Display_clock: process(Clk, start_stop)
variable DCnt : Integer range 0 to display_trigger-1 := 0;
begin
if rising_edge(Clk) then
    if DCnt = display_trigger - 1 then 
        DCnt := 0;
        Display_clk <= not Display_clk;  
    else 
        DCnt := DCnt + 1;
    end if;  
end if;
end process Display_clock;

Sekunde_clock: process(Clk, start_stop)
variable SCnt : Integer range 0 to sekunde_trigger-1 := 0;
begin
if rising_edge(Clk) then
    if start_stop = '1' then
        if SCnt = sekunde_trigger - 1 then 
            SCnt := 0;
            Seconds_clk <= not Seconds_clk;  
        else 
            SCnt := SCnt + 1;
        end if;  
    end if;
end if;
end process Sekunde_clock;

Sekunde_counter: process(   Clk,start_stop,Reset,player_select_deb,Seconds_clk,Seconds_clk_last,
                            player_last,input_select,min_plus_deb,min_minus_deb,sek_plus_deb,sek_minus_deb)
begin
--rest
if (rising_edge(Clk)) then
    if start_stop ='0' then
        if Reset = '1' then -- clock lauft nicht
            Reg_1<=reg1_const;
            Reg_0<=reg0_const;
        else NULL;
        end if;
        if input_select ='0' then
            if player_select_deb = '0' then -- player 0
                if min_plus_deb = '1' then
                    reg0_const<= reg0_const+60;
                    Reg_0 <= (Reg_0 + 60);
                elsif min_minus_deb = '1' then
                    reg0_const<= reg0_const-60;
                    Reg_0 <= (Reg_0 - 60);
                elsif sek_plus_deb = '1' then
                    reg0_const<= reg0_const+1;
                    Reg_0 <= (Reg_0 + 1);
                elsif sek_minus_deb = '1' then
                    reg0_const<= reg0_const-1;
                    Reg_0 <= (Reg_0 - 1);
                else NULL;
                end if;
            elsif player_select_deb = '1' then -- player 0
                if min_plus_deb = '1' then
                    reg1_const<= reg1_const+60;
                    Reg_1 <= (Reg_1 + 60);
                elsif min_minus_deb = '1' then
                    reg1_const<= reg1_const-60;
                    Reg_1 <= (Reg_1 - 60);
                elsif sek_plus_deb = '1' then
                    reg1_const<= reg1_const+1;
                    Reg_1 <= (Reg_1 + 1);
                elsif sek_minus_deb = '1' then
                    reg1_const<= reg1_const-1;
                    Reg_1 <= (Reg_1 - 1);
                else NULL;
                end if;
            else NULL;
            end if;
        elsif input_select ='1' then 
                if player_select_deb = '0' then -- player 0
                if min_plus_deb = '1' then
                    ink0<= ink0+60;
                elsif min_minus_deb = '1' then
                    ink0<= ink0-60;
                elsif sek_plus_deb = '1' then
                    ink0<= ink0+1;
                elsif sek_minus_deb = '1' then
                    ink0<= ink0-1;
                else NULL;
                end if;
            elsif player_select_deb = '1' then -- player 0
                if min_plus_deb = '1' then
                    ink1<= ink1+60;
                elsif min_minus_deb = '1' then
                    ink1<= ink1-60;
                elsif sek_plus_deb = '1' then
                    ink1<= ink1+1;
                elsif sek_minus_deb = '1' then
                    ink1<= ink1-1;
                else NULL;
                end if;    
            else NULL;
            end if;
        else NULL;
        end if;  
          
    elsif start_stop='1' then -- clock lauft
        if player_select_deb/=player_last and (Reg_0>0)and (Reg_1>0) then 
            if (player_select_deb='1') then -- if switch player 0 zu 1
                Reg_0 <= (Reg_0 + ink0);
            elsif (player_select_deb='0') and (Reg_1>0) then  -- if switch player 1 zu 0
                Reg_1 <= (Reg_1 + ink1);
            else NULL;
            end if;
        else NULL;
        end if;
        if Seconds_clk = '1' and Seconds_clk_last = '0' then    -- seconds clk rising edge
            if player_select_deb = '0' then -- player 0
                if Reg_0 > 0 and (Reg_1>0)then
                    Reg_0 <= Reg_0 - 1;
                else NULL;
                end if;
                Reg_out <= Reg_0;
            elsif player_select_deb = '1' then
                if Reg_1 > 0 and (Reg_0>0) then
                    Reg_1 <= Reg_1 - 1;
                else NULL;
                end if;
                Reg_out <= Reg_1;
            else NULL;
            end if;
        else NULL;
        end if;                    
    else NULL;
    end if; 
    
    player_last <= player_select_deb;
    Seconds_clk_last <= Seconds_clk;
    if player_select_deb = '0' then 
        if input_select ='0' then
            Reg_out <= Reg_0;
        else Reg_out <= ink0;
        end if;
    else 
        if input_select ='0' then
            Reg_out <= Reg_1;
        else Reg_out <= ink1;
        end if;
    end if;        
else NULL;
end if;
end process Sekunde_counter;

-- player switch
Player_led: process(player_select_deb, input_select)
begin
if (player_select_deb='0') then
    LED0 <='1';
    LED1 <='0';
elsif (player_select_deb='1') then
    LED0 <='0';
    LED1 <='1';
else NULL;
end if;
if (input_select='0') then
    LED2 <='1';
    LED3 <='0';
elsif (input_select='1') then
    LED2 <='0';
    LED3 <='1';
else NULL;
end if;
end process Player_led;


 AB_out : process (Reg_out, Display_clk)
	   begin
	   -- output for Time on Display    
	   -- Reg_out / 60 -> Minuten   Min2: Zehner, Min1: Einer
	   -- -> Min2 = Minuten / 10
	   -- -> Min1 = Minuten % 10                          
	   -- Reg_out % 60 -> Sekunden  Sek2: Zehner, Sek1: Einer
	   -- -> Sek2 = Sekunden / 10
	   -- -> Sek1 = Sekunden % 10
	     -- D1 <= resize((Reg_out mod 60) mod 10, 4);

	   D1 <= resize((Reg_out mod 60) mod 10, 4);   -- LSB
	   D2 <= resize((Reg_out mod 60) / 10, 4);
	   D3 <= resize((Reg_out / 60) mod 10, 4);
	   D4 <= resize((Reg_out / 60) / 10, 4);       -- MSB
	   	        
	   end process AB_out;
           
-- multiplexer select signal for 7-segment display
	  MUXCount : process (Display_clk) begin   
	    if (rising_edge(Display_clk)) then
	        if (MUX < 3) then MUX <= MUX + 1;
	          else MUX <= "00"; 
	        end if;          
	    end if;
	  end process MUXCount;
-- Blinker wenn Zeit abgelaufen
    Blink_CLK : process (Clk) 			-- Geschwindigkeit vom Blinken bei abgelauener Zeit
    begin
	   if rising_edge(Clk) then
            if Blink_cnt = Blink_trigger - 1 then
                Blink_cnt <= 0;
                Blink_en  <= not Blink_en;  -- Toggle alle 0,25s
            else
                Blink_cnt <= Blink_cnt + 1;
            end if;
        end if;    
    end process Blink_CLK;    
    
           
-- multiplex and decode to 7-segment display 
    Display_MUX : process (MUX, Display_clk, Reg_out) -- MUX Decoder

	   begin
        if rising_edge(Display_clk) then
            if (Reg_out = "0") and (Blink_en = '0') then
                -- Blink-Phase: alle Segmente aus (0,5s Pause)
                Mux_7_seg <= "1111";
            else
                -- Normal-Phase: MUX durchcyclen
                case MUX is
                    when "00"   => Mux_7_seg <= "1110";
                    when "01"   => Mux_7_seg <= "1101";
                    when "10"   => Mux_7_seg <= "1011";
                    when "11"   => Mux_7_seg <= "0111";
                    when others => Mux_7_seg <= "1111";
                end case;
            end if;
        end if;                           
    end process Display_MUX;
	  
	  DOut_MUX : process (MUX, Display_clk, D1, D2, D3, D4) -- MUX generating DOut 
	  begin 
	    if rising_edge(Display_clk) then 
	     case MUX is   
	       when "00" => DOut <= D1;    -- LSB
	       when "01" => DOut <= D2; 
	       when "10" => DOut <= D3;
	       when "11" => DOut <= D4;    -- MSB
	       when others => NULL;
	     end case;   
	    end if;                       
	  end process DOut_MUX;
	  
	  Display_Decoder : process (DOut) -- decodes DOut to 7-Segm.
	  begin 
	    case DOut is             --  pabcdefg
	      when x"0" => Out_7_seg <= "10000001";
	      when x"1" => Out_7_seg <= "11001111"; 
	      when x"2" => Out_7_seg <= "10010010";
	      when x"3" => Out_7_seg <= "10000110"; 
	      when x"4" => Out_7_seg <= "11001100";
	      when x"5" => Out_7_seg <= "10100100"; 
	      when x"6" => Out_7_seg <= "00100000"; -- punkt an
	      when x"7" => Out_7_seg <= "10001111"; 
	      when x"8" => Out_7_seg <= "10000000";
	      when x"9" => Out_7_seg <= "00000100"; -- punkt an
	      when others => Out_7_seg <= "00110000"; -- E: Error
	    end case;
	  end process Display_Decoder;

end Behavioral;


-- RESET
-- reset =1 -> start_stop=0?
-- wenn 0-> reset
-- wenn 1-> nix

-- ZEIT
-- player reg-> 300 s
-- wenn start_stop =1 -> 300 - zeit
-- wenn zeit=300 -> player reg=0 -> blink whole mux

-- SWITCH
-- wenn player_select =0 -> player reg 1 select -> LED 1 an, reg 1 an anzeige 
-- wenn player select =1 -> player reg 2 select -> led 2 an

-- ANZEIGE
-- anzeige:
-- anfang:  1 0 0 0
-- 1 s:     0 9 5 9

-- 280s
-- 280 / 60=min
--280 % 60= sec
--
