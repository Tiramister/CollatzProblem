library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity collatz_tb is
end collatz_tb;

architecture RTL of collatz_tb is
    component collatz
        port(
            clk: in std_logic := '0';    -- system clock
            go: in std_logic := '0';     -- receive the signal of finishing preparation
            reset: in std_logic := '0';  -- terminate simulation forcibly
            done: out std_logic := '0';  -- notify that simulation was finished

            gate: in gate_t := (others => '0');  -- initial height, or name of the route
            result: inout route_t := ((others => '0'), (others => '0'), (others => '0'))
                -- gate, peak (max height), and length of the route
    );
    end component;

    signal clk, go, reset, done, alldone: std_logic := '0';
    signal gate: std_logic_vector(9 downto 0) := (others => '0');

    signal res_gate: std_logic_vector(9 downto 0) := (others => '0');
    signal res_peak: std_logic_vector(17 downto 0) := (others => '0');
    signal res_length: std_logic_vector(7 downto 0) := (others => '0');

    constant CLOCK: Time := 20 ns;

begin
    cl: collatz port map(
        clk => clk,
        go => go,
        reset => reset,
        gate => gate,
        result.gate => res_gate,
        result.peak => res_peak,
        result.length => res_length,
        done => done
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

    process begin
        wait until clk'event and clk = '1';

        wait for CLOCK / 4;
        gate <= gate + 1;
        go <= '1';
        wait for CLOCK;
        go <= '0';

        wait until done'event and done = '1';

        if gate = "1111111111" then
            alldone <= '1';
            wait;
        end if;

        wait for CLOCK / 4;
        reset <= '1';
        wait for CLOCK;
        reset <= '0';
    end process;
end RTL;
