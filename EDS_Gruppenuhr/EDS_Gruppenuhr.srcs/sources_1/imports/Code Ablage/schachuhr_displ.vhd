library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity schachuhr_displ is
port (  Reg_out     : in unsigned (12 downto 0);
        Display_clk : in std_logic;
        Seconds_clk : in std_logic;
        Out_7_seg   : out std_logic_vector(7 downto 0));
end schachuhr_displ;

architecture Behavioral of schachuhr_displ is
-- internal signals and variables
constant Blink_trigger : integer := 100; -- 100 MHz -> 10 us 
signal Blink_en     : std_logic := '1';
signal Blink_cnt    : integer range 0 to Blink_trigger - 1 := 0; 


signal MUX  : unsigned (1 downto 0):= (others=>'0');
signal Mux_7_seg: std_logic_vector(3 downto 0);
signal D1, D2, D3, D4, DOut : unsigned (3 downto 0):= (others => '0');

signal D_help : unsigned (12 downto 0);

begin                     
-- output mux 
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
    Blink_CLK : process (Display_clk) 			-- Geschwindigkeit vom Blinken bei abgelauener Zeit
    begin
	   if rising_edge(Display_clk) then
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
                -- (auch wenn Reg_out /= 0 immer aktiv)
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
