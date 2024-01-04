library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplication is 
	generic (N : integer := 5);
	port ( CLK_i,RST_i,START_i : in std_logic;
			  A,B : in std_logic_vector(N-1 downto 0) := (others => '0');
			  Result : out std_logic_vector(2*N-1 downto 0):= (others => '0');
			  DONE : out std_logic := '0';
			  overflow : out std_logic := '0');
end multiplication;

architecture Behave of multiplication is 
	type state_type is (s0,s1,s2,s3);
	signal Data_A :std_logic_vector(2*N-1 downto 0):= (others => '0'); 
	signal Data_B :std_logic_vector(N-1 downto 0):= (others => '0');	
	signal Data_Product :std_logic_vector(2*N-1 downto 0):= (others => '0'); 
	signal overflow_check : std_logic := '0'; 
	signal bit_counter : integer := 0; 
	signal state : state_type := s0;		
	signal S_Start : std_logic := '0'; 

	begin 
		S_Start <= START_i;
		
		process (RST_i, CLK_i, START_i)
		begin 
			if RST_i ='0' then -- reset
				state <= s0;
				Data_A <= (others => '0');
				Data_B <= (others => '0');
				Data_Product <= (others => '0');
				Result  <= (others => '0');
				DONE <= '0';
				overflow <= '0';
			elsif rising_edge(CLK_i) then
				case state is 
					
					when s0 =>  -- Get Data A and Data B
						if S_Start ='0' then
							
							if A(N-1) = '1' and B(N-1) = '1' then
								Data_A(N-1 downto 0) <= A;
								
								Data_B <= not B + 1;


							elsif A(N-1) = '1' and B(N-1) = '0' then
								Data_A(N-1 downto 0) <= A;
								Data_A(2*N-1 downto N) <= (others => '1');
								Data_B <= B;
								
							elsif A(N-1) = '0' and B(N-1) = '1' then
								Data_A(N-1 downto 0) <= A;
								Data_B <= not B + 1;
							else
								Data_A(N-1 downto 0) <= A ;
								Data_A(2*N-1 downto N) <= (others => '0') ;
								Data_B <= B;
							end if;
							
							Result  <= (others => '0');
							overflow <= '0';
							DONE <= '0';

							state <= s1;					
						else

							state <= s0;
						end if;
					
					when s1 =>  -- Multiple Process
						if (bit_counter < N) then
							if Data_B(bit_counter) ='1' then
								Data_Product <= Data_Product + Data_A;
								Data_A <= std_logic_vector(shift_left(unsigned(Data_A), 1)); --shift_Left Data_A 1 bit
								bit_counter <= (bit_counter+1);
							else
								Data_A <= std_logic_vector(shift_left(unsigned(Data_A), 1)); --shift_Left Data_A 1 bit
								bit_counter <= (bit_counter+1);
							end if;
						else
							
							if (A(N-1) xor B(N-1)) = '1' then 
								Data_Product <= not Data_Product + 1; 
							end if;
							
							bit_counter <= 0;
							state <= s2;
						end if;
					
					when s2 => 
						if ((bit_counter < N) and (overflow_check = '0')) then 
						
							overflow_check <= Data_Product(N+bit_counter) xor Data_Product(N-1+bit_counter);
							bit_counter <= bit_counter + 1;
						else
						
							state <= s3;
						end if;
					
					when s3 =>	

						if S_Start ='0' then
							state <= s3;
						else
							Result <= Data_Product;
							overflow <= overflow_check;
							overflow_check <= '0';
							Data_Product <= (others => '0');
							Data_A <=(others => '0');
							Data_B <=(others => '0');
							bit_counter <= 0;
							DONE <= '1';
							state <= s0;
						end if;
					
					when others =>
						state <= S0;
						
				end case;
			end if;
			
			
		end process;
end Behave;