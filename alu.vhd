-- Filename: alu.vhd

-- ----------------------------------------------------------------------
-- Copyright (c) 2013 by Doulos Ltd.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------
-- Solution to ALU Exercise

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;

entity ALU is
  port (A, B : in  std_logic_vector(7 downto 0);
        Op   : in  std_logic_vector(3 downto 0);
        F    : out std_logic_vector(7 downto 0);
        Cout : out Std_logic;
        Equal: out Std_logic);
end;


architecture A1 of ALU is

  -- Simple solution...
  -- Easy to read, but relies on resource sharing

  signal Tmp: Signed(8 downto 0);
  signal A9, B9: Signed(8 downto 0);

begin

  A9 <= Resize(signed(A), 9);
  B9 <= Resize(signed(B), 9);

  process (A, A9, B9, Op)
  begin
    case Op is
    when "0000" =>
      -- AplusB
      Tmp <= A9 + B9;
    when "0001" =>
      -- AminusB
      Tmp <= A9 - B9;
    when "0010" =>
      -- BminusA
      Tmp <= B9 - A9;
    when "0100" =>
      -- OnlyA
      Tmp <= A9;
    when "0101" =>
      -- OnlyB
      Tmp <= B9;
    when "0110" =>
      -- minusA
      Tmp <= -A9;
    when "0111" =>
      -- minusB
      Tmp <= -B9;
    when "1000" =>
      -- ShiftleftA
      Tmp <= signed(A) & '0';
    when "1001" =>
      -- ShiftrightA
      Tmp <= "00" & signed(A(7 downto 1));
    when "1010" =>
      -- RotateleftA
      Tmp <= signed(A) & A(7);
    when "1011" =>
      -- RotaterightA
      Tmp <= '0'& A(0) & signed(A(7 downto 1));
    when "1110" =>
      -- AllZeros
      Tmp <= (others => '0');
    when "1111" =>
      -- AllOnes
      Tmp <= (others => '1');
    when others =>
      -- Dummy3
      -- Dummy12
      -- Dummy13
      Tmp <= (others => '-');
    end case;
  end process;

  Equal <= '1' when (A = B) else '0';
  Cout <= Tmp(8);

  F <= std_logic_vector(Tmp(7 downto 0));

end;
