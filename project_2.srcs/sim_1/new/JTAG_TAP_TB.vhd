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
    signal RST  : std_logic := '1';  -- Test reset
    signal input_data : std_logic_vector(31 downto 0) := X"DEADBEEF";
    signal output_data : std_logic_vector(31 downto 0);

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
            when "1101" => return PDR;
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
        while true loop
            TCK <= '0';
            wait for TCK_PERIOD / 2;
            TCK <= '1';
            wait for TCK_PERIOD / 2;
        end loop;
    end process;

    -- Main test process
    test_process: process
   variable expected_state : STATE_TYPE;
    begin
        -- Reset the TAP controller
        RST <= '1';
        wait for 3 * TCK_PERIOD;
        RST <= '0';


        expected_state := TLR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected TLR state" severity error;

        -- Move to 'Run-Test/Idle' state
        TMS <= '0';  -- From Test-Logic-Reset to Run-Test/Idle
        wait for TCK_PERIOD;
        expected_state := RTI;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected RTI state" severity error;

        -- Move to 'Select-DR-Scan' state
        TMS <= '1';  -- From Run-Test/Idle to Select-DR-Scan
        wait for TCK_PERIOD;
        expected_state := SDR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected SDR state" severity error;

        -- Move to 'Capture-DR' state
        TMS <= '0';  -- From Select-DR-Scan to Capture-DR
        wait for TCK_PERIOD;
        expected_state := CDR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected CDR state" severity error;


        -- Move to 'SHIFT-DR' state
        TMS <= '0';  -- From CAPTURE-DR to SDR-SHIFT
        wait for 2*TCK_PERIOD;
        expected_state := SDR_SHIFT;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected SDR_SHIFT state" severity error;


        -- Move to 'EXIT1-DR' state
        TMS <= '1';
        wait for TCK_PERIOD;
        expected_state := E1DR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected SDR_SHIFT state" severity error;

        -- Move to PDR state
        TMS <= '0';
        wait for 2*TCK_PERIOD;
        expected_state := PDR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected PDR state" severity error;

        -- Move to 'Exit2-DR' state
        TMS <= '1';
        wait for TCK_PERIOD;
        expected_state := E2DR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected E2DR state" severity error;

        -- Move to 'Update-DR' state
        TMS <= '1';  -- From Exit2-DR to Update-DR
        wait for TCK_PERIOD;
        expected_state := UDR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected UDR state" severity error;

        -- Return back to 'Capture-DR' state
        TMS <= '1';  -- From Update-DR to Shift-DR
        wait for TCK_PERIOD;
        TMS<= '0';
        wait for TCK_PERIOD;       

        -- Move to 'Exit 1-DR' state
        TMS <= '1';  -- From Capture-DR to Exit 1-DR
        wait for TCK_PERIOD;
        expected_state := E1DR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected E1DR state" severity error;

        -- Move to 'Update-DR' state
        TMS <= '1';  -- From Exit 1-DR to Update-DR
        wait for TCK_PERIOD;
        expected_state := UDR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected UDR state" severity error;

        -- Move to 'Run-Test/Idle' state
        TMS <= '0';  -- From Update-DR to Run-Test/Idle
        wait for TCK_PERIOD;
        expected_state := RTI;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected RTI state" severity error;

        -- Move to 'Select-IR-Scan' state
        TMS <= '1';  -- From Run-Test/Idle to Select-IR-Scan Through Select-DR-Scan
        wait for 2*TCK_PERIOD;
        expected_state := SIR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected SIR state" severity error;

        -- Move to 'Capture-IR' state
        TMS <= '0';  -- From Select-IR-Scan to Capture-IR
        wait for TCK_PERIOD;
        expected_state := CIR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected CIR state" severity error;

        -- Move to 'Exit 1-IR' state
        TMS <= '1';  -- From Capture-IR to Exit 1-IR
        wait for TCK_PERIOD;
        expected_state := E1IR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected E1IR state" severity error;

        -- Move to 'Update-IR' state
        TMS <= '1';  -- From Exit 1-IR to Update-IR
        wait for TCK_PERIOD;
        expected_state := UIR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected UIR state" severity error;

        -- Move to 'Run-Test/Idle' state
        TMS <= '0';  -- From Update-IR to Run-Test/Idle
        wait for TCK_PERIOD;
        expected_state := RTI;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected RTI state" severity error;

        -- Move to 'Test-Logic-Reset' state
        TMS <= '1';
        wait for 3*TCK_PERIOD;
        expected_state := TLR;
        assert(to_state_type(STATE_OUT) = expected_state) report "Error: Expected TLR state" severity error;


        wait;
    end process;

end behavior;
