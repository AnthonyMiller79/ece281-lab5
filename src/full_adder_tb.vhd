-- Testbench for full_adder.vhd

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity full_adder_tb is
end full_adder_tb;

architecture test_bench of full_adder_tb is 

	-- Component Declaration	
    component full_adder is
        port (
            A     : in std_logic;
            B     : in std_logic;
            Cin   : in std_logic;
            S     : out std_logic;
            Cout  : out std_logic
            );
        end component full_adder;	

  -- These signals will be wired to match full adder truth table
  -- https://usafa-ece.github.io/ece281-book/ICE/ICE3.html#full-adder-truth
  signal w_in   : std_logic_vector(2 downto 0);
  signal w_out  : std_logic_vector(1 downto 0); 
    
begin
	-- PORT MAPS ----------------------------------------
   full_adder_uut: full_adder
    port map(
        A     => w_in(1),
        B     => w_in(0),
        Cin   => w_in(2),
        S     => w_out(0),
        Cout  => w_out(1)
    );

	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
	-- Test plan process
	-- Testing each combination of i_A and i_B (4 total)
	test_process : process 
	begin
        -- Octal test cases based on full adder truth table
        -- https://usafa-ece.github.io/ece281-book/ICE/ICE3.html#full-adder-truth
        w_in <= o"0"; wait for 10 ns;
            assert w_out = "00" report "Error on input o0" severity failure;
        w_in <= o"1"; wait for 10 ns;
            assert w_out = "01" report "Error on input o1" severity failure;
        w_in <= o"2"; wait for 10 ns;
            assert w_out = "01" report "Error on input o2" severity failure;
        w_in <= o"3"; wait for 10 ns;
            assert w_out = "10" report "Error on input o3" severity failure;
        w_in <= o"4"; wait for 10 ns;
            assert w_out = "01" report "Error on input o4" severity failure;
        w_in <= o"5"; wait for 10 ns;
            assert w_out = "10" report "Error on input o5" severity failure;
        w_in <= o"6"; wait for 10 ns;
            assert w_out = "10" report "Error on input o6" severity failure;
        w_in <= o"7"; wait for 10 ns;
            assert w_out = "11" report "Error on input o7" severity failure;                                          
                                
		wait; -- wait forever
		
	end process;	
	-----------------------------------------------------	
	
end test_bench;
