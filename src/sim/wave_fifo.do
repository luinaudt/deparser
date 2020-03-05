onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_stream/clk
add wave -noupdate /axi_stream/reset_n
add wave -noupdate /axi_stream/stream_out_ready
add wave -noupdate /axi_stream/stream_out_tlast
add wave -noupdate /axi_stream/stream_out_valid
add wave -noupdate /axi_stream/stream_out_data
add wave -noupdate /axi_stream/stream_in_valid
add wave -noupdate /axi_stream/stream_in_tlast
add wave -noupdate /axi_stream/stream_in_ready
add wave -noupdate /axi_stream/stream_in_data
add wave -noupdate /axi_stream/head
add wave -noupdate /axi_stream/head_next
add wave -noupdate /axi_stream/tail
add wave -noupdate /axi_stream/tail_next
add wave -noupdate -expand -group state /axi_stream/almost_empty
add wave -noupdate -expand -group state /axi_stream/almost_full
add wave -noupdate -expand -group state /axi_stream/full
add wave -noupdate -expand -group state /axi_stream/empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {151511 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 216
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {83424 ps} {177504 ps}
