library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.all;

library work;
use work.rv32i_pkg.all;

entity tb_cpu is
end entity;

architecture sim of tb_cpu is
  -- VERSION 1.1.7 - STABLE LONG RUN
  
  function to_hex(v : std_logic_vector) return string is
    variable L : line;
    variable nchars : integer := (v'length+3)/4;
    variable s : string(1 to nchars);
  begin
    hwrite(L, v);
    s := L.all;
    deallocate(L);
    return s;
  end function;

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '1';
  signal ibus_addr   : std_logic_vector(31 downto 0);
  signal ibus_rdata  : std_logic_vector(31 downto 0);
  signal ibus_req    : std_logic;
  signal ibus_ready  : std_logic := '1';
  signal dbus_addr   : std_logic_vector(31 downto 0);
  signal dbus_wdata  : std_logic_vector(31 downto 0);
  signal dbus_rdata  : std_logic_vector(31 downto 0);
  signal dbus_we     : std_logic;
  signal dbus_be     : std_logic_vector(3 downto 0);
  signal dbus_valid  : std_logic;
  signal dbus_ready  : std_logic := '1';
  signal dbg_pc      : std_logic_vector(31 downto 0);
  signal dbg_regfile : regfile_t;

  type mem_t is array (0 to 4095) of std_logic_vector(7 downto 0);
  
  impure function load_mem(file_name : in string) return mem_t is
    file mem_file : text;
    variable L : line;
    variable i : integer := 0;
    variable temp_mem : mem_t := (others => (others => '0'));
    variable hex_val : std_logic_vector(31 downto 0);
    variable status : file_open_status;
  begin
    file_open(status, mem_file, file_name, read_mode);
    if status = open_ok then
        while not endfile(mem_file) and i < 1024 loop
          if not endfile(mem_file) then
            readline(mem_file, L);
            hread(L, hex_val);
            temp_mem(4*i+0) := hex_val(7 downto 0);
            temp_mem(4*i+1) := hex_val(15 downto 8);
            temp_mem(4*i+2) := hex_val(23 downto 16);
            temp_mem(4*i+3) := hex_val(31 downto 24);
            i := i + 1;
          end if;
        end loop;
        file_close(mem_file);
        report "--- MEMORIA CARICATA (" & integer'image(i*4) & " byte) ---" severity warning;
    else
        report "ERRORE: Impossibile aprire program.mem" severity failure;
    end if;
    return temp_mem;
  end function;

  signal memory : mem_t := load_mem("program.mem");

begin
  clk <= not clk after 5 ns;

  process
  begin
    report "--- START SIMULATION ---" severity warning;
    rst <= '1'; wait for 100 ns; 
    rst <= '0';
    wait;
  end process;

  -- Heartbeat ogni 1000 cicli
  process(clk)
    variable count : integer := 0;
  begin
    if rising_edge(clk) then
        if count = 0 then
            report "HEARTBEAT: PC=0x" & to_hex(dbg_pc) severity note;
        end if;
        count := (count + 1) mod 1000;
    end if;
  end process;

  -- Synchronous Memory (Unified)
  process(clk)
    variable addr_i, addr_d : integer;
  begin
    if rising_edge(clk) then
      -- I-Bus
      if is_x(ibus_addr) then
        ibus_rdata <= x"00000013";
      else
        addr_i := to_integer(unsigned(ibus_addr(11 downto 0)));
        if addr_i >= 0 and addr_i <= 4092 then
          ibus_rdata <= memory(addr_i+3) & memory(addr_i+2) & memory(addr_i+1) & memory(addr_i+0);
        else
          ibus_rdata <= x"00000013";
        end if;
      end if;

      -- D-Bus Read
      if is_x(dbus_addr) then
        dbus_rdata <= (others => '0');
      else
        addr_d := to_integer(unsigned(dbus_addr(11 downto 0)));
        if addr_d >= 0 and addr_d <= 4092 then
          dbus_rdata <= memory(addr_d+3) & memory(addr_d+2) & memory(addr_d+1) & memory(addr_d+0);
        else
          dbus_rdata <= (others => '0');
        end if;
      end if;

      -- D-Bus Write & HALT
      if dbus_valid = '1' and dbus_we = '1' and not is_x(dbus_addr) then
        if dbus_addr = x"FFFFFFFC" then
          report "### STRESS TEST COMPLETATO ###" severity warning;
          report "RISULTATO Fibonacci(7)  [0x800]: 0x" & to_hex(memory(2051) & memory(2050) & memory(2049) & memory(2048)) severity warning;
          report "RISULTATO SumSquares(5) [0x804]: 0x" & to_hex(memory(2055) & memory(2054) & memory(2053) & memory(2052)) severity warning;
          report "RISULTATO CheckStatus   [0x808]: 0x" & to_hex(memory(2059) & memory(2058) & memory(2057) & memory(2056)) severity warning;
          finish;
        end if;

        addr_d := to_integer(unsigned(dbus_addr(11 downto 0)));
        if addr_d >= 0 and addr_d <= 4092 then
          report "WRITE: Addr=0x" & to_hex(dbus_addr) & " Data=0x" & to_hex(dbus_wdata) severity note;
          for i in 0 to 3 loop
            if dbus_be(i) = '1' then memory(addr_d + i) <= dbus_wdata(8*i+7 downto 8*i); end if;
          end loop;
        end if;
      end if;
    end if;
  end process;

  uut: entity work.cpu_top
    port map (
      clk => clk, rst => rst,
      ibus_addr => ibus_addr, ibus_rdata => ibus_rdata, ibus_req => ibus_req, ibus_ready => ibus_ready,
      dbus_addr => dbus_addr, dbus_wdata => dbus_wdata, dbus_rdata => dbus_rdata,
      dbus_we => dbus_we, dbus_be => dbus_be, dbus_valid => dbus_valid, dbus_ready => dbus_ready,
      dbg_pc => dbg_pc, dbg_regfile => dbg_regfile
    );

end architecture;
