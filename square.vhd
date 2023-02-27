library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity square is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_start : in STD_LOGIC;
           o_done : out STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_addr : out STD_LOGIC_VECTOR (1 downto 0);
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC);
end square;

architecture Behavioral of square is
component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r2_sel : in STD_LOGIC;
           r3_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end component;
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal r3_load : STD_LOGIC;
signal r2_sel : STD_LOGIC;
signal r3_sel : STD_LOGIC;
signal d_sel : STD_LOGIC;
signal o_end : STD_LOGIC;
type S is (S0,S1,S2,S3,S4,S5,S6);
signal cur_state, next_state : S;
begin
    DATAPATH0: datapath port map(
        i_clk,
        i_res,
        i_data,
        o_data,
        r1_load,
        r2_load,
        r3_load,
        r2_sel,
        r3_sel,
        d_sel,
        o_end
    );
    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                if o_end = '1' then
                    next_state <= S4;
                else
                    next_state <= S3;
                end if;
            when S3 =>
                if o_end = '1' then
                    next_state <= S4;
                else
                    next_state <= S3;
                end if;
            when S4 =>
                next_state <= S5;
            when S5 =>
                next_state <= S6;
            when S6 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r2_sel <= '0';
        r3_sel <= '0';
        d_sel <= '0';
        o_addr <= "00";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                o_addr <= "00";
                o_en <= '1';
                r1_load <= '1';
                r3_sel <= '0';
                r3_load <= '1';
                r2_sel <= '0';
                r2_load <= '1';
            when S2 =>
                r3_sel <= '1';
                r3_load <= '1';
            when S3 =>
                r3_sel <= '1';
                r3_load <= '1';
                r2_sel <= '1';
                r2_load <= '1';
            when S4 =>
                d_sel <= '0';
                o_addr <= "01";
                o_en <= '1';
                o_we <= '1';
            when S5 =>
                d_sel <= '1';
                o_addr <= "10";
                o_en <= '1';
                o_we <= '1';
            when S6 =>
                o_done <= '1';
        end case;
    end process;
    
end Behavioral;

-- datapath
entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r2_sel : in STD_LOGIC;
           r3_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (15 downto 0);
signal sum : STD_LOGIC_VECTOR(15 downto 0);
signal mux_reg2 : STD_LOGIC_VECTOR(15 downto 0);
signal mux_reg3 : STD_LOGIC_VECTOR(7 downto 0);
signal sub : STD_LOGIC_VECTOR(7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
begin
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    sum <= ("00000000" & o_reg1) + o_reg2;
    
    with r2_sel select
        mux_reg2 <= "0000000000000000" when '0',
                    sum when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg2 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= mux_reg2;
            end if;
        end if;
    end process;
    
    with d_sel select
        o_data <= o_reg2(7 downto 0) when '0',
                  o_reg2(15 downto 8) when '1',
                  "XXXXXXXX" when others;
    
    with r3_sel select
        mux_reg3 <= i_data when '0',
                    sub when '1',
                    "XXXXXXXX" when others;
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= mux_reg3;
            end if;
        end if;
    end process;
    
    sub <= o_reg3 - "00000001";
    
    o_end <= '1' when (o_reg3 = "00000000") else '0';

end Behavioral;
          
