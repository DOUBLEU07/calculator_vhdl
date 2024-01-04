library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity division is
	generic (N:integer := 5);
	port (CLK_i, RST_i, START_i :in std_logic;
			A,B :in std_logic_vector(N-1 downto 0):= (others => '0');
			Quotient :out std_logic_vector(2*N-1 downto 0):= (others => '0');
			Remainder :out std_logic_vector(N-1 downto 0):= (others => '0');
			DONE:out std_logic := '0';
			overflow : out std_logic);
	end division;
	
architecture data_flow of division is
	type state_type is (s0,s1,s2,s3);
	signal Data_A :std_logic_vector(2*N-1 downto 0):=(others => '0');
	signal Data_B :std_logic_vector(2*N-1 downto 0):=(others => '0');
	signal Data_Q :std_logic_vector(2*N-1 downto 0):=(others => '0');
	signal overflow_check : std_logic := '0';
	signal check_neg : std_logic := '0';
	signal bit_counter : integer := 0;
	signal state : state_type := s0;
	signal S_Start : std_logic := '0';
	
	begin
		S_Start <= START_i;
		
		process (RST_i, CLK_i, START_i)
		begin
			if RST_i = '0' then
				state <= S0;
				Data_A <= (others => '0');
				Data_B <= (others => '0');
				Data_Q <= (others => '0');
				Quotient <= (others => '0');
				Remainder <= (others => '0');
				DONE <= '0';
				overflow <= '0';
				
			elsif rising_edge(CLK_i) then
				case state is
					
					when S0 =>
						if S_Start = '0' then
						

						
							
							if A(N-1) = '1' then
								Data_A (N-1 downto 0) <= not A + 1; 
							else
								Data_A (N-1 downto 0) <= A; 
							end if;

							if B(N-1) = '1' then
								Data_B (2*N-1 downto N) <= not B + 1;
							else
								Data_B (2*N-1 downto N) <= B; 
							end if;
							
							
							
							Quotient  <= (others => '0');
							Remainder  <= (others => '0');
							overflow <= '0';
							DONE <= '0';
							
							state <= s1;
						else
							state <= s0;
						end if;
						
					when s1 => 
						if (bit_counter < (N+1)) then
							if check_neg = '0' then
							
								Data_A <= Data_A - Data_B;
								check_neg <= '1';
							else
								if Data_A(2*N-1) = '0' then
								
									Data_Q <= std_logic_vector(shift_left(unsigned(Data_Q),1));
									Data_Q(0) <= '1';	
								else 
								
									Data_A <= Data_B + Data_A;
									Data_Q <= std_logic_vector(shift_left(unsigned(Data_Q),1));
								end if;
								Data_B <= std_logic_vector(shift_right(unsigned(Data_B),1));
								bit_counter <= bit_counter + 1;
								check_neg <= '0';
							end if;
						else 
						
							if (A(N-1) xor B(N-1)) = '1' then
								Data_Q <= not Data_Q + 1;
							end if;
							if A(N-1) = '1' then
								Data_A <= not Data_A + 1;
							end if;
						
							bit_counter <= 0;
							state <= s2;
						end if;
						
					when s2 =>  
						if ((bit_counter < N) and (overflow_check = '0')) then 
						
							overflow_check <= Data_Q(N+bit_counter) xor Data_Q(N-1+bit_counter);
							bit_counter <= bit_counter + 1;
						else
						
							state <= s3;
						end if;
						
					when s3 =>		
						if S_Start ='0' then
							state <= s3;
						else
							Quotient <= Data_Q;
							Remainder <= Data_A(N-1 downto 0);
							overflow <= overflow_check;
							overflow_check <='0';
							Data_Q <= (others => '0');
							Data_A <=(others => '0');
							Data_B <=(others => '0');
							bit_counter <= 0;
							state <= s0;
							DONE <= '1';
						end if;
						
					when others =>
						state <= S0;
				end case;
			end if;
		end process;
end data_flow;