
${name} : entity work.${componentName}
  generic map (nbHeader    => ${nbHeader},
               outputWidth => ${wControl})
  port map (
    clk         => ${clk},
    reset_n     => ${reset_n},
    start_dep   => ${start},
    ready       => ${ready},
    finish      => ${finish},
    headerValid => ${headersValid},
    output      => ${output});
