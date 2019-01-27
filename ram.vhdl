-- Original VHDL source code Copyright 2008 DOULOS
-- https://www.doulos.com/knowhow/vhdl_designers_guide/models/simple_ram_model/
-- Modified by: Hiroto Nishikawa

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.types.all;

entity ram_sync is
    port (
        clk: in std_logic := '0';
        we:  in std_logic := '0';
        address: in  address_t := (others => '0');
        datain:  in  route_t := ((others => '0'), (others => '0'), (others => '0'));
        dataout: out route_t := ((others => '0'), (others => '0'), (others => '0'))
    );
end entity ram_sync;

architecture RTL of ram_sync is

    type ram_type is array (0 to 1023) of route_t;

    signal ram: ram_type  := (others => ((others => '0'), (others => '0'), (others => '0')));
    signal read_address: address_t := (others => '0');

begin
    process(clk) begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(address))) <= datain;
            end if;
            read_address <= address;
        end if;

        dataout <= ram(to_integer(unsigned(read_address)));
    end process;
end architecture RTL;
