-----------------------------------------------------------------
-- Name     : vl_gen_pkg --
-----------------------------------------------------------------
-- Description:
--
-- 
-- Author   : peperodriguez --
-- Created  : 30/11/19 --
--------------------------------------------------------------
--
-- Changelog:
-- - 30/11/19 peperodriguez => First version
--

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
---- synthesis translate_off
--library unisim;
--use unisim.vcomponents.all;
---- synthesis translate_on

package vl_gen_pkg is
   
  ------------------------------------------------------------------------------------------ 
  --  Types 
  ------------------------------------------------------------------------------------------ 

  ------------------------------------------------------------------------------------------ 
  --  Functions 
  ------------------------------------------------------------------------------------------ 
  function bin2gray (signal d : unsigned) return unsigned;
  function bin2gray (signal d : std_logic_vector) return std_logic_vector;
  function gray2bin (signal d : unsigned) return unsigned;
  function gray2bin (signal d : std_logic_vector) return std_logic_vector;

end package;

package body vl_gen_pkg  is

  function bin2gray (signal d : unsigned) return unsigned is
    variable v_res : unsigned(d'length - 1 downto 0) := (others => '0');
  begin

    v_res(d'length - 1) := d(d'length - 1);

    for k in 0 to d'length - 2 loop
      v_res(k) := d(k + 1) xor d(k);
    end loop;

    return v_res;
  end bin2gray;
  

  function bin2gray (signal d : std_logic_vector) return std_logic_vector is
    variable v_res : std_logic_vector(d'length - 1 downto 0) := (others => '0');
  begin
    v_res(d'length - 1) := d(d'length - 1);

    for k in 0 to d'length - 2 loop
      v_res(k) := d(k + 1) xor d(k);
    end loop;

    return v_res;
  end bin2gray;

  function gray2bin (signal d : unsigned) return unsigned is
    variable v_res : unsigned(d'length - 1 downto 0) := (others => '0');
  begin

    v_res(d'length - 1) := d(d'length - 1);

    for k in d'length - 2 downto 0 loop
      v_res(k) := d(k + 1) xor d(k);
    end loop;

    return v_res;
  end gray2bin;

  function gray2bin (signal d : std_logic_vector) return std_logic_vector is
    variable v_res : std_logic_vector(d'length - 1 downto 0) := (others => '0');
  begin
    v_res(d'length - 1) := d(d'length - 1);

    for k in d'length - 2 downto 0 loop
      v_res(k) := d(k + 1) xor d(k);
    end loop;

    return v_res;
  end gray2bin;

end package body;

