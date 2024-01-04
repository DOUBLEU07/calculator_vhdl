library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.STD_LOGIC_UNSIGNED.all;


entity Binary_add_and_subt is
	generic( N : integer := 5);
	port( CLK_i,RST_i,START_i : in std_logic;
			addORsub : in std_logic;
			A: in  std_logic_vector (N-1 downto 0);
			B: in  std_logic_vector (N-1 downto 0);
			S : out  std_logic_vector (2*N-1 downto 0);
			Overflow, DONE: out std_logic);
end Binary_add_and_subt;

architecture structural of Binary_add_and_subt is
	
	type state_type is (s0,s1,s2);
	signal state : state_type := s0;
	signal Data_A : std_logic_vector(N-1 downto 0);
	signal Data_B : std_logic_vector(N-1 downto 0);
	signal result : std_logic_vector(2*N-1 downto 0);
	signal cout : std_logic_vector(N downto 0);
	

begin
	process (RST_i, CLK_i, START_i)

	begin
		if RST_i = '0' then
			state <= s0;
			S <= (others => '0');
			cout <= (others => '0');
			DONE <= '0';
			overflow <= '0';
		elsif rising_edge(CLK_i) then
			case state is 
				when s0 =>
				
					if START_i ='0' then
						
							if A(N-1) = '1' and addORsub = '1' then
								Data_A <= not A + 1;
							else
								Data_A <= A; 
							end if;

							if B(N-1) = '1' and addORsub = '1' then
								Data_B <= not B + 1;
							else
								Data_B <= B; 
							end if;
							
						S <= (others => '0');
						Overflow <= '0';
						DONE <= '0';
						state <= s1;
					else
						state <= s0;
					end if;
					
				when s1 =>
					cout(0) <= addORsub;
					for i in 0 to N-1 loop
						result(i) <= (Data_A(i) xor Data_B(i)) xor cout(i);
						cout(i+1) <= ((Data_A(i) xor Data_B(i)) and cout(i)) or (Data_A(i) and Data_B(i));
					end loop;
					state <= s2;
					
				when s2 => 
					if START_i ='1' then
						if A(N-1) = '1' and B(N-1) = '1' then
							S <= result + 1;
						
						elsif A(N-1) = '1' and addORsub = '0'  then
							S <= not result + 1;
						elsif A(N-1) = '1' and addORsub = '1' then
							S <= result;
							
						elsif B(N-1) = '1' and addORsub = '0' then
							S <= not result + 1;	
						elsif B(N-1) = '1' and addORsub = '1' then
							S <= result;
						else
							S <= result;
						end if;
						
						overflow <= cout(N) xor cout(N-1);
						DONE <= '1';
						state <= s0;
					else
						state <= s2;
					end if;

				when others =>
					state <= s0;
			end case;
		end if;
	end process;
		
end structural;
			