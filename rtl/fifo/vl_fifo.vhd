-----------------------------------------------------------------
-- Name     : vl_fifo --
-----------------------------------------------------------------
-- Description:
--
-- 
-- Author   : peperodriguez --
-- Created  : 29/11/19 --
--------------------------------------------------------------
--
-- Changelog:
-- - 29/11/19 peperodriguez => First version
--

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
---- synthesis translate_off
--library unisim;
--use unisim.vcomponents.all;
---- synthesis translate_on
use work.vl_gen_pkg.all;

entity vl_fifo is
  generic (
    G_DATA_W        : integer := 32;
    G_ATTR_RAMSTYLE : string := "auto";
    G_DEPTH         : integer := 1024; 
    G_CDC_EN        : boolean := true
  );
  port (
    i_rst         : in  std_logic; -- domain a, CDC to b

    -- Port A : Input
    i_clk_a       : in  std_logic;
    i_d_a         : in  std_logic_vector(G_DATA_W - 1 downto 0); 
    i_en_a        : in  std_logic;
    o_full_a      : out std_logic;
    o_empty_a     : out std_logic;

    -- Port B : Output
    i_clk_b       : in  std_logic;
    o_d_b         : out std_logic_vector(G_DATA_W - 1 downto 0); 
    i_en_b        : in  std_logic;
    o_full_b      : out std_logic;
    o_empty_b     : out std_logic
        
  );
end vl_fifo;

architecture rtl of vl_fifo  is

  assert (G_DEPTH > 1) 
    report "Depth for FIFO must be greater than 1"
    severity failure; 


  ------------------------------------------------------------------------------------------ 
  --  Constants 
  ------------------------------------------------------------------------------------------ 
  constant C_ADDR_W           : integer := integer(ceil(log2(real(G_DEPTH))));
  constant C_FIFO_CDC_STAGES  : integer := 2;

  ------------------------------------------------------------------------------------------ 
  --  Types 
  ------------------------------------------------------------------------------------------ 
  type uns_pipe_t is array (C_FIFO_CDC_STAGES - 1 downto 0) of unsigned(C_ADDR_W - 1 downto 0);

  ------------------------------------------------------------------------------------------ 
  --  Components
  ------------------------------------------------------------------------------------------ 

  ------------------------------------------------------------------------------------------ 
  --  Signals
  ------------------------------------------------------------------------------------------ 
  signal w_addr_bin_a   : unsigned(C_ADDR_W - 1 downto 0);
  signal r_addr_bin_a   : unsigned(C_ADDR_W - 1 downto 0);
  signal w_addr_bin_b   : unsigned(C_ADDR_W - 1 downto 0);
  signal r_addr_bin_b   : unsigned(C_ADDR_W - 1 downto 0);

  signal w_addr_gray_a  : unsigned(C_ADDR_W - 1 downto 0);
  signal r_addr_gray_a  : unsigned(C_ADDR_W - 1 downto 0);
  signal w_addr_gray_b  : unsigned(C_ADDR_W - 1 downto 0);
  signal r_addr_gray_b  : unsigned(C_ADDR_W - 1 downto 0);
begin
  -- Instantiation of the DPRAM
  mem_i : entity work.dpram
  generic map (
    G_ATTR_RAMSTYLE => G_ATTR_RAMSTYLE,
    G_DATA_W        => G_DATA_W,
    G_ADDR_W        => C_DATA_W

    )
  port map (
    -- Port A
    i_clk_a   => i_clk_a,
    i_d_a     => i_d_a,         
    o_d_a     => open,         
    i_ad_a    => w_addr_bin_a,         
    i_we_a    : in  std_logic;
    i_en_a    : in  std_logic;
        
    -- Signals
    i_clk_b   => i_clk_b,
    i_d_b     : in  std_logic_vector(G_DATA_W - 1 downto 0);        
    o_d_b     : out std_logic_vector(G_DATA_W - 1 downto 0);        
    i_ad_b    => r_addr_bin_b,         
    i_we_b    => '0',
    i_en_b    : in  std_logic
    );
end architecture rtl;

