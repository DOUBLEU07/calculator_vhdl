library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity Calculator is 
	generic( N : integer := 5);
	port( CLK_i, RST_i, START_i : in std_logic;
			A_i, B_i : in std_logic_vector(N-1 downto 0) := (others => '0');
			Result_i : out std_logic_vector(2*N-1 downto 0) := (others => '0');
			Remainder_i : out std_logic_vector(N-1 downto 0) := (others => '0');
			DONE_i : out std_logic ;
			seven_seg_digit_1 : out std_logic_vector (6 downto 0);
			seven_seg_digit_2 : out std_logic_vector (6 downto 0); 
			seven_seg_digit_3 : out std_logic_vector (6 downto 0);
			seven_seg_digit_4 : out std_logic_vector (6 downto 0);
			seven_seg_digit_5 : out std_logic_vector (6 downto 0);
			seven_seg_digit_6 : out std_logic_vector (6 downto 0));
end Calculator;

architecture structural of Calculator is


	component Binary_add_and_subt is
	generic( N : integer := 5);
	port( CLK_i,RST_i,START_i : in std_logic;
			addORsub : in std_logic;
			A: in  std_logic_vector (N-1 downto 0);
			B: in  std_logic_vector (N-1 downto 0);
			S : out  std_logic_vector (2*N-1 downto 0);
			Overflow, DONE: out std_logic);
	end component;
	
	
	component multiplication is
	generic( N : integer := 5);
	port( CLK_i,RST_i,START_i : in std_logic;
		  A,B : in std_logic_vector(N-1 downto 0) := (others => '0');
		  Result : out std_logic_vector(2*N-1 downto 0):= (others => '0');
		  DONE : out std_logic := '0';
		  overflow : out std_logic := '0');
	end component;
	
	component division is
	generic( N : integer := 5);
	port(CLK_i, RST_i, START_i :in std_logic;
			A,B :in std_logic_vector(N-1 downto 0):= (others => '0');
			Quotient :out std_logic_vector(2*N-1 downto 0):= (others => '0');
			Remainder :out std_logic_vector(N-1 downto 0):= (others => '0');
			DONE:out std_logic := '0';
			overflow : out std_logic);
	end component;
	
	
	

	type state_type is (s0,s1,s2,s3,s4,s5,s6,get_op);
	
	--addsub's data
	signal Over_add :std_logic;
	signal Over_sub :std_logic;
	signal cout :std_logic;
	signal sum_add :std_logic_vector(2*N-1 downto 0) := (others => '0');
	signal sum_sub :std_logic_vector(2*N-1 downto 0) := (others => '0');
	signal Data_Done_add : std_logic ;
	signal Data_Done_sub : std_logic ;
	
	--multipli's data
	signal Data_Poduct : std_logic_vector(2*N-1 downto 0) := (others => '0');
	signal Over_Multi :std_logic;
	signal Data_Done_Multi : std_logic ;
	
	--division's data
	signal Re : std_logic_vector(N-1 downto 0) := (others => '0');
	signal Quotient : std_logic_vector(2*N-1 downto 0) := (others => '0');
	signal Over_Div :std_logic;
	signal Data_Done_div : std_logic ;
	
	signal BCD_data_digit_1 : std_logic_vector (3 downto 0);
	signal BCD_data_digit_2 : std_logic_vector (3 downto 0);
	signal BCD_data_digit_3 : std_logic_vector (3 downto 0);
	signal BCD_data_digit_4 : std_logic_vector (3 downto 0);
	signal BCD_data_digit_5 : std_logic_vector (3 downto 0);
	signal BCD_data_digit_6 : std_logic_vector (3 downto 0);

	

begin
	
	addder:Binary_add_and_subt generic map ( N => 5)
										port map(CLK_i => CLK_i,
													RST_i => RST_i,
													START_i => Start_i,
													addORsub => '1',
													A => A_i,
													B => B_i,
													S => sum_add,
													DONE => Data_Done_add,
													Overflow => Over_add);

													
	subt:Binary_add_and_subt generic map ( N => 5)
									port map(CLK_i => CLK_i,
												RST_i => RST_i,
												START_i => Start_i,
												addORsub => '0',
												A => A_i,
												B => B_i,
												S => sum_sub,
												DONE => Data_Done_sub,
												Overflow => Over_sub);
												
												
	multi : multiplication generic map ( N => 5)
					port map(
						CLK_i => CLK_i,
						RST_i => RST_i,
						START_i => Start_i,
						A => A_i,
						B => B_i,
						Result => Data_Poduct,
						DONE => Data_Done_Multi,
						overflow => Over_Multi);
								
	div	:	division generic map ( N => 5)
					port map(
						CLK_i => CLK_i,
						RST_i => RST_i,
						START_i => Start_i,
						A => A_i,
						B => B_i,
						Quotient => Quotient,
						Remainder => Re,
						DONE => Data_Done_Div,
						overflow => Over_Div);
												
	
	Cal_Converter:entity work.Cal_conv(Behavioral)
				  port map(clk_i => CLK_i, 
							  rst_i => RST_i,
							  Start_i => START_i,
							  
							  Operator => A_i(1 downto 0),
							  
							  sum_add => sum_add,	
							  sum_sub => sum_sub,
							  
							  sum_multi => Data_Poduct,	
							  
							  sum_div => Quotient,
							  
							  Remainder => Re,
							  
							  Result_i => Result_i,
							  Remainder_i => Remainder_i,
							  
							  Input_DONE_add => Data_Done_add,
							  Input_DONE_sub => Data_Done_sub,
							  Input_DONE_Multi => Data_Done_Multi,
							  Input_DONE_Div => Data_Done_Div,
							  
							  Output_DONE => DONE_i,

							 

							  a => A_i,
							  b => B_i,
							  BCD_digit_1 => BCD_data_digit_1,
							  BCD_digit_2 => BCD_data_digit_2,
							  BCD_digit_3 => BCD_data_digit_3,
							  BCD_digit_4 => BCD_data_digit_4,
							  BCD_digit_5 => BCD_data_digit_5,
							  BCD_digit_6 => BCD_data_digit_6 );
								  
	seven_seg_display_1: entity work.Cal_BCD_to_SevSeg(data_process)
								port map(
										clk_i => CLK_i,
										BCD_i  => BCD_data_digit_1,
										seven_seg  => seven_seg_digit_1 );
										
	seven_seg_display_2: entity work.Cal_BCD_to_SevSeg(data_process)
								port map(
										clk_i => CLK_i,
										BCD_i  => BCD_data_digit_2,
										seven_seg  =>seven_seg_digit_2 );
										
	seven_seg_display_3: entity work.Cal_BCD_to_SevSeg(data_process)
									port map(
										clk_i => CLK_i,
										BCD_i  => BCD_data_digit_3,
										seven_seg  =>seven_seg_digit_3 );
										
	seven_seg_display_4: entity work.Cal_BCD_to_SevSeg(data_process)
									port map(
										clk_i => CLK_i,
										BCD_i  => BCD_data_digit_4,
										seven_seg  =>seven_seg_digit_4 );
										
	seven_seg_display_5: entity work.Cal_BCD_to_SevSeg(data_process)
									port map(
										clk_i => CLK_i,
										BCD_i  => BCD_data_digit_5,
										seven_seg  =>seven_seg_digit_5 );
										
	seven_seg_display_6: entity work.Cal_BCD_to_SevSeg(data_process)
									port map(
										clk_i => CLK_i,
										BCD_i  => BCD_data_digit_6,
										seven_seg  =>seven_seg_digit_6 );
end structural;
					