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
signal MUX  : unsigned (1 downto 0):= (others=>'0');
signal Mux_7_seg: std_logic_vector(3 downto 0);
signal D1, D2, D3, D4, DOut : unsigned (3 downto 0):= (others => '0');

signal D_help : unsigned (12 downto 0);

--type help is array (4 downto 1) of unsigned (12 downto 0);


begin                     
-- output mux 
	   AB_out : process (Reg_out, Display_clk)
--	   variable D_help : help;
	   begin
	   -- output for Time on Display    
	   -- 280s / 60 -> Minuten   Min2: Zehner, Min1: Einer
	   -- -> Min2 = Minuten / 10
	   -- -> Min1 = Minuten % 10                          
	   -- 280s % 60 -> Sekunden  Sek2: Zehner, Sek1: Einer
	   -- -> Sek2 = Sekunden / 10
	   -- -> Sek1 = Sekunden % 10
	     -- D1 <= resize((Reg_out mod 60) mod 10, 4);
	   
--	   D_help <= (Reg_out mod 60) mod 10;
--	   D1 <= D_help (3 downto 0); 
--	   D_help <= (Reg_out mod 60) / 10; 
--	   D2 <= D_help (3 downto 0);
--	   D_help <= (Reg_out / 60) mod 10;
--	   D3 <= D_help (3 downto 0);
--	   D_help <= (Reg_out / 60) / 10;
--	   D4 <= D_help (3 downto 0);
	   
--	   D_help(1) := (Reg_out mod 60) mod 10;
--	   D1 <= D_help(1) (3 downto 0); 
--	   D_help(2) := (Reg_out mod 60) / 10; 
--	   D2 <= D_help(2) (3 downto 0);
--	   D_help(3) := (Reg_out / 60) mod 10;
--	   D3 <= D_help(3) (3 downto 0);
--	   D_help(4) := (Reg_out / 60) / 10;
--	   D4 <= D_help(4) (3 downto 0);
	     
	   D1 <= resize((Reg_out mod 60) mod 10, 4);
	   D2 <= resize((Reg_out mod 60) / 10, 4);
	   D3 <= resize((Reg_out / 60) mod 10, 4);
	   D4 <= resize((Reg_out / 60) / 10, 4);
	   
	   
	        
	   end process AB_out;
           
-- multiplexer select signal for 7-segment display
	  MUXCount : process (Display_clk) begin   
	    if (rising_edge(Display_clk)) then
	        if (MUX < 3) then MUX <= MUX + 1;
	          else MUX <= "00"; 
	        end if;          
	    end if;
	  end process MUXCount;
           
-- multiplex and decode to 7-segment display 
	  Display_MUX : process (MUX, Display_clk) -- MUX Decoder
	  begin 
	    if rising_edge(Display_clk) then
	     case MUX is
	       when "00" => Mux_7_seg <= "1110"; -- drive segment S4 via Enable 4
	       when "01" => Mux_7_seg <= "1101"; -- drive segment S3 via Enable 3 
	       when "10" => Mux_7_seg <= "1011"; -- drive segment S2 via Enable 2  
	       when "11" => Mux_7_seg <= "0111"; -- drive segment S1 via Enable 1 
	       when others => Mux_7_seg <= "1111";
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
