library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cordic is
	generic(
        -- Describes the amount of bits per vector element.
        N_BITS_VECTOR : integer:= 32;
        -- Describes the amount of bits to represent the angle.
        N_BITS_ANGLE : integer := 18;
        N_ITER       : integer := 15);
    port(
        clk  : in std_logic;
        x1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        y1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
        beta : in signed(N_BITS_ANGLE-1 downto 0);
        start: in std_logic;
        x2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        y2   : out std_logic_vector(N_BITS_VECTOR downto 0);
        z2   : out std_logic_vector(N_BITS_ANGLE-1 downto 0);
        done : out std_logic);

end;

architecture cordic_arch of cordic is

    component cordic_processor is
        generic(
            -- Describes the amount of bits per vector element.
            N_BITS_VECTOR : integer:= 32;
            -- Describes the amount of bits to represent the angle.
            N_BITS_ANGLE : integer := 17;
            N_ITER       : integer := 10);
        port(
            clk  : in std_logic;
            x1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
            y1   : in std_logic_vector(N_BITS_VECTOR-1 downto 0);
            beta : in signed(N_BITS_ANGLE-1 downto 0);
            start: in std_logic;
            mode : in std_logic;
            x2   : out std_logic_vector(N_BITS_VECTOR downto 0);
            y2   : out std_logic_vector(N_BITS_VECTOR downto 0);
            z2   : out std_logic_vector(N_BITS_ANGLE-1 downto 0);
            done : out std_logic);
    end component;

    function A2_COMPLEMENT(X : std_logic_vector(N_BITS_VECTOR-1 downto 0))
    return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(not X) + to_unsigned(1, X'length), X'length));
    end A2_COMPLEMENT;

    function A2_COMPLEMENT2(X : std_logic_vector(N_BITS_VECTOR downto 0))
    return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(not X) + to_unsigned(1, X'length), X'length));
    end A2_COMPLEMENT2;

    signal beta_adjusted : signed(N_BITS_ANGLE-1 downto 0);
    signal x1_adjusted   : std_logic_vector(N_BITS_VECTOR-1 downto 0);
    signal y1_adjusted   : std_logic_vector(N_BITS_VECTOR-1 downto 0);

    signal x2_aux   : std_logic_vector(N_BITS_VECTOR downto 0);
    signal y2_aux   : std_logic_vector(N_BITS_VECTOR downto 0);

begin

    process(beta)
    begin
        -- 2**(N_BITS_ANGLE-1) --> 180
        -- 2**(N_BITS_ANGLE-2) --> 90
        -- 2**(N_BITS_ANGLE-3) --> 45
        if (beta > to_signed(2**(N_BITS_ANGLE-2), N_BITS_ANGLE) and
           (beta < to_signed(2**(N_BITS_ANGLE-1), N_BITS_ANGLE))) then
            beta_adjusted <= beta - to_signed(2**(N_BITS_ANGLE-1), N_BITS_ANGLE);
            x1_adjusted   <= A2_COMPLEMENT(x1);
            y1_adjusted   <= A2_COMPLEMENT(y1);
        elsif (unsigned(beta) > to_unsigned(2**(N_BITS_ANGLE-1), N_BITS_ANGLE) and
              (unsigned(beta) < to_unsigned(2**(N_BITS_ANGLE-1) + 2**(N_BITS_ANGLE-2), N_BITS_ANGLE))) then
            beta_adjusted <= beta + to_signed(2**(N_BITS_ANGLE-1), N_BITS_ANGLE);
            x1_adjusted   <= A2_COMPLEMENT(x1);
            y1_adjusted   <= A2_COMPLEMENT(y1);
        else
            beta_adjusted <= beta;
            x1_adjusted   <= x1;
            y1_adjusted   <= y1;
        end if;
    end process;

    processor : cordic_processor
    generic map(N_BITS_VECTOR, N_BITS_ANGLE, N_ITER)
    port map(
        clk => clk,
        x1 => x1_adjusted,
        y1 => y1_adjusted,
        beta => beta_adjusted,
        mode => '0', -- Rotation mode only
        start => start,
        x2   => x2_aux,
        y2   => y2_aux,
        z2   => z2,
        done => done);


    process(done)
    begin
        --if x1(x1'length-1) = '1' and y1(y1'length-1) = '0' then
        if signed(x1) < signed(y1) then
            x2 <= std_logic_vector(A2_COMPLEMENT2(y2_aux));
            y2 <= std_logic_vector(A2_COMPLEMENT2(x2_aux));
        else
            x2 <= x2_aux;
            y2 <= y2_aux;
        --elsif x1(x1'length-1) = '0' and y1(y1'length-1) = '1' then
        --elsif x1(x1'length-1) = '1' and y1(y1'length-1) = '0' then
        --else
        end if;
    end process;
end;
