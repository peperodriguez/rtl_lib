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

  ------------------------------------------------------------------------------------------ 
  --  Constants 
  ------------------------------------------------------------------------------------------ 
  constant C_ADDR_W           : integer := integer(ceil(log2(real(G_DEPTH))));

  constant C_FIFO_CDC_STAGES  : integer := 2;
  constant C_DUMMY_DATA       : std_logic_vector(G_DATA_W - 1 downto 0) := (others => '0');        

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
  signal w_addr_bin_a   : unsigned(C_ADDR_W downto 0);
  signal r_addr_bin_a   : unsigned(C_ADDR_W downto 0);
  signal fifo_wr        : std_logic := '0';
  signal fifo_full_a    : std_logic := '0';

  signal w_addr_bin_b   : unsigned(C_ADDR_W downto 0);
  signal r_addr_bin_b   : unsigned(C_ADDR_W downto 0);
  signal fifo_rd        : std_logic := '0';
  signal fifo_empty_b   : std_logic := '1';

  signal r_addr_gray_a  : uns_pipe_t;
  signal w_addr_gray_b  : uns_pipe_t;

  signal rst_cdc  : std_logic_vector(1 downto 0) := "00";
  signal rst_b    : std_logic := '0';

begin

  assert (G_DEPTH > 1) 
    report "Depth for FIFO must be greater than 1"
    severity failure; 

  -- Reset CDC
  rst_cdc_p : process(i_clk_b)
  begin
    if rising_edge(i_clk_b) then
      rst_cdc <= rst_cdc(0) & i_rst;
    end if;
  end process rst_cdc_p;

  rst_b <= rst_cdc(1);

  -- Crossing write addr
  w_addr_cdc_p : process(i_clk_b)
  begin
    if rising_edge(i_clk_b) then
      w_addr_gray_b <= w_addr_gray_b(C_FIFO_CDC_STAGES - 2 downto 0) & bin2gray(w_addr_bin_a);
      if i_rst = '1' then
        w_addr_gray_b <= (others => (others => '0'));
      end if;
    end if;
  end process w_addr_cdc_p;

  w_addr_bin_b  <= gray2bin(w_addr_gray_b(C_FIFO_CDC_STAGES - 1));

  fifo_empty_b <= '1' when  w_addr_bin_b = r_addr_bin_b else '0';

  -- Crossing read addr
  r_addr_cdc_p : process(i_clk_a)
  begin
    if rising_edge(i_clk_a) then
      r_addr_gray_a <= r_addr_gray_a(C_FIFO_CDC_STAGES - 2 downto 0) & bin2gray(r_addr_bin_b);
      if i_rst = '1' then
        r_addr_gray_a <= (others => (others => '0'));
      end if;
    end if;
  end process r_addr_cdc_p;

  r_addr_bin_a  <= gray2bin(r_addr_gray_a(C_FIFO_CDC_STAGES - 1));  -- Adds one extra latency cycle

  fifo_full_a <=  '1' when  w_addr_bin_a(C_ADDR_W - 1 downto 0) = r_addr_bin_a(C_ADDR_W - 1 downto 0) and
                            w_addr_bin_a(C_ADDR_W) /= r_addr_bin_a(C_ADDR_W) else
                  '0';

  -- Write side
  fifo_wr <= i_en_a and not(fifo_full_a); 

  write_addr_p : process(i_clk_a)
  begin
    if rising_edge(i_clk_a) then

      if fifo_wr = '1' then
        w_addr_bin_a  <= w_addr_bin_a + 1;
      end if;

      if i_rst = '1' then
        w_addr_bin_a  <= (others => '0');
      end if;

    end if;
  end process write_addr_p;

  -- Read side
  fifo_rd <= i_en_b and not(fifo_empty_b); 

  read_addr_p : process(i_clk_b)
  begin
    if rising_edge(i_clk_b) then

      if fifo_rd = '1' then
        r_addr_bin_b  <= r_addr_bin_b + 1;
      end if;

      if i_rst = '1' then
        r_addr_bin_b  <= (others => '0');
      end if;

    end if;
  end process read_addr_p;

  -- Instantiation of the DPRAM
  mem_i : entity work.vl_dpram
  generic map (
    G_ATTR_RAMSTYLE => G_ATTR_RAMSTYLE,
    G_DATA_W        => G_DATA_W,
    G_ADDR_W        => C_ADDR_W

    )
  port map (
    -- Port A
    i_clk_a   => i_clk_a,
    i_d_a     => i_d_a,         
    o_d_a     => open,         
    i_ad_a    => std_logic_vector(w_addr_bin_a(C_ADDR_W - 1 downto 0)),         
    i_we_a    => fifo_wr,
    i_en_a    => '1',
        
    -- Signals
    i_clk_b   => i_clk_b,
    i_d_b     => C_DUMMY_DATA,        
    o_d_b     => o_d_b,        
    i_ad_b    => std_logic_vector(r_addr_bin_b(C_ADDR_W - 1 downto 0)),         
    i_we_b    => '0',
    i_en_b    => '1'
    );
end architecture rtl;

