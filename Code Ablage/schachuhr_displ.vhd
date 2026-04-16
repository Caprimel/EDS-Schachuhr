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
signal ink0 : std_logic_vector(7 downto 0):= "00000011";
signal ink1 : std_logic_vector(7 downto 0):= "00000011";

begin
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

                         
-- output mux 
	   AB_out : process (Reg_out)
	   begin
	   -- output for Time on Display    
	   -- 280s / 60 -> Minuten   Min2: Zehner, Min1: Einer
	   -- -> Min2 = Minuten / 10
	   -- -> Min1 = Minuten % 10                          
	   -- 280s % 60 -> Sekunden  Sek2: Zehner, Sek1: Einer
	   -- -> Sek2 = Sekunden / 10
	   -- -> Sek1 = Sekunden % 10
	     D1 <= (Reg_out % 60) % 10; 
	     D2 <= (Reg_out % 60) / 10; 
	     D3 <= (Reg_out / 60) % 10;
	     D4 <= (Reg_out / 60) / 10;     
	   end process AB_out;
           
-- multiplexer select signal for 7-segment display
	  MUXCount : process (Dis_Clk) begin   
	    if (rising_edge(Dis_Clk)) then
	        if (MUX < 3) then MUX <= MUX + 1;
	          else MUX <= "00"; 
	        end if;          
	    end if;
	  end process MUXCount;
           
-- multiplex and decode to 7-segment display 
	  Display_MUX : process (MUX, Display_Clk, Seconds_clk, Reg_out) -- MUX Decoder
	  begin  
	  	case Reg_out is
	  	when "0" =>
	  		if rising_edge(Seconds_clk) then
	  	    	if rising_edge(Display_clk) then
	     			case MUX is        
	       			when "00" => Mux_7_seg <= "1110"; -- drive segment S4 via Enable 4
	       			when "01" => Mux_7_seg <= "1101"; -- drive segment S3 via Enable 3 
	       			when "10" => Mux_7_seg <= "1011"; -- drive segment S2 via Enable 2  
	       			when "11" => Mux_7_seg <= "0111"; -- drive segment S1 via Enable 1 
	       			when others => Mux_7_seg <= "1111";
	     		end case;
	    	end case;
	  	when others =>
	    	if rising_edge(Display_clk) then
	     		case MUX is        
	       		when "00" => Mux_7_seg <= "1110"; -- drive segment S4 via Enable 4
	       		when "01" => Mux_7_seg <= "1101"; -- drive segment S3 via Enable 3 
	       		when "10" => Mux_7_seg <= "1011"; -- drive segment S2 via Enable 2  
	       		when "11" => Mux_7_seg <= "0111"; -- drive segment S1 via Enable 1 
	       		when others => Mux_7_seg <= "1111";
	     	end case;     
	     end case;                     
	    end if;
	  end process Display_MUX;    
	  
	  DOut_MUX : process (MUX, Display_clk, D1, D2, D3, D4) -- MUX generating DOut 
	  begin 
	    if rising_edge(Display_clk) then 
	     case MUX is   
	       when "00" => DOut <= D1;
	       when "01" => DOut <= D2; 
	       when "10" => DOut <= D3;
	       when "11" => DOut <= D4;
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
