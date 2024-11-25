entity clocks_7s_extphy_se is
	generic(
		CLK_FR_FREQ: real := 100.0; -- updated to 100 MHz input clock frequency
		CLK_VCO_FREQ: real := 1000.0; -- VCO freq 1000MHz
		CLK_AUX_FREQ: real := 40.0 -- Aux Clock frequency
	);
	port(
		sysclk: in std_logic;
		clko_125: out std_logic;
		clko_125_90: out std_logic;
		clko_200: out std_logic;
		clko_ipb: out std_logic; 
		clko_aux: out std_logic;
		locked: out std_logic;
		nuke: in std_logic;
		soft_rst: in std_logic;
		rsto_125: out std_logic;
		rsto_ipb: out std_logic;
		rsto_aux: out std_logic;
		rsto_ipb_ctrl: out std_logic;
		onehz: out std_logic
	);
end clocks_7s_extphy_se;

architecture rtl of clocks_7s_extphy_se is
	
	signal dcm_locked, sysclk_u, sysclk_i, clk_ipb_i, clk_125_i, clk_125_90_i, clk_aux_i, clkfb, clk_ipb_b, clk_125_b, clk_aux_b, clk_200_i: std_logic;
	signal d17, d17_d: std_logic;
	signal nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, srst, rst_ipb, rst_125, rst_aux, rst_ipb_ctrl: std_logic := '1';
	signal rctr: unsigned(3 downto 0) := "0000";

begin

	ibufgds0: IBUFG port map(
		i => sysclk,
		o => sysclk_u
	);
	
	bufhsys: BUFH port map(
		i => sysclk_u,
		o => sysclk_i
	);
	
	bufg125: BUFG port map(
		i => clk_125_i,
		o => clk_125_b
	);

	clko_125 <= clk_125_b;

	bufg125_90: BUFG port map(
		i => clk_125_90_i,
		o => clko_125_90
	);
	
	bufgipb: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);
	
	clko_ipb <= clk_ipb_b;
	
	bufg200: BUFG port map(
		i => clk_200_i,
		o => clko_200
	);	
	
	bufgaux: BUFG port map(
		i => clk_aux_i,
		o => clk_aux_b
	);

	clko_aux <= clk_aux_b;

	mmcm: MMCME2_BASE
		generic map(
			clkin1_period => 1000.0 / CLK_FR_FREQ,
			clkfbout_mult_f => CLK_VCO_FREQ / CLK_FR_FREQ,
			clkout1_divide => integer(CLK_VCO_FREQ / 50.00), -- 50 MHz clock for clko_125
			clkout2_divide => integer(CLK_VCO_FREQ / 50.00), -- 50 MHz clock with phase shift for clko_125_90
			clkout2_phase => 45.0, -- 45 degree phase shift
			clkout3_divide => integer(CLK_VCO_FREQ / 31.25),
			clkout4_divide => integer(CLK_VCO_FREQ / 200.00),
			clkout5_divide => integer(CLK_VCO_FREQ / CLK_AUX_FREQ)
		)
		port map(
			clkin1 => sysclk_i,
			clkfbin => clkfb,
			clkfbout => clkfb,
			clkout1 => clk_125_i,
			clkout2 => clk_125_90_i,
			clkout3 => clk_ipb_i,
			clkout4 => clk_200_i,
			clkout5 => clk_aux_i,
			locked => dcm_locked,
			rst => '0',
			pwrdwn => '0'
		);
	
	clkdiv: entity work.ipbus_clock_div
		port map(
			clk => sysclk_i,
			d17 => d17,
			d28 => onehz
		);
	
	process(sysclk_i)
	begin
		if rising_edge(sysclk_i) then
			d17_d <= d17;
			if d17='1' and d17_d='0' then
				rst <= nuke_d2 or not dcm_locked;
				nuke_d <= nuke_i; -- Time bomb (allows return packet to be sent)
				nuke_d2 <= nuke_d;
			end if;
		end if;
	end process;
		
	locked <= dcm_locked;
	srst <= '1' when rctr /= "0000" else '0';
	
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rst_ipb <= rst or srst;
			nuke_i <= nuke;
			if srst = '1' or soft_rst = '1' then
				rctr <= rctr + 1;
			end if;
		end if;
	end process;
	
	rsto_ipb <= rst_ipb;
	
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rst_ipb_ctrl <= rst;
		end if;
	end process;
	
	rsto_ipb_ctrl <= rst_ipb_ctrl;
	
	process(clk_125_b)
	begin
		if rising_edge(clk_125_b) then
			rst_125 <= rst;
		end if;
	end process;
	
	rsto_125 <= rst_125;

	process(clk_aux_b)
	begin
		if rising_edge(clk_aux_b) then
			rst_aux <= rst;
		end if;
	end process;
	
	rsto_aux <= rst_aux;
			
end rtl;
