library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity testbench is
end testbench;

architecture RTL of testbench is
    component top
        port(
            clk: in std_logic := '0';       -- system clock
            alldone: out std_logic := '0';  -- notify that iteration was finished
            top4: inout route4 := (others => ((others => '0'), (others => '0'), (others => '0')));

            clk_count: inout std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;

    signal clk: std_logic := '0';
    signal clk_count: std_logic_vector(31 downto 0) := (others => '0');
    signal alldone: std_logic := '0';

    signal top0_gate: gate_t := (others => '0');
    signal top1_gate: gate_t := (others => '0');
    signal top2_gate: gate_t := (others => '0');
    signal top3_gate: gate_t := (others => '0');

    signal top0_peak: peak_t := (others => '0');
    signal top1_peak: peak_t := (others => '0');
    signal top2_peak: peak_t := (others => '0');
    signal top3_peak: peak_t := (others => '0');

    signal top0_length: length_t := (others => '0');
    signal top1_length: length_t := (others => '0');
    signal top2_length: length_t := (others => '0');
    signal top3_length: length_t := (others => '0');

    constant CLOCK: Time := 20 ns;

begin
    tcl: top port map(
        clk => clk,
        clk_count => clk_count,
        alldone => alldone,

        top4(0).gate => top0_gate,
        top4(1).gate => top1_gate,
        top4(2).gate => top2_gate,
        top4(3).gate => top3_gate,

        top4(0).peak => top0_peak,
        top4(1).peak => top1_peak,
        top4(2).peak => top2_peak,
        top4(3).peak => top3_peak,

        top4(0).length => top0_length,
        top4(1).length => top1_length,
        top4(2).length => top2_length,
        top4(3).length => top3_length
    );

    process begin
        wait for CLOCK / 2;
        clk <= '1';
        wait for CLOCK / 2;
        clk <= '0';
        if alldone = '1' then
            wait;
        end if;
    end process;
end RTL;
