----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.10.2024 11:58:00
-- Design Name: 
-- Module Name: JTAG - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity JTAG_TAP_CONTROLLER is
    Port ( 
        TMS : in STD_LOGIC;
        TCK : in STD_LOGIC;
        RST : in STD_LOGIC;
        TDO : out STD_LOGIC;
        TDI : in std_logic;
        IR_OUT: out std_logic_vector (7 downto 0); -- Instruction Register Output
        DR_OUT: out std_logic_vector (31 downto 0); -- Data Register Output

        -- Debug Port for State
        STATE_OUT: out std_logic_vector (3 downto 0) -- Debug
        );
end JTAG_TAP_CONTROLLER;

architecture Behavioral of JTAG_TAP_CONTROLLER is

    type state_type is (TLR,RTI, SDR, CDR, SDR_SHIFT, E1DR, PDR, E2DR, UDR,
                        SIR, CIR, SIR_SHIFT, E1IR, PIR, E2IR, UIR);
    SIGNAL STATE,NEXT_STATE : state_type;       

    -- Function to convert STD_LOGIC_VECTOR to STATE_TYPE
-- Function to convert STATE_TYPE to STD_LOGIC_VECTOR
    function to_slv(st : STATE_TYPE) return STD_LOGIC_VECTOR is
    begin
        case st is
            when TLR => return "0000";
            when RTI => return "0001";
            when SDR => return "0010";
            when CDR => return "0011";
            when SDR_SHIFT => return "0100";
            when E1DR => return "0101";
            when PDR => return "0110";
            when E2DR => return "0111";
            when UDR => return "1000";
            when SIR => return "1001";
            when CIR => return "1010";
            when SIR_SHIFT => return "1011";
            when E1IR => return "1100";
            when PIR => return "1101";
            when E2IR => return "1110";
            when UIR => return "1111";
        end case;
    end function;
    
    -- Data size
    constant DATA_SIZE : integer := 31; -- replace 32 with the size of your register

    -- Signals for Data Register (DR) and Instruction Register (IR)

    signal ir : std_logic_vector (7 downto 0);

    -- 32 bit internal registers
    signal curr_local_dr_reg : std_logic_vector (DATA_SIZE downto 0) := X"C0FFEE00";
    signal next_local_dr_reg : std_logic_vector (DATA_SIZE downto 0) := X"C0FFEE00";

    -- Counter
    signal counter : integer := 0;

    begin

    --State Transition
    process (TCK, RST)
    begin 
        if RST = '1' then
            state <= TLR;
        elsif rising_edge (TCK) then
            state <= next_state;
        end if;

    end process;

    --State Transition Logic
    process (STATE, TMS)
    begin
        case( STATE ) is
        
            when TLR =>
            if TMS = '1' then
                NEXT_STATE <= TLR;
            else
                NEXT_STATE <= RTI;
            end if;
            
        when RTI =>
            if TMS = '1' then
                NEXT_STATE <= SDR;
            else
                NEXT_STATE <= RTI;
            end if;
            
        when SDR =>
            if TMS = '1' then
                NEXT_STATE <= SIR;
            else
                NEXT_STATE <= CDR;
            end if;
            
        when CDR =>
            if TMS = '1' then
                NEXT_STATE <= E1DR; 
            else
                NEXT_STATE <= SDR_SHIFT;
            end if;
            
        when SDR_SHIFT =>
            if TMS = '1' then
                NEXT_STATE <= E1DR;
            else
                NEXT_STATE <= SDR_SHIFT;
            end if;
            
        when E1DR =>
            if TMS = '1' then
                NEXT_STATE <= UDR;
            else
                NEXT_STATE <= PDR;
            end if;
            
        when PDR =>
            if TMS = '1' then
                NEXT_STATE <= E2DR;
            else
                NEXT_STATE <= PDR;
            end if;
            
        when E2DR =>
            if TMS = '1' then
                NEXT_STATE <= UDR;
            else
                NEXT_STATE <= SDR;
            end if;
            
        when UDR =>
            if TMS = '1' then
                NEXT_STATE <= SDR;
            else
                NEXT_STATE <= RTI;
            end if;
            
        when SIR =>
            if TMS = '1' then
                NEXT_STATE <= TLR;
            else
                NEXT_STATE <= CIR;
            end if;
            
        when CIR =>
            if TMS = '1' then
                NEXT_STATE <= E1IR;
            else
                NEXT_STATE <= SIR_SHIFT;
            end if;
            
        when SIR_SHIFT =>
            if TMS = '1' then
                NEXT_STATE <= E1IR;
            else
                    NEXT_STATE <= SIR_SHIFT;
                end if;
                
            when E1IR =>
                if TMS = '1' then
                    NEXT_STATE <= UIR;
                else
                    NEXT_STATE <= PIR;
                end if;
                
            when PIR =>
                if TMS = '1' then
                    NEXT_STATE <= E2IR;
                else
                    NEXT_STATE <= PIR;
                end if;
            
            when E2IR =>
                if TMS = '1' then
                    NEXT_STATE <= UIR;
                else
                    NEXT_STATE <= SIR_SHIFT;
                end if;
                
            when UIR =>
                if TMS = '1' then
                    NEXT_STATE <= SDR;
                else
                    NEXT_STATE <= RTI;
                end if;
                
            when others =>
                NEXT_STATE <= TLR;
            
        
        end case ;
    end process;

    -- Counter Decrement
    process (TCK, STATE)
    begin 
        if rising_edge(TCK) then
            if STATE = SDR_SHIFT then
                if counter = 0 then
                    counter <= DATA_SIZE;
                else
                    counter <= counter - 1;
                end if;
            else
                counter <= DATA_SIZE;
            end if;
        end if;
    end process;

    -- Data Register (DR) and Instruction Register (IR) Output
    process (TCK, STATE, counter, RST)
    begin
        if RST = '1' then
            curr_local_dr_reg <= X"C0FFEE00";
        end if;
        if rising_edge(TCK) then
            case STATE is
                when SDR_SHIFT =>
                    TDO <= curr_local_dr_reg(counter);
                    next_local_dr_reg(counter) <= TDI;
                
                when UDR =>
                    null; -- Per Spec next_local_dr_reg should be updated here
                          -- This would require an extra register to store the value of next_local_dr_reg
                
                when CDR =>
                    curr_local_dr_reg <= next_local_dr_reg;

                when TLR =>
                    next_local_dr_reg <= X"C0FFEE00";
                    curr_local_dr_reg <= X"C0FFEE00";
                
                when others =>
                    null;
                
            end case;
        end if;
    end process;

    -- DEBUG PROCESS For STATE_OUT
    process (STATE)
    begin
        STATE_OUT <= to_slv(STATE);
    end process;

end Behavioral;
