-- Testbench for JTAG TAP Controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_jtag_tap is
end tb_jtag_tap;

architecture behavior of tb_jtag_tap is

    type state_type is (TLR,RTI, SDR, CDR, SDR_SHIFT, E1DR, PDR, E2DR, UDR,
                        SIR, CIR, SIR_SHIFT, E1IR, PIR, E2IR, UIR);

    -- Signals
    signal TCK   : std_logic := '0';
    signal TMS   : std_logic := '0';
    signal TDI   : std_logic := '0';
    signal TDO   : std_logic;
    signal RST   : std_logic := '1';  -- Test reset
    signal input_data : std_logic_vector(31 downto 0) := X"AAAAAAAA";
    signal output_data : std_logic_vector(31 downto 0) := (others => '0');

    signal STATE_OUT : std_logic_vector (3 downto 0);

    -- Clock period
    constant TCK_PERIOD : time := 20 ns;

    -- Function to convert STD_LOGIC_VECTOR to STATE_TYPE
    function to_state_type(sv : STD_LOGIC_VECTOR(3 downto 0)) return STATE_TYPE is
    begin
        case sv is
            when "0000" => return TLR;
            when "0001" => return RTI;
            when "0010" => return SDR;
            when "0011" => return CDR;
            when "0100" => return SDR_SHIFT;
            when "0101" => return E1DR;
            when "0110" => return PDR;
            when "0111" => return E2DR;
            when "1000" => return UDR;
            when "1001" => return SIR;
            when "1010" => return CIR;
            when "1011" => return SIR_SHIFT;
            when "1100" => return E1IR;
            when "1101" => return PIR;
            when "1110" => return E2IR;
            when "1111" => return UIR;
            when others => return TLR;
        end case;
    end function;
begin

    -- DUT instantiation
    uut: entity work.JTAG_TAP_CONTROLLER
        port map (
            TCK  => TCK,
            TMS  => TMS,
            TDI  => TDI,
            TDO  => TDO,
            RST => RST,

            -- Debug Port
            STATE_OUT => STATE_OUT
        );

    -- Generate TCK clock
    TCK_process: process
    begin
        while now < 2000 ns loop  -- Run simulation for 2000 ns
            TCK <= '0';
            wait for TCK_PERIOD / 2;
            TCK <= '1';
            wait for TCK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Main test process
    test_process: process
        variable expected_state : STATE_TYPE;
    begin
        -- Reset the TAP controller
        RST <= '1';
        wait for 3 * TCK_PERIOD;
        RST <= '0';
        wait for TCK_PERIOD;

        -- Go to RTI state
        TMS <= '0';
        wait for TCK_PERIOD;
        assert(to_state_type(STATE_OUT) = RTI) report "Error: Expected RTI state" severity error;

        -- Go to Shift-DR state
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-DR
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-DR
        assert(to_state_type(STATE_OUT) = SDR_SHIFT) report "Error: Expected SDR_SHIFT state" severity error;
        TDI <= input_data(31);
        -- Shift in test data
        for i in 30 downto 0 loop
            wait for TCK_PERIOD / 2;  -- Wait for half clock cycle
            output_data <= output_data(30 downto 0) & TDO;    -- Capture TDO at the middle of the clock cycle
            wait for TCK_PERIOD / 2;  -- Wait for the other half clock cycle
            TDI <= input_data(i);
        end loop;
        
        

        -- Exit Shift-DR
        TMS <= '1'; wait for TCK_PERIOD; -- Exit1-DR
        output_data <= output_data(30 downto 0) & TDO; 
        TMS <= '1'; wait for TCK_PERIOD; -- Update-DR
        TMS <= '0'; wait for TCK_PERIOD; -- RTI

        -- Check output data
        assert(output_data = X"C0FFEE00") report "Error: Unexpected output data " severity error;

        -- Go to Shift-DR state again
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-DR
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-DR

        TDI <= input_data(31);
        -- Shift in test data
        for i in 30 downto 0 loop
            wait for TCK_PERIOD / 2;  -- Wait for half clock cycle
            output_data <= output_data(30 downto 0) & TDO;    -- Capture TDO at the middle of the clock cycle
            wait for TCK_PERIOD / 2;  -- Wait for the other half clock cycle
            TDI <= input_data(i);
        end loop;

        TMS <= '1'; wait for TCK_PERIOD; -- Exit1-DR
        output_data <= output_data(30 downto 0) & TDO; 
        -- Check if the shifted out data matches the input
        assert(output_data = input_data) report "Error: Shifted out data doesn't match input " severity error;

        -- End test

        TMS <= '1'; wait for TCK_PERIOD; -- Update-DR
        TMS <= '0'; wait for TCK_PERIOD; -- RTI

        report "Test completed successfully";
        wait;
    end process;

end behavior;