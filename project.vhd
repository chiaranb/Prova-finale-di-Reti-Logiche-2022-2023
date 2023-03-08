----------------------------------------------------------------------------------
-- Prova Finale (Progetto di Reti Logiche) AA 2022-2023
-- Chiara Thien Thao Nguyen Ba - CodicePersona 10727985
-- Flavia Nicotri - CodicePersona 10751801
-- Prof. Fabio Salice
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 10727985_10751801.vhd
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY project_reti_logiche IS
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
END project_reti_logiche;

ARCHITECTURE Behavioral OF project_reti_logiche IS
    --Datapath component
    COMPONENT datapath IS
        PORT (
            i_clk : IN STD_LOGIC;
            i_rst : IN STD_LOGIC;
            i_w : IN STD_LOGIC;
            i_mem_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            o_z0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            o_z1 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            o_z2 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            o_z3 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            o_mem_addr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

            rCh_load : IN STD_LOGIC;
            rAddr_load : IN STD_LOGIC;
            rIN_load : IN STD_LOGIC;
            rZ0_load : IN STD_LOGIC;
            rZ1_load : IN STD_LOGIC;
            rZ2_load : IN STD_LOGIC;
            rZ3_load : IN STD_LOGIC;
            clear_addr : IN STD_LOGIC;
            rZ0_sel : IN STD_LOGIC;
            rZ1_sel : IN STD_LOGIC;
            rZ2_sel : IN STD_LOGIC;
            rZ3_sel : IN STD_LOGIC;
            demux_sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0));
    END COMPONENT;

    --Registri
    SIGNAL o_regCh : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL rCh_load : STD_LOGIC;

    SIGNAL o_regAddr : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL rAddr_load : STD_LOGIC;
    SIGNAL clear_addr : STD_LOGIC;

    SIGNAL o_regIN : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL rIN_load : STD_LOGIC;

    SIGNAL o_regZ0 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL rZ0_load : STD_LOGIC;

    SIGNAL o_regZ1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL rZ1_load : STD_LOGIC;

    SIGNAL o_regZ2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL rZ2_load : STD_LOGIC;

    SIGNAL o_regZ3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL rZ3_load : STD_LOGIC;

    --Mux
    SIGNAL rZ0_sel : STD_LOGIC;
    SIGNAL rZ1_sel : STD_LOGIC;
    SIGNAL rZ2_sel : STD_LOGIC;
    SIGNAL rZ3_sel : STD_LOGIC;

    --Demultiplexer
    SIGNAL demux_regZ0 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL demux_regZ1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL demux_regZ2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL demux_regZ3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL demux_sel : STD_LOGIC_VECTOR (1 DOWNTO 0);

    TYPE Stato IS (IDLE, CH, READ, ADDR, MEM, LOAD, DONE);
    SIGNAL cur_state, next_state : Stato;
BEGIN
    --
    ----DATAPATH 
    --

    --Registro Address
    PROCESS (i_clk, i_rst, clear_addr)
    BEGIN
        IF (i_rst = '1') THEN
            o_regAddr <= "0000000000000000";
        ELSIF (clear_addr = '1') THEN
            o_regAddr <= "0000000000000000";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rAddr_load = '1') THEN
                o_regAddr(15 DOWNTO 1) <= o_regAddr(14 DOWNTO 0);
                o_regAddr(0) <= i_w;
            END IF;
        END IF;
    END PROCESS;

    o_mem_addr <= o_regAddr;
    --Registro Canale
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            o_regCh <= "00";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rCh_load = '1') THEN
                o_regCh(1) <= o_regCh(0);
                o_regCh(0) <= i_w;
            END IF;
        END IF;
    END PROCESS;
    --Registro Dato IN
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            o_regIN <= "00000000";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rIN_load = '1') THEN
                o_regIN <= i_mem_data;
            END IF;
        END IF;
    END PROCESS;

    --Registro Z0
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            o_regZ0 <= "00000000";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rZ0_load = '1') THEN
                o_regZ0 <= demux_regZ0;
            END IF;
        END IF;
    END PROCESS;

    --Registro Z1
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            o_regZ1 <= "00000000";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rZ1_load = '1') THEN
                o_regZ1 <= demux_regZ1;
            END IF;
        END IF;
    END PROCESS;

    --Registro Z2
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            o_regZ2 <= "00000000";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rZ2_load = '1') THEN
                o_regZ2 <= demux_regZ2;
            END IF;
        END IF;
    END PROCESS;

    --Registro Z3
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            o_regZ3 <= "00000000";
        ELSIF i_clk'event AND i_clk = '1' THEN
            IF (rZ3_load = '1') THEN
                o_regZ3 <= demux_regZ3;
            END IF;
        END IF;
    END PROCESS;

    --Mux Z0
    WITH rz0_sel SELECT
        o_z0 <= "00000000" WHEN '0',
                o_regZ0 WHEN '1',
                "XXXXXXXX" WHEN OTHERS;

    --Mux Z1
    WITH rz1_sel SELECT
        o_z1 <= "00000000" WHEN '0',
                o_regZ1 WHEN '1',
                "XXXXXXXX" WHEN OTHERS;

    --Mux Z2
    WITH rz2_sel SELECT
        o_z2 <= "00000000" WHEN '0',
                o_regZ2 WHEN '1',
                "XXXXXXXX" WHEN OTHERS;

    --Mux Z3
    WITH rz3_sel SELECT
        o_z3 <= "00000000" WHEN '0',
                o_regZ3 WHEN '1',
                "XXXXXXXX" WHEN OTHERS;

    --Demux
    demux_regZ0 <= o_regIN WHEN demux_sel = "00" ELSE
        (OTHERS => '0');
    demux_regZ1 <= o_regIN WHEN demux_sel = "01" ELSE
        (OTHERS => '0');
    demux_regZ2 <= o_regIN WHEN demux_sel = "10" ELSE
        (OTHERS => '0');
    demux_regZ3 <= o_regIN WHEN demux_sel = "11" ELSE
        (OTHERS => '0');

    --
    ---- FSM
    --

    --Cambia stato e reset 
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            cur_state <= IDLE;
        ELSIF i_clk'event AND i_clk = '1' THEN
            cur_state <= next_state;
        END IF;
    END PROCESS;

    --Trova stato successivo
    PROCESS (cur_state, i_start)
    BEGIN
        next_state <= cur_state;
        CASE cur_state IS
            WHEN IDLE =>
                IF i_start = '1' THEN
                    next_state <= CH;
                ELSE
                    next_state <= IDLE;
                END IF;
            WHEN CH =>
                IF i_start = '1' THEN
                    next_state <= READ;
                ELSE
                    next_state <= ADDR;
                END IF;
            WHEN READ =>
                IF i_start = '1' THEN
                    next_state <= READ;
                ELSE
                    next_state <= ADDR;
                END IF;
            WHEN ADDR =>
                next_state <= MEM;
            WHEN MEM =>
                next_state <= LOAD;
            WHEN LOAD =>
                next_state <= DONE;
            WHEN DONE =>
                next_state <= IDLE;
        END CASE;
    END PROCESS;

    --Gestione segnali
    PROCESS (cur_state, i_start, o_regCh, demux_sel)
    BEGIN
        rCh_load <= '0';
        rAddr_load <= '0';
        rIN_load <= '0';
        rZ0_load <= '0';
        rZ1_load <= '0';
        rZ2_load <= '0';
        rZ3_load <= '0';
        rZ0_sel <= '0';
        rZ1_sel <= '0';
        rZ2_sel <= '0';
        rZ3_sel <= '0';
        o_done <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        demux_sel <= "00";
        clear_addr <= '0';

        CASE cur_state IS
            WHEN IDLE =>
                IF i_start = '1' THEN
                    rCh_load <= '1';
                END IF;
            WHEN CH =>
                rCh_load <= '1';
            WHEN READ =>
                IF i_start = '1' THEN
                    rAddr_load <= '1';
                END IF;
            WHEN ADDR =>
                o_mem_en <= '1';
                o_mem_we <= '0';
            WHEN MEM =>
                rIN_load <= '1';
            WHEN LOAD =>
                demux_sel <= o_regCh;
                CASE demux_sel IS
                    WHEN "00" =>
                        rZ0_load <= '1';
                    WHEN "01" =>
                        rZ1_load <= '1';
                    WHEN "10" =>
                        rZ2_load <= '1';
                    WHEN "11" =>
                        rZ3_load <= '1';
                    WHEN OTHERS =>
                END CASE;
            WHEN DONE =>
                clear_addr <= '1';
                o_done <= '1';
                rZ0_sel <= '1';
                rZ1_sel <= '1';
                rZ2_sel <= '1';
                rZ3_sel <= '1';
        END CASE;
    END PROCESS;
END Behavioral;
