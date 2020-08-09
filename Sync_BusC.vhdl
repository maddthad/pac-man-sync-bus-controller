----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Thad Seeberger
-- 
-- Create Date: 8-9-2020
-- Design Name: pac man, ms pac, other midway game boards sync bus controller
-- Module Name: Sync_BusC
-- Project Name: 
-- Target Devices: cpld
-- Tool Versions: 
-- Description: implements the sync bus controller in a cpld/dip adapter Tested working in atmel cpld
-- 
-- Dependencies: 

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sync_busC is
    Port ( M6 : in STD_LOGIC;
           H1 : in STD_LOGIC;
           H2 : in STD_LOGIC;
           BD : inout STD_LOGIC_VECTOR (7 downto 0);
           CK : out STD_LOGIC;
           RW : out STD_LOGIC;
           IORNOT : in STD_LOGIC;
           RDNOT : in STD_LOGIC;
           WRSQNOT : out STD_LOGIC;
           D : inout STD_LOGIC_VECTOR (7 downto 0);
           M1 : in STD_LOGIC;
           CSNOT : in STD_LOGIC);
	attribute pinnum         : string;
	attribute pinnum of M6 : signal is "2";
	attribute pinnum of H1  : signal is "3";
	attribute pinnum of H2 : signal is "5";
	attribute pinnum of BD : signal is "13,11,10,6,8,12,15,14";
	attribute pinnum of CK : signal is "18";
	attribute pinnum of RW : signal is "19";
	attribute pinnum of IORNOT : signal is "20";
	attribute pinnum of RDNOT : signal is "21";
	attribute pinnum of WRSQNOT : signal is "22";
	attribute pinnum of D : signal is "27,30,31,34,33,28,23,25";
	attribute pinnum of M1 : signal is "35";
	attribute pinnum of CSNOT : signal is "42";
end sync_busC;

architecture Behavioral of sync_busC is
signal U2CLK : STD_LOGIC;
signal U2AD : STD_LOGIC;
signal U2AQ : STD_LOGIC;
signal U2BD : STD_LOGIC;
signal U2BQ : STD_LOGIC;
signal U4ACLK : STD_LOGIC;
signal U4AQ : STD_LOGIC;
signal U4BQ : STD_LOGIC;
signal U4AQNOT : STD_LOGIC;
signal U4BQNOT : STD_LOGIC;
signal U4BCLK : STD_LOGIC;
signal RPNOT : STD_LOGIC;
signal WPNOT : STD_LOGIC;
--signal CK :STD_LOGIC;
signal A : STD_LOGIC_VECTOR (1 downto 0);
signal X : STD_LOGIC_VECTOR (3 downto 0);
signal B : STD_LOGIC_VECTOR (1 downto 0);
signal Y : STD_LOGIC_VECTOR (3 downto 0);
signal U6Q : STD_LOGIC_VECTOR ( 7 downto 0);
signal U7Q : STD_LOGIC_VECTOR ( 7 downto 0);
signal SEL : std_logic_vector(1 downto 0);
begin


A(0) <= H2;
A(1) <= RDNOT;
B(0) <= '0';
B(1) <= M1;
RW <= U2BQ;
RPNOT <= NOT (H1 OR U4AQNOT);
WPNOT <= NOT (U4AQNOT OR U4BQNOT);
CK <= NOT  (  (NOT( U2AQ OR RPNOT)) or ( NOT (U2BQ OR WPNOT) )  );
U2CLK <= NOT( H1 OR ( NOT ('0' OR M6) ) );
U4ACLK <= NOT ( NOT (M6 OR '0'));
U4BCLK <= NOT ( M6 OR '0');
U2AD <= X(0);
WRSQNOT <= X(1);
U2BD <= X(2);
U4AQNOT <= NOT U4AQ;
U4BQNOT <= NOT U4BQ;
SEL<= X(1) & Y(0);
--U2
U2AQ <= U2AD when ( rising_edge(U2CLK) ) else U2AQ;
U2BQ <= U2BD when ( rising_edge(U2CLK) ) else U2BQ;
--U4
U4AQ <=  H1  when ( rising_edge(U4ACLK) ) else U4AQ;
U4BQ <=  H1  when ( rising_edge(U4BCLK) ) else U4BQ;
--U5
BD <= D when U2BQ='0' else "ZZZZZZZZ";
--registers U6, U7
--U7Q <= D When ( rising_edge(Y(2)) )  else U7Q;
process( X(1), Y(0),Y(2) )
	begin
		if rising_edge( Y(2) ) then
			if( X(1) = '0' ) then
				U7Q <= U6Q;
			else
				U7Q <=D;
			end if;
		end if;
end process;

U6Q <= BD When ( rising_edge(H2) ); -- else U6Q;

process ( Y(0), X(1) )
	begin
		if Y(0) = '0' then
			D<= U7Q;
	 	else if X(1) = '0' then
			D<= U6Q;
	 	else
			D<="ZZZZZZZZ";
		end if;
	end if;
end process;

process( A, CSNOT)
begin
  X<="1111";
  if (CSNOT = '0') then
    case A is
        when "00" => X(0) <= '0';	--U2AD
        when "01" => X(1) <= '0'; --WRSQNOT
        when "10" => X(2) <= '0'; --U2BD
        when "11" => X(3) <= '0';
        when others => X <= "1111";
     end case;
	 else
	    X<="1111";
   end if;
end process; 

process( B, IORNOT)
begin
  Y<="1111";
  if (IORNOT = '0') then
    case B is
        when "00" => Y <= "1110"; --U7 enable
        when "01" => Y <= "1101";
        when "10" => Y <= "1011"; --U7 clk
        when "11" => Y <= "0111";
	   when others => Y <= "1111";
     end case;
   else
	Y<="1111";
   end if;
end process;           
end Behavioral;
