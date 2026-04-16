--------------------------------------------------------------------------
--- Chess_Clock
--- Solution for MIMAS V2 Board from Numato
--- Author: Klaus Gosger
---
--- Please note: this code needs adaptation when used on other boards!
---
--------------------------------------------------------------------------  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity Chess_Clock is  
 Port (RS         : in   std_logic;     -- Reset (active low)
       Clk        : in   std_logic;    -- Serial clock ? MHz
       AB         : in   std_logic;    -- DP Switch  
       StartStop  : in   std_logic;    -- Stop Clock = 0, Continue = 1
       DigitOut   : out  std_logic_vector (7 downto 0); -- One Segment 
       MUXOut     : out  std_logic_vector (2 downto 0));-- Select Segemnt
end Chess_Clock;

architecture RTL of Chess_Clock is

	-- internal signals and variables
	signal Dis_Clk : std_logic := '0'; -- display clock 
	signal Sec_Clk : std_logic := '0'; -- clock in seconds
	signal D1, D2, D3, DOut : std_logic_vector (3 downto 0):= (others => '0'); 
	        -- minutes (D3) and seconds (D2_1) as output to the display 
	signal DCnt : unsigned (15 downto 0):= (others=>'0');  -- counter for Dis_Clk
	signal SCnt : unsigned (7 downto 0):= (others=>'0');   -- counter for Sec_Clk
	signal MUX  : unsigned (1 downto 0):= (others=>'0');   -- Select Signal for MUX and Decoding of Digits     
	    
	signal A1, A2, A3 : unsigned (3 downto 0):= (others=>'0'); 
	    -- minutes (4_3) and seconds (2_1) Player A
	signal B1, B2, B3 : unsigned (3 downto 0):= (others=>'0'); 
	    -- minutes (4_3) and seconds (2_1)  Player B
	
	begin
  
      Dis_Clk <= Clk; -- consider Clk as Display clock for tests in simulation 
                          -- needs to be solved different in code for synthesis
  
	  Seconds : process (Dis_Clk, StartStop) begin
	    if (rising_edge(Dis_Clk) and (StartStop = '1')) then
	         if (SCnt < 50) then SCnt <= SCnt + 1;  
	          else 
	              SCnt <= "00000000";
	              Sec_Clk <= not Sec_Clk;
	          end if;  
	      end if;
	  end process Seconds;  
	 
	  -- counter for players A and B
	  AB_count : process (Sec_Clk, AB, StartStop, RS)
	  begin
	  case AB is
	  when '1' =>  -- counting for A
	     if (rising_edge(Sec_Clk) and StartStop = '1') then            
	         if (A1 < "1001") then
	              A1 <=(A1 + 1); 
	           else 
	              A1 <= "0000"; 
	              if A2 < "0101" then
	                 A2 <= (A2 + 1);    
	                 else A2<="0000"; 
	                   if A3 < "1001" then
	                   A3 <= (A3 + 1);
	                   else A3 <="0000";
	                   end if;
	              end if;
	          end if;
	     end if;
	    when others =>   -- counting for B
	     if (rising_edge(Sec_Clk) and StartStop = '1') then              
	         if (B1 < "1001") then
	              B1 <=(B1 + 1); 
	           else 
	              B1 <= "0000"; 
	              if B2 < "0101" then
	                 B2 <= (B2 + 1);    
	                 else B2<="0000"; 
	                   if B3 < "1001" then
	                   B3 <= (B3 + 1);
	                   else B3 <="0000";
	                   end if;
	              end if;
	          end if;
	     end if;                                  
	    end case;   
	   end process AB_count;   
	  
	  -- output mux 
	   AB_out : process (A1,A2,A3,B1,B2,B3,AB)
	   begin
	     case AB is
	          when '1' =>                     -- output for A  
	            D1 <= std_logic_vector(A1); D2 <= std_logic_vector(A2); D3 <= std_logic_vector(A3); -- output counter A
	          when others =>                     -- output for B
	            D1 <= std_logic_vector(B1); D2 <= std_logic_vector(B2); D3 <= std_logic_vector(B3); -- output counter B
	     end case; 
	   end process AB_out;
	  
	  -- multiplexer select signal for 7-segment display
	  MUXCount : process (Dis_Clk) begin   
	    if (rising_edge(Dis_Clk)) then
	        if (MUX < 2) then MUX <= MUX + 1;
	          else MUX <= "00"; 
	        end if;          
	    end if;
	  end process MUXCount;
	  
	  -- multiplex and decode to 7-segment display 
	  Display_MUX : process (MUX, Dis_Clk) -- MUX Decoder
	  begin 
	    if rising_edge(Dis_Clk) then
	     case MUX is   
	       when "00" => MUXOut <= "110"; -- drive segment S3 via Enable 3 
	       when "01" => MUXOut <= "101"; -- drive segment S2 via Enable 2  
	       when "10" => MUXOut <= "011"; -- drive segment S1 via Enable 1 
	       when others => MUXOut <= "111";
	     end case;                          
	    end if;
	  end process Display_MUX;    
	  
	  DOut_MUX : process (MUX, Dis_Clk,D1, D2, D3) -- MUX generating DOut 
	  begin 
	    if rising_edge(Dis_Clk) then 
	     case MUX is   
	       when "00" => DOut <= D1;
	       when "01" => DOut <= D2; 
	       when "10" => DOut <= D3; 
	       when others => NULL;
	     end case;   
	    end if;                       
	  end process DOut_MUX;
	  
	  Display_Decoder : process (DOut) -- decodes DOut to 7-Segm.
	  begin 
	    case DOut is            --  pabcdefg
	      when x"0" => DigitOut <= "10000001";
	      when x"1" => DigitOut <= "11001111"; 
	      when x"2" => DigitOut <= "10010010";
	      when x"3" => DigitOut <= "10000110"; 
	      when x"4" => DigitOut <= "11001100";
	      when x"5" => DigitOut <= "10100100"; 
	      when x"6" => DigitOut <= "00100000"; -- punkt an
	      when x"7" => DigitOut <= "10001111"; 
	      when x"8" => DigitOut <= "10000000";
	      when x"9" => DigitOut <= "00000100"; -- punkt an
	      when others => DigitOut <= "00110000"; -- E: Error
	    end case;
	  end process Display_Decoder;

end RTL;
