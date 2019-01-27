library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package types is
    subtype gate_t    is std_logic_vector(9 downto 0);
    subtype peak_t    is std_logic_vector(17 downto 0);
    subtype length_t  is std_logic_vector(7 downto 0);
    subtype address_t is std_logic_vector(9 downto 0);

    type route_t is record
        gate:   gate_t;
        peak:   peak_t;
        length: length_t;
    end record;

    type route4 is array(0 to 3) of route_t;
    type route5 is array(0 to 4) of route_t;
end package types;
