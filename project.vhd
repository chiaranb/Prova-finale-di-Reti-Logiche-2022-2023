----------------------------------------------------------------------------------
-- Prova Finale (Progetto di Reti Logiche) AA 2022-2023
-- Chiara Thien Thao Nguyen Ba CodicePersona 10727985
-- Flavia Nicotri CodicePersona 10751801
-- Prof. Fabio Salice
--
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: CodicePersona.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (  i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            i_start : in STD_LOGIC;
            i_w : in STD_LOGIC;
            o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
            o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
            o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
            o_z3 : out STD_LOGIC_VECTOR (7 downto 0);
            o_done : out STD_LOGIC;
            o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0);
            i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
            o_mem_we : out STD_LOGIC;
            o_mem_en : out STD_LOGIC
         );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    --Datapath component
    component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z3 : out STD_LOGIC_VECTOR (7 downto 0);
           rCh_load : in STD_LOGIC;
           rAdd_load : in STD_LOGIC;
           rZ0_load : in STD_LOGIC;
           rZ1_load : in STD_LOGIC;
           rZ2_load : in STD_LOGIC;
           rZ3_load : in STD_LOGIC;
           rAdd_sel : in STD_LOGIC;
           rZ0_sel : in STD_LOGIC;
           rZ1_sel : in STD_LOGIC;
           rZ2_sel : in STD_LOGIC;
           rZ3_sel : in STD_LOGIC;
           demux_sel : in STD_LOGIC_VECTOR (1 downto 0);
           --o_done: out STD_LOGIC;
          
end component;  
          
  --Registri
          signal o_regCh : STD_LOGIC_VECTOR (1 downto 0);
          signal rCh_load : STD_LOGIC;
          
          signal o_regAdd : STD_LOGIC_VECTOR (15 downto 0);
          signal rAdd_load : STD_LOGIC;
          
          signal o_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ0_load : STD_LOGIC;
          
          signal o_regZ1: STD_LOGIC_VECTOR (7 downto 0);
          signal rZ1_load : STD_LOGIC;
          
          signal o_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ2_load : STD_LOGIC;
          
          signal o_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ3_load : STD_LOGIC;
          
   --Mux
          signal mux_regAdd : STD_LOGIC_VECTOR (15 downto 0);
          signal rAdd_sel : STD_LOGIC;
                    
          signal mux_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ0_sel : STD_LOGIC;
          
          signal mux_regZ1 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ1_sel : STD_LOGIC;
          
          signal mux_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ2_sel : STD_LOGIC;
          
          signal mux_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ3_sel : STD_LOGIC;
          
    --Demultiplexer
          signal demux : STD_LOGIC_VECTOR (7 downto 0);
          signal demux_sel : STD_LOGIC_VECTOR (1 downto 0);

type Stato is ( );
signal cur_state, next_state : Stato;
          
begin
--
--Datapath 
--
   --Registro Address
         process(i_clk, i_rst)
          begin
            if(i_rst = '1') then
                o_regAddr <= "0000000000000000";
          elsif i_clk'event and i_clk = '1' then
                o_mem_addr(15 downto 1) <= o_mem_addr(14 downto 0);
                o_mem_addr(0) <= i_w;
          endif;
         end process;
                
   --Registro Canale
          process(i_clk, i_rst)
           begin
             if(i_rst = '1') then
                o_regCh <= "00";
          elsif i_clk'event and i_clk = '1' then
            o_regCh(2 downto 1) <= o_regCh(1 downto 0);
            o_regCh(0) <= i_w;
          endif;
         end process;
   
   --Registro Z0
          process(i_clk, i_rst)
           begin
            if(i_rst = '1') then
            o_regZ0 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(rZ0_load = '1') then
                o_regZ0 <= i_mem_data;
            end if;
        end if;
    end process;
          
  --Registro Z1
          process(i_clk, i_rst)
           begin
            if(i_rst = '1') then
            o_regZ1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(rZ1_load = '1') then
                o_regZ1 <= i_mem_data;
            end if;
        end if;
    end process;
          
  --Registro Z2
          process(i_clk, i_rst)
           begin
            if(i_rst = '1') then
            o_regZ2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(rZ2_load = '1') then
                o_regZ2 <= i_mem_data;
            end if;
        end if;
    end process;
          
  --Registro Z3
          process(i_clk, i_rst)
           begin
            if(i_rst = '1') then
            o_regZ3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(rZ3_load = '1') then
                o_regZ3 <= i_mem_data;
            end if;
        end if;
    end process;
          
end Behavioral;
