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

        gate:   in    gate_t  := (others => '0');  -- initial height, or name of the route
        result: inout route_t := ((others => '0'), (others => '0'), (others => '0'))
            -- gate, peak (max height), and length of the route
    );
end collatz;

architecture RTL of collatz is
    component ram_sync
        port (
            clk:     in  std_logic := '0';
            we:      in  std_logic := '0';
            address: in  address_t := (others => '0');
            datain:  in  route_t   := ((others => '0'), (others => '0'), (others => '0'));
            dataout: out route_t   := ((others => '0'), (others => '0'), (others => '0'))
        );
    end component;

    signal we:      std_logic := '0';
    signal address: address_t := (others => '0');
    signal datain:  route_t   := ((others => '0'), (others => '0'), (others => '0'));
    signal dataout: route_t   := ((others => '0'), (others => '0'), (others => '0'));
    -- signals above are connected to ram component

    signal state:  std_logic := '0';  -- when state = 1, simulation is being executed
    signal height: peak_t    := (others => '0');  -- current height

begin
    ram_c: ram_sync port map(
        clk     => clk,
        we      => we,
        address => address,
        datain  => datain,
        dataout => dataout
    );

    process(clk)
        variable shift: std_logic_vector(3 downto 0) := (others => '0');
            -- width to shift in even case
        variable h: peak_t := (others => '0');
            -- temporarily store the current height
        variable step: length_t := (others => '0');
            -- step number used in one operation
        variable tmpres: route_t := ((others => '0'), (others => '0'), (others => '0'));
            -- temporarily store the result

    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                -- halt operation, and reset outputs
                state <= '0';
                done  <= '0';
                we    <= '0';
                address <= (others => '0');
                result  <= ((others => '0'), (others => '0'), (others => '0'));
            end if;

            if (state = '0' and go = '1') then
                -- initialize inner data by input
                we     <= '0';
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

                -- send request to ram
                if (h < 1024) then
                    we <= '0';
                    address <= h(9 downto 0);
                end if;

                if (height = 1) then
                    -- stop operation
                    state <= '0';
                    done  <= '1';

                    -- prevent increment
                    result.length <= result.length;

                    we      <= '1';
                    address <= result.gate;
                    datain  <= result;
                elsif (dataout.gate /= 0) then
                    -- stop operation
                    state <= '0';
                    done  <= '1';

                    tmpres        := result;
                    tmpres.length := tmpres.length + dataout.length - 1;

                    if (dataout.peak > result.peak) then
                        tmpres.peak := dataout.peak;
                    end if;

                    result <= tmpres;

                    we      <= '1';
                    address <= tmpres.gate;
                    datain  <= tmpres;
                end if;
            end if;
        end if;

    end process;
end RTL;
