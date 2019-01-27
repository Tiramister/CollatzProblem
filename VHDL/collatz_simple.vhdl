library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity collatz is
    port(
        clk:   in  std_logic := '0';  -- system clock
        go:    in  std_logic := '0';  -- receive the signal when preparation is finished
        reset: in  std_logic := '0';  -- terminate simulation forcibly
        done:  out std_logic := '0';  -- notify that simulation is finished

        gate:   in    gate_t  := (others => '0');
            -- initial height, or name of the route
        result: inout route_t := ((others => '0'), (others => '0'), (others => '0'))
            -- gate, peak (max height), and length of the route
    );
end collatz;

architecture RTL of collatz is
    signal state:  std_logic := '0';  -- when state = 1, simulation is being executed
    signal height: peak_t    := (others => '0');  -- current height

begin
    process(clk) begin
        if (clk = '1') then
            if (reset = '1') then
                -- halt operation, and reset outputs
                state  <= '0';
                done   <= '0';
                result <= ((others => '0'), (others => '0'), (others => '0'));
            end if;

            if (state = '0' and go = '1') then
                -- initialize data by input
                state  <= '1';
                height <= "00000000" & gate;
                result <= ((gate), ("00000000" & gate), (others => '0'));
            end if;

            if (state = '1') then
                -- simulate the collatz problem
                if (height(0) = '0') then
                    height <= '0' & height(17 downto 1);
                else
                    height <= (height(16 downto 0) & '1') + height;
                end if;

                result.length <= result.length + 1;

                -- update peak, if necessary
                if (height > result.peak) then
                    result.peak <= height;
                end if;
            end if;

            if (height = "000000000000000001") then
                -- stop operation
                done  <= '1';
                state <= '0';

                -- prevent increment
                result.length <= result.length;
            end if;
        end if;

    end process;
end RTL;
