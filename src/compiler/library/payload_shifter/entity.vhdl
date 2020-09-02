${name} : entity work.payload_shifter
  generic map (nbInput       => $nbInput,
               dataWidth     => $width,
               keepWidth     => $keepWidth,
               nbBitsControl => $wControl)
  port map (
    clk     => ${clk},
    ctrl    => ${control},
    data    => ${inData},
    keep    => ${inKeep},
    selKeep => ${selKeep},
    selData => ${selData}
    );
