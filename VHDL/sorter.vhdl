library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity sorter is
    port(
        clk:   in std_logic := '0';  -- system clock
        ready: in std_logic := '0';  -- receive the signal when sorting is required

        top4:   inout route4  := (others => ((others => '0'), (others => '0'), (others => '0')));
        result: in    route_t := ((others => '0'), (others => '0'), (others => '0'))
            -- recieve the signal that collatz simulation is finished
    );
end sorter;

architecture RTL of sorter is
begin
    process(clk)
        variable top5: route5 := (others => ((others => '0'), (others => '0'), (others => '0')));
            -- temporary store the top 4 route and the result from collatz
        variable same: Boolean := False;
            -- True if top 4 has a route whose peak is equal to result

    begin
        if (rising_edge(clk) and ready = '1') then
            for i in 0 to 3 loop
                top5(i) := top4(i);
            end loop;
            top5(4) := result;

            -- check if there is a route whose peak is same with the result's.
            for i in 0 to 3 loop
                if (top5(i).peak = top5(4).peak) then
                    same := True;

                    if (top5(i).length < top5(4).length) then
                        top5(i).length := top5(4).length;
                        top5(i).gate   := top5(4).gate;
                    end if;
                end if;
            end loop;

            if (not same) then
                -- bubble sort
                for i in 3 downto 0 loop
                    if (top5(i).peak < top5(i + 1).peak) then
                        top5(i).peak     := top5(i).peak xor top5(i + 1).peak;
                        top5(i + 1).peak := top5(i).peak xor top5(i + 1).peak;
                        top5(i).peak     := top5(i).peak xor top5(i + 1).peak;

                        top5(i).gate     := top5(i).gate xor top5(i + 1).gate;
                        top5(i + 1).gate := top5(i).gate xor top5(i + 1).gate;
                        top5(i).gate     := top5(i).gate xor top5(i + 1).gate;

                        top5(i).length     := top5(i).length xor top5(i + 1).length;
                        top5(i + 1).length := top5(i).length xor top5(i + 1).length;
                        top5(i).length     := top5(i).length xor top5(i + 1).length;
                    end if;
                end loop;
            end if;

            same := False;

            for i in 0 to 3 loop
                top4(i) <= top5(i);
            end loop;
        end if;
    end process;
end RTL;
