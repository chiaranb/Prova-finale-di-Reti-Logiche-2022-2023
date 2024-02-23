----------------------------------------------------------------------------------
-- Company: Politecnico di Milano
-- Test Created by: Elia Pontiggia
--
-- Passed on date: 01.03.2023 18:37
--
-- Target of the test:
-- 
----------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

entity test3 is
end test3;

ARCHITECTURE testBench of test3 is
    CONSTANT CLOCK_PERIOD : TIME := 100 ns;
    SIGNAL tb_done : STD_LOGIC;
    SIGNAL mem_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_rst : STD_LOGIC := '0';
    SIGNAL tb_start : STD_LOGIC := '0';
    SIGNAL tb_clk : STD_LOGIC := '0';
    SIGNAL mem_o_data, mem_i_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL enable_wire : STD_LOGIC;
    SIGNAL mem_we : STD_LOGIC;
    SIGNAL tb_z0, tb_z1, tb_z2, tb_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tb_w : STD_LOGIC;

    CONSTANT SCENARIOLENGTH : INTEGER := 260;
    -- 5 + 1 + 20 + 8 + 20 + 16 + 20 + 16 + 20 + 12 + 20 + 15 + 20 + 4 + 20 + 7 + 20 
    -- (RST) + (CH00-MEM[1]) + (CH01-MEM[10001011]) + (CH10-MEM[1111111100000000]) + (CH11-MEM[0000111111000000]) + (CH11-MEM[100110010110]) + (CH10-MEM[111011011000001]) + (CH01-MEM[0000]) + (CH00-MEM[1111110]) [WAIT omesse] 
    SIGNAL scenario_rst : unsigned(0 TO SCENARIOLENGTH - 1)     := "00110" & "000" & "00000000000000000000" & "0000000000" & "00000000000000000000" & "000000000000000000" & "00000000000000000000" & "000000000000000000" & "00000000000000000000" & "00000000000000" & "00000000000000000000" & "00000000000000000" & "00000000000000000000" & "000000" & "00000000000000000000" & "000000000" & "00000000000000000000" ;
    SIGNAL scenario_start : unsigned(0 TO SCENARIOLENGTH - 1)   := "00000" & "111" & "00000000000000000000" & "1111111111" & "00000000000000000000" & "111111111111111111" & "00000000000000000000" & "111111111111111111" & "00000000000000000000" & "11111111111111" & "00000000000000000000" & "11111111111111111" & "00000000000000000000" & "111111" & "00000000000000000000" & "111111111" & "00000000000000000000" ;
    SIGNAL scenario_w : unsigned(0 TO SCENARIOLENGTH - 1)       := "00000" & "001" & "00000000000000000000" & "0110001011" & "00000000000000000000" & "101111111100000000" & "00000000000000000000" & "110000111111000000" & "00000000000000000000" & "11100110010110" & "00000000000000000000" & "10111011011000001" & "00000000000000000000" & "010000" & "00000000000000000000" & "001111110" & "00000000000000000000" ;

    TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : ram_type := (
                                2 => STD_LOGIC_VECTOR(to_unsigned(0, 8)),
                                3 => STD_LOGIC_VECTOR(to_unsigned(511, 8)),
                                1 => STD_LOGIC_VECTOR(to_unsigned(349, 8)),
                                139 => STD_LOGIC_VECTOR(to_unsigned(511, 8)),
                                65280 => STD_LOGIC_VECTOR(to_unsigned(508, 8)),
                                4032 => STD_LOGIC_VECTOR(to_unsigned(376, 8)),
                                2454 => STD_LOGIC_VECTOR(to_unsigned(187, 8)),
                                30401 => STD_LOGIC_VECTOR(to_unsigned(211, 8)),
                                0 => STD_LOGIC_VECTOR(to_unsigned(145, 8)),
                                126 => STD_LOGIC_VECTOR(to_unsigned(255, 8)),
                                OTHERS => "00000000"
                            );

    COMPONENT project_reti_logiche IS
        PORT (
            i_clk : IN STD_LOGIC;
            i_rst : IN STD_LOGIC;
            i_start : IN STD_LOGIC;
            i_w : IN STD_LOGIC;

            o_z0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_done : OUT STD_LOGIC;

            o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            i_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_mem_we : OUT STD_LOGIC;
            o_mem_en : OUT STD_LOGIC
        );
    END COMPONENT project_reti_logiche;

BEGIN
    UUT : project_reti_logiche
    PORT MAP(
        i_clk => tb_clk,
        i_start => tb_start,
        i_rst => tb_rst,
        i_w => tb_w,

        o_z0 => tb_z0,
        o_z1 => tb_z1,
        o_z2 => tb_z2,
        o_z3 => tb_z3,
        o_done => tb_done,

        o_mem_addr => mem_address,
        o_mem_en => enable_wire,
        o_mem_we => mem_we,
        i_mem_data => mem_o_data
    );


    -- Process for the clock generation
    CLK_GEN : PROCESS IS
    BEGIN
        WAIT FOR CLOCK_PERIOD/2;
        tb_clk <= NOT tb_clk;
    END PROCESS CLK_GEN;


    -- Process related to the memory
    MEM : PROCESS (tb_clk)
    BEGIN
        IF tb_clk'event AND tb_clk = '1' THEN
            IF enable_wire = '1' THEN
                IF mem_we = '1' THEN
                    RAM(conv_integer(mem_address)) <= mem_i_data;
                    mem_o_data <= mem_i_data AFTER 1 ns;
                ELSE
                    mem_o_data <= RAM(conv_integer(mem_address)) AFTER 1 ns; 
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    createScenario : PROCESS (tb_clk)
    BEGIN
        IF tb_clk'event AND tb_clk = '0' THEN
            tb_rst <= scenario_rst(0);
            tb_w <= scenario_w(0);
            tb_start <= scenario_start(0);
            scenario_rst <= scenario_rst(1 TO SCENARIOLENGTH - 1) & '0';
            scenario_w <= scenario_w(1 TO SCENARIOLENGTH - 1) & '0';
            scenario_start <= scenario_start(1 TO SCENARIOLENGTH - 1) & '0';
        END IF;
    END PROCESS;

    -- Process without sensitivity list designed to test the actual component.
    testRoutine : PROCESS IS
    BEGIN
        mem_i_data <= "00000000";
        -- wait for 10000 ns;

    WAIT UNTIL tb_rst = '1';
    WAIT UNTIL tb_rst = '0';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postreset  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postreset  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postreset  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postreset  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(511, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(511, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z2 = STD_LOGIC_VECTOR(to_unsigned(508, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(511, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z2 = STD_LOGIC_VECTOR(to_unsigned(508, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z3 = STD_LOGIC_VECTOR(to_unsigned(376, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(511, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z2 = STD_LOGIC_VECTOR(to_unsigned(508, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z3 = STD_LOGIC_VECTOR(to_unsigned(187, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(511, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z2 = STD_LOGIC_VECTOR(to_unsigned(211, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z3 = STD_LOGIC_VECTOR(to_unsigned(187, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(349, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(145, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z2 = STD_LOGIC_VECTOR(to_unsigned(211, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z3 = STD_LOGIC_VECTOR(to_unsigned(187, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;

    WAIT UNTIL tb_done = '0';
    WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_start = '1';

        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart  Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 

    WAIT UNTIL tb_done = '1';
    WAIT FOR CLOCK_PERIOD/2;

    ASSERT tb_z0 = STD_LOGIC_VECTOR(to_unsigned(255, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z1 = STD_LOGIC_VECTOR(to_unsigned(145, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z2 = STD_LOGIC_VECTOR(to_unsigned(211, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;
    ASSERT tb_z3 = STD_LOGIC_VECTOR(to_unsigned(187, 8)) REPORT "TEST NON PASSATO" SEVERITY failure;



    WAIT FOR CLOCK_PERIOD*2;
    ASSERT false REPORT "Simulation Ended! TEST PASSATO (NO 3)" SEVERITY failure;
    END PROCESS testRoutine;

END testBench;