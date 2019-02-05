library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.types.all;

entity top is
    port(
        clk:     in    std_logic := '0';  -- system clock
        alldone: out   std_logic := '0';  -- notify that iteration was finished
        top4:    inout route4    := (others => ((others => '0'), (others => '0'), (others => '0')));
            -- gate, peak, and length of routes which has top 4 peak

        clk_count: inout std_logic_vector(31 downto 0) := (others => '0')
    );
end top;

architecture RTL of top is
    component collatz
        port(
            clk:   in  std_logic := '0';
            go:    in  std_logic := '0';
            reset: in  std_logic := '0';
            done:  out std_logic := '0';

            gate:   in    gate_t  := (others => '0');
            result: inout route_t := ((others => '0'), (others => '0'), (others => '0'))
        );
    end component;

    component sorter
        port(
            clk:   in std_logic := '0';
            ready: in std_logic := '1';

            top4:   inout route4  := (others => ((others => '0'), (others => '0'), (others => '0')));
            result: in    route_t := ((others => '0'), (others => '0'), (others => '0'))
        );
    end component;

    signal go:    std_logic := '0';
    signal reset: std_logic := '0';
    signal done:  std_logic := '0';

    signal gate:   gate_t  := "0000000001";
    signal result: route_t := ((others => '0'), (others => '0'), (others => '0'));
    -- signals above are connected to collatz component

    signal ready: std_logic := '1';

begin
    collatz_c: collatz port map(
        clk    => clk,
        go     => go,
        reset  => reset,
        done   => done,
        gate   => gate,
        result => result
    );

    sorter_c: sorter port map(
        clk    => clk,
        ready  => ready,
        top4   => top4,
        result => result
    );

    process(clk) begin
        if (clk = '1') then
            clk_count <= clk_count + 1;

            if (ready = '1') then
                ready <= '0';
                -- give input to collatz
                reset <= '0';

                -- skip 5, 9, 11 (mod 12)
                if (to_integer(unsigned(gate)) mod 12 = 3) then
                    gate <= gate + 4;
                elsif (to_integer(unsigned(gate)) mod 12 = 7) then
                    gate <= gate + 6;
                else
                    gate <= gate + 2;
                end if;
                go    <= '1';
            end if;

            if (done = '1' and reset = '0') then
                ready <= '1';
                reset <= '1';
                -- sorting is done behind
            end if;

            if (go = '1') then
                go <= '0';
            end if;
        end if;

        if (done = '1' and gate = "1111111111" and ready = '1') then
            alldone <= '1';
        end if;
    end process;
end RTL;
