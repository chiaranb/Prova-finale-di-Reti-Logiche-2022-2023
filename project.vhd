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
           i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z3 : out STD_LOGIC_VECTOR (7 downto 0);
           rCh_load : in STD_LOGIC;
           rAddr_load : in STD_LOGIC;
           rZ0_load : in STD_LOGIC;
           rZ1_load : in STD_LOGIC;
           rZ2_load : in STD_LOGIC;
           rZ3_load : in STD_LOGIC;
           rAddr_sel : in STD_LOGIC;
           rZ0_sel : in STD_LOGIC;
           rZ1_sel : in STD_LOGIC;
           rZ2_sel : in STD_LOGIC;
           rZ3_sel : in STD_LOGIC;
           demux_sel : in STD_LOGIC_VECTOR (1 downto 0));
           --o_done: out STD_LOGIC;
end component;  
          
--Registri
      signal o_regCh : STD_LOGIC_VECTOR (1 downto 0);
      signal rCh_load : STD_LOGIC;

      signal o_regAddr : STD_LOGIC_VECTOR (15 downto 0);
      signal rAddr_load : STD_LOGIC;

      signal o_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ0_load : STD_LOGIC;

      signal o_regZ1: STD_LOGIC_VECTOR (7 downto 0);
      signal rZ1_load : STD_LOGIC;

      signal o_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ2_load : STD_LOGIC;

      signal o_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ3_load : STD_LOGIC;
          
--Mux
      signal mux_regAddr : STD_LOGIC_VECTOR (15 downto 0);
      signal rAddr_sel : STD_LOGIC;

      signal mux_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ0_sel : STD_LOGIC;

      signal mux_regZ1 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ1_sel : STD_LOGIC;

      signal mux_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ2_sel : STD_LOGIC;

      signal mux_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
      signal rZ3_sel : STD_LOGIC;
          
--Demultiplexer
      signal demux_regZ0 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_regZ1 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_regZ2 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_regZ3 : STD_LOGIC_VECTOR (7 downto 0);
      signal demux_sel : STD_LOGIC_VECTOR (1 downto 0);

type Stato is (START, CH_1, CH_0, ADDRESS, END_ADDRESS, REG, DONE, RESET);
signal cur_state, next_state : Stato;
          
begin
--
----DATAPATH 
--
		  
--Registro Address
       process(i_clk, i_rst)
	  begin
	 	if(i_rst = '1') then
			o_regAddr <= "0000000000000000";
	 	elsif i_clk'event and i_clk = '1' then
			o_mem_addr(15 downto 1) <= o_mem_addr(14 downto 0);
			o_mem_addr(0) <= i_w;
		end if;
	end process;
                
--Registro Canale
	process(i_clk, i_rst)
	   begin
	 	if(i_rst = '1') then
			o_regCh <= "00";
		elsif i_clk'event and i_clk = '1' then
			o_regCh(2 downto 1) <= o_regCh(1 downto 0);
			o_regCh(0) <= i_w;
		end if;
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

-- fin qui lo abbiamo fatto insieme
                    
--Mux Address Leggo un bit alla volta
	with rAddr_sel select
		mux_regAddr <=  "0" when '0',
				i_w when '1',
				"X" when others;

 --Mux Z0
	with rz0_sel select
		mux_regZ0 <=  "00000000" when '0',
			      o_regZ0 when '1',
		 	      "XXXXXXXX" when others;

  --Mux Z1
	with rz1_sel select
		mux_regZ1 <= "00000000" when '0',
			     o_regZ1 when '1',
			     "XXXXXXXX" when others;

--Mux Z2
	with rz2_sel select
		mux_regZ2 <= "00000000" when '0',
			     o_regZ2 when '1',
			     "XXXXXXXX" when others;

--Mux Z3
	with rz3_sel select
		mux_regZ3 <= "00000000" when '0',
			      o_regZ3 when '1',
			     "XXXXXXXX" when others;

--Demux
	with demux_sel select 
		demux_regZ0 <= i_mem_data when ”00”,
				   '-' when others; --oppure '0' when others da vedere
		demux_regZ1 <= i_mem_data when ”01” ,
				   '-' when others;
		demux_regZ2 <= i_mem_data when ”10”,
				   '-' when others;    
		demux_regZ3 <= i_mem_data when ”11”,
				   '-' when others;
          
--
---- FSM
--
          
--Dichirazione stati
	process(i_clk, i_rst) --default
	begin
		if(i_rst = '1') then
			cur_state <= RESET;
		elsif i_clk'event and i_clk = '1' then
			cur_state <= next_state;
		end if;
	end process;
		 
	process(cur_state, i_start) 
	begin 
	  next_state <= cur_state
	  case cur_state is
	  	when RESET =>
	  		next_state <= START;
	  	when START =>
	  		if i_start = '1' then
	  			next_state <= CH_1;	  			
	  		else
	  			next_state <= START;
	  		end if;	
	  	when CH_1 =>
	  		if i_start = '1' then
	  			next_state <= CH_0;
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
	  		next_state <= REG;
	  	when REG =>
	  		next_state <= DONE;
	  	when DONE =>
	  		next_state <= START;
          end case;
  end process;

--Gestione segnali
process	(cur_state) 
begin 
   rCh_load <= '0';
   rAddr_load <= '0';
   rZ0_load <= '0';
   rZ1_load <= '0';
   rZ2_load <= '0';
   rZ3_load <= '0';
   rAddr_sel <= '0';
   rZ0_sel <= '0';
   rZ1_sel <= '0';
   rZ2_sel <= '0';
   rZ3_sel <= '0';
   o_done <= '0';
   o_mem_addr <= "0000000000000000";
   o_mem_en <= '0';
   o_mem_we <= '0';
   o_z0 <= mux_regZ0;
   o_z1 <= mux_regZ1;
   o_z2 <= mux_regZ2;
   o_z3 <= mux_regZ3;

  case cur_state is
	when RESET =>
	  	o_regCh <= "00";
	  	o_regAddr <= "0000000000000000";
	  	o_regZ0 <= "00000000";
	  	o_regZ1 <= "00000000";
	  	o_regZ2 <= "00000000";
	  	o_regZ3 <= "00000000";
	when START => 
	when CH_1 =>
		rCh_load <= '1';
	when CH_2 =>
		rCh_load <= '1';
	when ADDRESS =>
		rAddr_load <= '1';
		rAddr_sel <= '1';
	when END_ADDRESS =>
		o_mem_addr <= o_regAddr;
		o_mem_en <= '1';
	when REG =>
		demux_sel <= o_regCh;
		case demux_sel is
			when "00" => 
				rZ0_load <= '1';
			when "01" => 
				rZ1_load <= '1';
			when "10" => 
				rZ2_load <= '1';
			when "11" => 
				rZ3_load <= '1';
		end case;
	when DONE =>
		o_done <= '1';
		rZ0_sel <= '1';
		rZ1_sel <= '1';
		rZ2_sel <= '1';
		rZ3_sel <= '1';
  end case;
end process; 
end Behavioral;
