----------------------------------------------------------------------------------
-- Prova Finale (Progetto di Reti Logiche) AA 2022-2023
-- Chiara Thien Thao Nguyen Ba CodicePersona 10727985
-- Flavia Nicotri CodicePersona 10751801
-- Prof. Fabio Salice
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: CodicePersona.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
         port (
             i_clk   : in std_logic;
             i_rst   : in std_logic;
             i_start : in std_logic;
             i_w     : in std_logic;
             o_z0    : out std_logic_vector(7 downto 0);
             o_z1    : out std_logic_vector(7 downto 0);
             o_z2    : out std_logic_vector(7 downto 0);
             o_z3    : out std_logic_vector(7 downto 0);
             o_done  : out std_logic;
             o_mem_addr : out std_logic_vector(15 downto 0);
             i_mem_data : in std_logic_vector(7 downto 0);
             o_mem_we   : out std_logic;
             o_mem_en   : out std_logic
         );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
--Datapath component
    component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_w : in  STD_LOGIC;
           i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z3 : out STD_LOGIC_VECTOR (7 downto 0);
           o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0);
            
           rCh_load : in STD_LOGIC;
           rAddr_load : in STD_LOGIC;
	       rIN_load : in STD_LOGIC;
           rZ0_sel : in STD_LOGIC;
           rZ1_sel : in STD_LOGIC;
           rZ2_sel : in STD_LOGIC;
           rZ3_sel : in STD_LOGIC;
           demux_sel : in STD_LOGIC_VECTOR (1 downto 0));         
end component; 

                    
--Registri
      signal o_regCh : STD_LOGIC_VECTOR(1 downto 0);
      signal rCh_load : STD_LOGIC; 
        
      signal o_regAddr : STD_LOGIC_VECTOR (15 downto 0);
      signal rAddr_load : STD_LOGIC;

      signal o_regIN : STD_LOGIC_VECTOR (7 downto 0);
      signal rIN_load : STD_LOGIC;
          
--Mux
      --signal mux_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ0_sel : STD_LOGIC;

      --signal mux_regZ1 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ1_sel : STD_LOGIC;

      --signal mux_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ2_sel : STD_LOGIC;

      --signal mux_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ3_sel : STD_LOGIC;
          
--Demultiplexer
      signal demux_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_regZ1 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_sel : STD_LOGIC_VECTOR (1 downto 0);

type Stato is (IDLE, CH_1, CH_0, ADDRESS, END_ADDRESS, WRITE, DONE, RESET);
signal cur_state, next_state : Stato;

begin
  
--
----DATAPATH 
--
	DATAPATH0: datapath port map(
	       i_clk => i_clk,
           i_rst =>  i_rst,
           i_w  => i_w,
           i_mem_data =>  i_mem_data,
           o_z0  => o_z0,
           o_z1 => o_z1,
           o_z2  => o_z2,
           o_z3  => o_z3,
           o_mem_addr  => o_mem_addr,
            
           rCh_load  => rCh_load,
           rAddr_load => rAddr_load,
	       rIN_load => rIN_load,
           rZ0_sel=> rZ0_sel,
           rZ1_sel => rZ1_sel,
           rZ2_sel =>rZ2_sel,
           rZ3_sel => rZ3_sel,
           demux_sel => demux_sel
           );
             
--Registro Address
    process(i_clk, i_rst)
	  begin
	 	if(i_rst = '1') then
			o_regAddr <= "0000000000000000";
	 	elsif i_clk'event and i_clk = '1' then
	 	   if(rAddr_load = '1') then
                o_regAddr(15 downto 1) <= o_regAddr(14 downto 0);
                o_regAddr(0) <= i_w;
			end if;
		end if;
	end process;
    
                
------Registro Canale
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regCh <= "00";
        elsif i_clk'event and i_clk = '1' then
            if(rCh_load = '1') then
                o_regCh(1) <= o_regCh(0);
                o_regCh(0) <= i_w;
            end if;
        end if;
    end process;


--Registro Dato IN
	process(i_clk, i_rst)
	    begin
		if(i_rst = '1') then
		   	o_regIN <= "00000000";
		elsif i_clk'event and i_clk = '1' then
		    if(rIN_load = '1') then
			 o_regIN <= i_mem_data;
		    end if;
		end if;
	end process;                   

 --Mux Z0
	with rz0_sel select
		o_z0 <=  "00000000" when '0',
			      demux_regZ0 when '1',
		 	      "XXXXXXXX" when others;

  --Mux Z1
	with rz1_sel select
		o_z1 <= "00000000" when '0',
			     demux_regZ1 when '1',
			     "XXXXXXXX" when others;

--Mux Z2
	with rz2_sel select
		o_z2 <= "00000000" when '0',
			     demux_regZ2 when '1',
			     "XXXXXXXX" when others;

--Mux Z3
	with rz3_sel select
		o_z3 <= "00000000" when '0',
			      demux_regZ3 when '1',
			     "XXXXXXXX" when others;

--Demux
		demux_regZ0 <=  o_regIN when demux_sel = "00" else (others => '0');
        demux_regZ1 <=  o_regIN when demux_sel = "01" else (others => '0');
		demux_regZ2 <=  o_regIN when demux_sel = "10" else (others => '0');
		demux_regZ3 <=  o_regIN when demux_sel = "11" else (others => '0');
    
--
---- FSM
--
          
--Cambia stato e reset 
process(i_clk, i_rst) 
begin
	if(i_rst = '1') then
		cur_state <= RESET;
	elsif i_clk'event and i_clk = '1' then	 	   
		cur_state <= next_state;
	end if;
end process;

--Trova stato successivo
process(cur_state, i_start) 
begin 
  next_state <= cur_state;
  case cur_state is
	when RESET =>
	   if i_start = '0' then
		next_state <= IDLE;
		end if;
	when IDLE =>
		if i_start = '1' then
			next_state <= CH_1;	  			
		else
			next_state <= IDLE;
		end if;	
	when CH_1 =>
		if i_start = '1' then
			next_state <= CH_0;
		end if;
	when CH_0 => 
		if i_start = '1' then
			next_state <= ADDRESS;		
		else
			next_state <= END_ADDRESS;
		end if;
	when ADDRESS =>
		if i_start = '1' then 
			next_state <= ADDRESS;
		else
			next_state <= END_ADDRESS;
		end if;
	when END_ADDRESS =>
		next_state <= WRITE;
	when WRITE =>
		next_state <= DONE;
	when DONE =>
	    if i_start = '0' then
		next_state <= IDLE;
		end if;
  end case;
end process;

--Gestione segnali
process	(cur_state, o_regAddr) 
begin
   rCh_load <= '0';
   rAddr_load <= '0';
   rIN_load <= '0';
   rZ0_sel <= '0';
   rZ1_sel <= '0';
   rZ2_sel <= '0';
   rZ3_sel <= '0';
   o_done <= '0';
   o_mem_en <= '0';
   o_mem_we <= '0';
   demux_sel <= "00";
   
  case cur_state is
	when RESET =>
	when IDLE => 
	when CH_1 =>
	   rCh_load <= '1';
	when CH_0 =>
        rCh_load <= '1';
	when ADDRESS =>
		rAddr_load <= '1';
	when END_ADDRESS =>
		o_mem_addr <= o_regAddr;
		o_mem_en <= '1';
		o_mem_we <= '0';
	when WRITE =>
        rIN_load <= '1'; 
	when DONE =>
		demux_sel <= o_regCh;
		o_done <= '1';
		rZ0_sel <= '1';
		rZ1_sel <= '1';
		rZ2_sel <= '1';
		rZ3_sel <= '1';

  end case;
end process; 
end Behavioral;
