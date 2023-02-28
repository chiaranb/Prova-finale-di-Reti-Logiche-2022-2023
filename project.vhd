----------------------------------------------------------------------------------
-- Prova Finale (Progetto di Reti Logiche) AA 2022-2023
-- Chiara Thien Thao Nguyen Ba CodicePersona 10727985
-- Flavia Nicotri CodicePersona
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
            o_mem_en : out STD_LOGIC;
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
          signal rAdd_sel :  STD_LOGIC;
                    
          signal mux_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ0_sel :  STD_LOGIC;
          
          signal mux_regZ1 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ1_sel :  STD_LOGIC;
          
          signal mux_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ2_sel :  STD_LOGIC;
          
          signal mux_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
          signal rZ3_sel :  STD_LOGIC;
          
    --Demultiplexer
          signal demux : STD_LOGIC_VECTOR (7 downto 0);
          signal demux_sel : STD_LOGIC_VECTOR (1 downto 0);

type Stato is ( );
signal cur_state, next_state : Stato;
          
begin
--
--Datapath 
--
          
end Behavioral;
