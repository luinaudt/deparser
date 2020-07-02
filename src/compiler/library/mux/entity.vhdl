
${name} : entity work.mux
  generic map (nbInput => $nbInput,
               width => $width,
               nbBitsControl => $wControl)
  port map (
    clk     => ${clk},
    control => ${control},
    input   => ${input},
    output  => ${output});
