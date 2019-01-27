library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use work.types.all;

entity collatz is
    port(
        clk:   in  std_logic := '0';  -- system clock
        go:    in  std_logic := '0';  -- receive the signal of finishing preparation
        reset: in  std_logic := '0';  -- terminate the simulation forcibly
        done:  out std_logic := '0';  -- notify that the simulation is finished

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
    process(clk)
        variable shift: std_logic_vector(3 downto 0) := (others => '0');  -- width to shift
        variable h:     peak_t   := (others => '0');  -- temporarily store the current height
        variable step:  length_t := (others => '0');  -- step number used in one operation

    begin
        if (clk = '1') then
            if (reset = '1') then
                -- halt operation, and reset outputs
                state   <= '0';
                done    <= '0';
                result  <= ((others => '0'), (others => '0'), (others => '0'));
            end if;

            if (state = '0' and go = '1') then
                -- initialize inner data by input
                state  <= '1';
                height <= "00000000" & gate;
                result <= ((gate), ("00000000" & gate), (others => '0'));
            end if;

            if (state = '1') then
                step  := (others => '0');
                shift := (others => '0');
                h     := height;

                -- calculate the number to shift
                for i in 15 downto 0 loop
                    if (h(i) = '1') then
                        shift := std_logic_vector(to_unsigned(i, 4));
                    end if;
                end loop;

                -- barrel shifter
                for i in 0 to 3 loop
                    if (shift(i) = '1') then
                        h    := std_logic_vector(to_unsigned(0, 2**i)) & h(17 downto 2**i);
                        step := step + 2**i;
                    end if;
                end loop;

                -- case odd
                if (shift = 0) then
                    h    := (h(16 downto 0) & '1') + h;
                    step := step + 1;
                end if;

                result.length <= result.length + step;
                height        <= h;

                -- update peak, if necessary
                if (height > result.peak) then
                    result.peak <= height;
                end if;
            end if;

            if (height = 1) then
                -- stop operation
                done  <= '1';
                state <= '0';

                -- prevent increment
                result.length <= result.length;
            end if;
        end if;

    end process;
end RTL;
