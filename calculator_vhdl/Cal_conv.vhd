library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Cal_conv is
	generic( N : integer := 5);
	port( clk_i  : in  std_logic;	-- system clock
         rst_i  : in  std_logic; 	-- synchronous reset, active-low
			Start_i : in std_logic;
			
			Operator : in  std_logic_vector (1 downto 0);
			
			sum_add 	: in  std_logic_vector (2*N-1 downto 0);
			sum_sub	: in  std_logic_vector (2*N-1 downto 0);
			
			sum_multi 	: in  std_logic_vector (2*N-1 downto 0);
			sum_div	: in  std_logic_vector (2*N-1 downto 0);
			
			Remainder 	: in  std_logic_vector (N-1 downto 0);
			
			Result_i : out STD_LOGIC_VECTOR (2*N-1 downto 0);
			Remainder_i : out STD_LOGIC_VECTOR (N-1 downto 0);
			
			Input_DONE_add : in std_logic;
			Input_DONE_sub : in std_logic;
			Input_DONE_multi : in std_logic;
			Input_DONE_div : in std_logic;
			
			Output_DONE : out std_logic;

						
			
			a 	: in  std_logic_vector (N-1 downto 0);
			b	: in  std_logic_vector (N-1 downto 0);	
		   BCD_digit_1 : out std_logic_vector (3 downto 0);
		   BCD_digit_2 : out std_logic_vector (3 downto 0);
			BCD_digit_3 : out std_logic_vector (3 downto 0);
		   BCD_digit_4 : out std_logic_vector (3 downto 0);
			BCD_digit_5 : out std_logic_vector (3 downto 0);
		   BCD_digit_6 : out std_logic_vector (3 downto 0)
			);
					  
end Cal_conv;

architecture Behavioral of Cal_conv is
signal int_data_1 : integer := 0;
signal int_data_2 : integer:= 0;
signal int_data_3 : integer := 0;
signal int_data_4 : integer:= 0;
signal int_data_5 : integer := 0;
signal int_data_6 : integer:= 0;

signal data_a : std_logic_vector (N-1 downto 0);	
signal data_b : std_logic_vector (N-1 downto 0);	

signal OP : std_logic_vector (1 downto 0);

signal data_result : std_logic_vector (2*N-1 downto 0);
signal data_remainder : std_logic_vector (N-1 downto 0);

signal data_result_re : std_logic_vector (2*N-1 downto 0);
signal data_remainder_re : std_logic_vector (N-1 downto 0);



signal data_done : std_logic;

type state_type is (s0,get_op);

signal state : state_type := s0;

begin
	process(clk_i, rst_i)
		begin
			if (rst_i='0' ) then  
				int_data_1 <= 0;
				int_data_2 <= 0;
				int_data_3 <= 0;
				int_data_4 <= 0;
				int_data_5 <= 0;
				int_data_6 <= 0;
				
			elsif rising_edge(clk_i) then	
					case state is
						when s0 =>
						int_data_1 <= conv_integer(unsigned(a)) mod 10;
						int_data_2 <= (conv_integer (unsigned(a)) / 10) mod 10;
						int_data_3 <= (conv_integer(unsigned(a))/ 100 ) mod 10 ;
						int_data_4 <= conv_integer(unsigned(b)) mod 10;
						int_data_5 <= (conv_integer (unsigned(b)) / 10) mod 10;
						int_data_6 <= (conv_integer(unsigned(b))/ 100 ) mod 10 ;
							if Start_i = '1' then

									if OP = "11" then 
										data_result <= sum_add;
										data_done <= Input_DONE_add;

									elsif OP = "10" then 
										data_result <= sum_sub;
										data_done <= Input_DONE_sub;
									
									elsif OP = "01" then 
										data_result <= sum_multi;
										data_done <= Input_DONE_multi;
										
									elsif OP = "00" then 
										data_result <= sum_div;
										data_remainder <= Remainder;
										data_done <= Input_DONE_div;
								end if;
								state <= s0;
							else

								data_result <= (others => '0');
								data_remainder <= (others => '0');
								data_done <= '0';
								state <= get_op;
							end if;
							
						when get_op =>
							
							if Start_i = '1' then
								state <= s0;
								OP <= Operator;
							else
								state <= get_op;
							end if;
							
						
						
						when others =>
							state <= s0;
					end case;
				
			
			
			
			
				if data_done = '0' then
					if a(N-1) = '1' then
						data_a <= not a + 1;
					else
						data_a <= a;
					end if;
					
					if b(N-1) = '1' then
						data_b <= not b + 1;
					else
						data_b <= b;
					end if;
					
					if conv_integer(unsigned(data_a)) >= 0 and conv_integer(unsigned(data_a)) < 10 then
						int_data_1 <= conv_integer(unsigned(data_a)) mod 10;
						if a(N-1) = '1' then
							int_data_2 <= 11;
						else
							int_data_2 <= 10;
						end if;
						int_data_3 <= 10;
						
					elsif conv_integer(unsigned(data_a)) >= 10 and conv_integer(unsigned(data_a)) < 16 then
						int_data_1 <= conv_integer(unsigned(data_a)) mod 10;
						int_data_2 <= (conv_integer (unsigned(data_a)) / 10) mod 10;
						if a(N-1) = '1' then
							int_data_3 <= 11;
						else
							int_data_3 <= 10;
						end if;

					end if;
					
					
					if conv_integer(unsigned(data_b)) >= 0 and conv_integer(unsigned(data_b)) < 10 then
						int_data_4 <= conv_integer(unsigned(data_b)) mod 10;
						if b(N-1) = '1' then
							int_data_5 <= 11;
						else
							int_data_5 <= 10;
						end if;
						int_data_6 <= 10;
					elsif conv_integer(unsigned(data_b)) >= 10 and conv_integer(unsigned(data_b)) < 16 then
						int_data_4 <= conv_integer(unsigned(data_b)) mod 10;
						int_data_5 <= (conv_integer (unsigned(data_b)) / 10) mod 10;
						if b(N-1) = '1' then
							int_data_6 <= 11;
						else
							int_data_6 <= 10;
						end if;

					end if;
				else

					if data_result(2*N-1) = '1' then
						data_result_re <= (not data_result) + 1;
					else
						data_result_re <= data_result;
					end if;
					
					if data_remainder(N-1) = '1' then
						data_remainder_re <= (not data_remainder) + 1;
					else 
						data_remainder_re <= data_remainder;
					end if;
	
					
					-- Result
					if conv_integer(unsigned(data_result_re)) = 0 then
						int_data_1 <= 0;
						int_data_2 <= 10;
						int_data_3 <= 10;
					else
						if conv_integer(unsigned(data_result_re)) > 0 and conv_integer(unsigned(data_result_re)) < 10 then
							int_data_1 <= conv_integer(unsigned(data_result_re)) mod 10;
							if data_result(2*N-1) = '1' then
								int_data_2 <= 11;
							else
								int_data_2 <= 10;
							end if;
							int_data_3 <= 10;
						elsif conv_integer(unsigned(data_result_re)) >= 10 and conv_integer(unsigned(data_result_re)) < 100 then
							int_data_1 <= conv_integer(unsigned(data_result_re)) mod 10;
							int_data_2 <= (conv_integer (unsigned(data_result_re)) / 10) mod 10;
							if data_result(2*N-1) = '1' then
								int_data_3 <= 11;
							else
								int_data_3 <= 10;
							end if;
						elsif conv_integer(unsigned(data_result_re)) >= 100 and conv_integer(unsigned(data_result_re)) < 1000 then
							int_data_1 <= conv_integer(unsigned(data_result_re)) mod 10;
							int_data_2 <= (conv_integer (unsigned(data_result_re)) / 10) mod 10;
							int_data_3 <= (conv_integer(unsigned(data_result_re))/ 100 ) mod 10 ;
						end if;
					
						
					end if;
					
					-- Remainder
					if conv_integer(unsigned(data_result_re)) > 100 then
						if data_result(2*N-1) = '1' then
							int_data_4 <= 11;
						else
							int_data_4 <= 10;
						end if;
						int_data_5 <= 10;
						int_data_6 <= 10;
					elsif conv_integer(unsigned(data_remainder_re)) = 0 then
						int_data_4 <= 0;
						int_data_5 <= 10;
						int_data_6 <= 10;
					else
						if conv_integer(unsigned(data_remainder_re)) > 0 and conv_integer(unsigned(data_remainder_re)) < 10 then
							int_data_4 <= conv_integer(unsigned(data_remainder_re)) mod 10;
							int_data_5 <= 10;
							int_data_6 <= 10;
						elsif conv_integer(unsigned(data_remainder_re)) >= 10 and conv_integer(unsigned(data_remainder_re)) < 100 then
							int_data_4 <= conv_integer(unsigned(data_remainder_re)) mod 10;
							int_data_5 <= (conv_integer (unsigned(data_remainder_re)) / 10) mod 10;
							int_data_6 <= 10;
						elsif conv_integer(unsigned(data_remainder_re)) >= 100 and conv_integer(unsigned(data_remainder_re)) < 1000 then
							int_data_4 <= conv_integer(unsigned(data_remainder_re)) mod 10;
							int_data_5 <= (conv_integer (unsigned(data_remainder_re)) / 10) mod 10;
							int_data_6 <= (conv_integer(unsigned(data_remainder_re))/ 100 ) mod 10 ;
						end if;
					end if;

				end if;
				

			end if;
			Result_i <= data_result;
			Remainder_i <= data_remainder;
			Output_DONE <= data_done;
			BCD_digit_1 <= conv_std_logic_vector(int_data_1, 4);
			BCD_digit_2 <= conv_std_logic_vector(int_data_2, 4);
			BCD_digit_3 <= conv_std_logic_vector(int_data_3, 4);
			BCD_digit_4 <= conv_std_logic_vector(int_data_4, 4);
			BCD_digit_5 <= conv_std_logic_vector(int_data_5, 4);
			BCD_digit_6 <= conv_std_logic_vector(int_data_6, 4);
					
	end process;
		
end Behavioral;