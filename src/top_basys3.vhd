--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(15 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        btnL    :   in std_logic;
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals 	generic (K_DIV : natural := 2);
component clock_divider is
	generic ( constant k_DIV : natural := 2	);
	port ( 	i_clk    : in std_logic;		   -- basys3 clk
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
	);
	end component;
	component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end component;

    component controller_fsm is
    Port ( 
    i_clk : in std_logic;
    i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end component ;
  
  component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
end component;
component button_debounce is 
port( clk : in std_logic;
reset : in std_logic;
button : in std_logic;
action : out std_logic);
end component;


component TDM4 is
	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
end component;

component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end component;
--dignles 
signal w_clk_slow : std_logic;
signal w_cycle : std_logic_vector(3 downto 0);
signal w_regA : std_logic_vector(7 downto 0);
signal w_regB : std_logic_vector(7 downto 0);
signal w_alu_result : std_logic_vector(7 downto 0);
signal w_alu_flags : std_logic_vector(3 downto 0);
signal w_display_val : std_logic_vector(7 downto 0);
signal w_sign : std_logic;
signal w_hundreds : std_logic_vector(3 downto 0);
signal w_tens : std_logic_vector(3 downto 0);
signal w_ones : std_logic_vector(3 downto 0);
signal w_sign_digit : std_logic_vector(3 downto 0);
signal w_tdm_data : std_logic_vector(3 downto 0);
signal w_tdm_sel : std_logic_vector(3 downto 0);
signal w_blank  : std_logic;
signal w_d2 : std_logic_Vector (3 downto 0);

signal w_d1 : std_logic_Vector (3 downto 0);

signal w_d0 : std_logic_Vector (3 downto 0);
signal w_btnC_db : std_logic; 
signal w_btnC_prev :std_logic;
signal w_btnC_pulse :std_logic;
signal w_cycle_prev : std_logic_vector(3 downto 0);
begin
	-- PORT MAPS ----------------------------------------    
debouncer_in : button_debounce
port map( 
	clk => clk,
reset => btnU,
button => btnC,
action => w_btnC_db
);
pulse_proc : process(clk)
begin
if rising_edge(clk) then
w_btnC_prev <= w_btnC_db;
w_btnC_pulse <= w_btnC_db and not w_btnC_prev;
end if;
end process;
clkdiv_in : clock_divider
generic map (k_DIV => 50000 )
    port map(
    i_clk => clk,
    i_reset =>btnL,
    o_clk => w_clk_slow
    );
    fsm_in : controller_fsm
    port map(
    i_clk => CLK,
    i_reset => btnU,
    i_adv => w_btnC_db,
    o_cycle => w_cycle
    );
    alu_in : ALU
    port map(
    i_A => w_regA,
    i_B => w_regB,
    i_op => sw(15 downto 13),
    o_result => w_alu_result,
    o_flags => w_alu_flags
    );
    twoscomp_in : twos_comp
    port map(
    i_bin => w_display_val,
    o_sign => w_sign,
    o_hund => w_hundreds,
    o_tens => w_tens,
    o_ones => w_ones
    );
    
    w_d2 <=  "1110" when w_hundreds = "0000" else w_hundreds;
        w_d1 <=  "1110" when (w_hundreds = "0000" and w_tens = "0000") else w_tens;
            w_d0 <=  w_ones;
    
    
    tdm_in : TDM4
    generic map(k_WIDTH => 4)
    port map (
    i_clk => w_clk_slow,
    i_reset => btnU,
    i_D3 => w_sign_digit,
    i_D2 => w_d2,
    i_D1 => w_d1,
    i_D0 => w_d0,
    o_data => w_tdm_data,
    o_sel => w_tdm_Sel
    );
 seg_in : sevenseg_decoder
 port map( 
 i_Hex => w_tdm_data,
 o_seg_n => seg 
 );
 
 reg_in : process(clk)
 begin
 if rising_edge(clk) then
 w_cycle_prev <= w_cycle;
 if btnU = '1' then
 w_regA <= "00000000";
 w_regB <= "00000000";
 else
 if w_btnC_db ='1' and w_cycle_prev = "0001" then
    w_regA <= sw( 7 downto 0);
    end if;
    if w_btnC_db ='1' and w_cycle_prev = "0010" then
    w_regB <= sw(7 downto 0);
    end if;
    end if;
    end if;
    end process reg_in;
    
    w_blank <= w_cycle(0);
    w_display_val <= sw(7 downto 0) when w_cycle = "0010" else
    sw(7 downto 0) when w_cycle = "0100" else
    w_alu_result when w_cycle = "1000" else
    "00000000";
  
w_sign_digit <= "1111" when w_sign = '1' else "1110";

an <= "1111" when w_blank = '1' else  w_tdm_sel;
	
	-- CONCURRENT STATEMENTS ----------------------------
led(3 downto 0) <= w_cycle;
led(11 downto 4) <= ("00000000");
led(15 downto 12) <= w_alu_flags;

	
	
end top_basys3_arch;
