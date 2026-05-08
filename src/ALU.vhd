----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

component ripple_adder is
Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC);
       end component;
       
signal w_result_add : std_logic_vector (8 downto 0);

signal w_result_sub : std_logic_vector (8 downto 0);
signal w_result : std_logic_vector (7 downto 0);
signal w_negative :Std_logic;
signal w_overflow :Std_logic;
signal w_zero :Std_logic;
signal w_carry :Std_logic;

signal w_add_s : std_logic_vector (7 downto 0);
signal w_add_c_mid : std_logic;
signal w_add_cout : std_logic;

signal w_B_inv : std_logic_vector (7 downto 0);
signal w_sub_s : std_logic_vector (7 downto 0);
signal w_sub_c_mid : std_logic;
signal w_sub_cout : std_logic;


begin
   w_B_inv <= not i_B;
   add_low : ripple_adder
   port map(
   A => i_A (3 downto 0),
   b => i_B (3 downto 0),
   Cin => '0',
   S => w_add_s(3 downto 0),
   Cout => w_add_c_mid
   );
   add_high : ripple_adder
   port map(
      A => i_A (7 downto 4),
   B => i_B (7 downto 4),
   Cin =>w_add_c_mid,
   S => w_add_s(7 downto 4),
   Cout => w_add_cout
   );
   sub_low : ripple_adder
   port map(
      A => i_A (3 downto 0),
   B => w_B_inv (3 downto 0),
   Cin => '1',
   S => w_sub_s(3 downto 0),
   Cout => w_sub_c_mid
   );
      sub_high : ripple_adder
   port map(
      A => i_A (7 downto 4),
   B => w_B_inv (7 downto 4),
   Cin => w_sub_c_mid,
   S => w_sub_s(7 downto 4),
   Cout => w_sub_cout
   );
    process(i_op, w_add_s, w_sub_s, i_A, i_B)
    begin 
    if i_op = "000" then
            w_result <= w_add_s;
    elsif i_op = "001" then
            w_result <= w_sub_s;
    elsif i_op = "010" then
            w_result <=i_A AND i_B;
    elsif i_op = "011" then
            w_result <=i_A OR i_B;
    else
        w_result <= "00000000";
    end if;
    end process;

o_result <= w_result;
w_zero <= '1' when w_result = x"00" else '0';
w_negative <= w_result(7);

w_carry<= w_add_cout when i_op = "000" else
           w_sub_cout when i_op = "001" else
           '0';
 w_overflow <=
 (NOT i_A(7) AND NOT i_B(7) AND w_result(7))
 OR(i_A(7) AND i_B(7) AND NOT w_result(7))
 when i_op ="000" else
 (not i_A(7) AND i_B(7) AND w_result(7))
 or (i_A(7) AND NOT i_B(7) AND NOT w_result(7))
 when i_op = "001" else
 '0';
o_flags <= w_negative & w_overflow & w_zero & w_carry;
end Behavioral;
