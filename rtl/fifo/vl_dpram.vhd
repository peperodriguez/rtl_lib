-----------------------------------------------------------------
-- Name     : vl_dpram --
-----------------------------------------------------------------
-- Description:
--  Simple dual-port RAM with common data width. 
-- 
-- Author   : peperodriguez --
-- Created  : 24/11/19 --
--------------------------------------------------------------
--
-- Changelog:
-- - 24/11/19 peperodriguez => First version
--

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
---- synthesis translate_off
--library unisim;
--use unisim.vcomponents.all;
---- synthesis translate_on

entity vl_dpram is
  generic (
    G_ATTR_RAMSTYLE : string := "auto";
    G_DATA_W        : integer := 8;
    G_ADDR_W        : integer := 10
  );
  port (
    -- Port A
    i_clk_a   : in  std_logic;
    i_d_a     : in  std_logic_vector(G_DATA_W - 1 downto 0);         
    o_d_a     : out std_logic_vector(G_DATA_W - 1 downto 0);         
    i_ad_a    : in  std_logic_vector(G_ADDR_W - 1 downto 0);         
    i_we_a    : in  std_logic;
    i_en_a    : in  std_logic;
        
    -- Signals
    i_clk_b   : in  std_logic;
    i_d_b     : in  std_logic_vector(G_DATA_W - 1 downto 0);        
    o_d_b     : out std_logic_vector(G_DATA_W - 1 downto 0);        
    i_ad_b    : in  std_logic_vector(G_ADDR_W - 1 downto 0);         
    i_we_b    : in  std_logic;
    i_en_b    : in  std_logic
        
  );
end vl_dpram;

architecture rtl of vl_dpram  is
  ------------------------------------------------------------------------------------------ 
  --  Types and Constants 
  ------------------------------------------------------------------------------------------ 
  type mem_t is array ((2**G_ADDR_W) - 1 downto 0) of std_logic_vector(G_DATA_W - 1 downto 0);


  ------------------------------------------------------------------------------------------ 
  --  Components
  ------------------------------------------------------------------------------------------ 

  ------------------------------------------------------------------------------------------ 
  --  Signals and variables
  ------------------------------------------------------------------------------------------ 
  shared variable mem : mem_t := (others => (others => '0'));
  attribute RAM_STYLE : string;
  attribute RAM_STYLE of mem: variable is G_ATTR_RAMSTYLE;

  signal dout_a   : std_logic_vector(G_DATA_W - 1 downto 0);
  signal dout_b   : std_logic_vector(G_DATA_W - 1 downto 0);
  signal ad_idx_a : integer := 0;
  signal ad_idx_b : integer := 0;

begin

  ad_idx_a  <= to_integer(unsigned(i_ad_a));
  ad_idx_b  <= to_integer(unsigned(i_ad_b));

  p_port_a : process(i_clk_a)
  begin
    if rising_edge(i_clk_a) then
      if i_en_a = '1' then
        dout_a  <= mem(ad_idx_a);
        if i_we_a = '1' then
          mem(ad_idx_a) := i_d_a;
        end if;
      end if;
    end if;
  end process p_port_a;

  p_port_b : process(i_clk_b)
  begin
    if rising_edge(i_clk_b) then
      if i_en_b = '1' then
        dout_b  <= mem(ad_idx_b);
        if i_we_b = '1' then
          mem(ad_idx_b) := i_d_b;
        end if;
      end if;
    end if;
  end process p_port_b;

end architecture rtl;

