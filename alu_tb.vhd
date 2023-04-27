-- Filename: alu_tb.vhd

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
-- Test Bench for ALU Exercise

entity ALU_TB is
end;

-------------------------------------------------------------------
-- Randomized test using coverage with OSVVM                     --
-------------------------------------------------------------------
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
library osvvm;
use osvvm.RandomPkg.all;
use osvvm.CoveragePkg.all;

architecture osvvmbench of ALU_TB is

  constant OP_SIZE       : POSITIVE := 4;

  -- Signals connected to the ALU
  signal Cout, Equal : Std_logic;
  signal F: std_logic_vector(7 downto 0);
  signal A, B: std_logic_vector(7 downto 0) := (others => '0');
  signal Op: std_logic_vector(OP_SIZE-1 downto 0);

  -- Delay constants
  constant OP_DELAY : TIME := 10 ns;
 
  shared variable cp_Op : covPType;
  shared variable cp_A : covPType;
  shared variable cp_B : covPType;
  shared variable cp_A_Op : covPType;
  shared variable cp_B_Op : covPType;
  shared variable cp_A_B_Op : covPType;
  
  shared variable cp_CoutF_Op : covPType;
  
  signal Stop : BOOLEAN; 
  signal CoutF : std_logic_vector(8 downto 0);
  
begin

  coutF <= Cout & F;
  
  UUT: entity WORK.ALU(A1)
    port map ( A     => A,
               B     => B,
               Op    => Op,
               F     => F,
               Cout  => Cout,
               Equal => Equal);

  -- Randomized stimulus
  Stim: process
    -- The random variables
    variable RndOp : RandomPType;
    variable RndB : RandomPType;
    variable RndA : RandomPType;

    -- ncycles counts how many vectors were applied
    variable ncycles : natural;
    
    -- alldone is set true when simulation is complete
    variable alldone : boolean;
    
    -- integer versions of the inputs to the device under test
    variable opInt : natural range 0 to 15;
    variable AInt, BInt : natural range 0 to 255;
  begin
    RndOp.InitSeed(RndOp'instance_name);
    RndA.InitSeed(RndA'instance_name);
    RndB.InitSeed(RndB'instance_name);
    RndOp.setRandomParm(NORMAL, 8.0, 3.0);

    --
    -- allDone indicates end of test
    -- NOW < 1ms is a timeout in case allDone is not asserted
    --
    while not allDone and (NOW < 1 ms)  loop
        
        Op <= RndOp.Randslv(0, 15, (3,12,13),4);
        A <= RndA.Randslv(0, 255, 8);
        B <= RndB.randslv(0,255,8);             
        wait for OP_DELAY;
        
        -- stop simulating when every combination of CoutF and Op
        -- has been covered
        allDone := cp_CoutF_Op.isCovered;
        nCycles := nCycles + 1;
    end loop;
    wait for 1 ns;
    report "Number of simulation cycles = " & to_string(nCycles);
    STOP <= TRUE;
    wait;
  end process Stim;

  
  InitCoverage: process --sets up coverpoint bins
  begin
    -- 15 discrete bins for Op
    cp_Op.AddBins(GenBin(0,15));
    
    -- 8 equal bins for A, e.g. 0-7, 8-15... 248-255
    cp_A.AddBins(GenBin(0,255,8));
    
    -- 10 bins for B
    cp_B.AddBins(GenBin(1,254,8));
    cp_B.AddBins(GenBin(0,0));
    cp_B.AddBins(GenBin(255,255));
    
    -- Look for every combination of A and Op
    cp_A_Op.AddCross(GenBin(0,255,8),GenBin(0,15));
    
    -- look for every combination of B and Op
    cp_B_Op.AddCross(GenBin(0,255,8),GenBin(0,15));
    
    -- Every combination of AxBxOp
    cp_A_B_Op.AddCross(GenBin(0,255,8),GenBin(0,255,8),GenBin(0,15));
    
    -- Every combination of (F,Cout) x Op
    cp_CoutF_Op.AddCross( GenBin(0, 511, 16),
                          GenBin(0, 15)
                         );
    wait;
  end process InitCoverage;



  Sample: process
  begin
    loop
      -- trigger a new sample when Op changes
      wait on Op;
      wait for 1 ns; -- wait until all signals stable
      
      -- Sample the simple coverpoints
      cp_Op.ICover      (TO_INTEGER(UNSIGNED(Op)));
      cp_A.ICover       (TO_INTEGER(UNSIGNED(A)) );
      cp_B.ICover       (TO_INTEGER(UNSIGNED(B)) );
      
      -- The remaining coverpoints are crosses.
      -- The following line uses integer_vector, which must be declared, or 
      -- requires VHDL 2008.
      --cp_A_Op.ICover    ( integer_vector'(TO_INTEGER(UNSIGNED(A) ),TO_INTEGER(UNSIGNED(Op)) ) );
      cp_B_Op.ICover    ( (TO_INTEGER(UNSIGNED(B)), TO_INTEGER(UNSIGNED(Op))) );
      cp_A_B_Op.ICover  ( (TO_INTEGER(UNSIGNED(A)), TO_INTEGER(UNSIGNED(B)), TO_INTEGER(UNSIGNED(Op))) );
      -- to avoid problems with X or U, we use to_01 to convert all values ot 0 or 1
      cp_CoutF_Op.ICover( (TO_INTEGER(unsigned(to_01(coutf))), TO_INTEGER(unsigned(op)) ) );
    end loop;
  end process Sample;


  CoverReport: process
  begin
    wait until STOP;
    report "CoutF x Op";
    cp_CoutF_Op.writebin;
    report("B Coverage details");
    cp_B.WriteBin;
    report "coverage holes " & to_string(cp_coutF_OP.CountCovHoles);
  end process CoverReport;
    
end architecture osvvmbench;
