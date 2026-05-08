----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_clk : in std_logic;
    i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    
    constant s0 : std_logic_Vector(3 downto 0) := "0001";
        constant s1 : std_logic_Vector(3 downto 0) := "0010";    
        constant s2 : std_logic_Vector(3 downto 0) := "0100";
            constant s3 : std_logic_Vector(3 downto 0) := "1000";
    signal f_state : std_logic_vector(3 downto 0) := s0;
        
begin

state_reg : process(i_clk)
begin
     if rising_Edge(i_clk) then
     if i_reset ='1' then
     f_state <=s0;
     elsif i_adv ='1' then 
     if f_state = s0 then 
     f_state <=s1;
     elsif f_state = s1 then 
     f_state <=s2;
     elsif f_State =s2 then 
     f_state <= s3;
     elsif f_state =s3 then
     f_state <= s0;
     else 
     f_state <= s0;
     end if;
     end if;
     end if;
   end process state_reg;
   o_cycle <= f_state; 

end FSM;
