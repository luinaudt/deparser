onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_stream/clk
add wave -noupdate /axi_stream/reset_n
add wave -noupdate /axi_stream/stream_out_ready
add wave -noupdate /axi_stream/stream_out_tlast
add wave -noupdate /axi_stream/stream_out_valid
add wave -noupdate -radix unsigned /axi_stream/stream_out_data
add wave -noupdate /axi_stream/stream_in_valid
add wave -noupdate /axi_stream/stream_in_tlast
add wave -noupdate /axi_stream/stream_in_ready
add wave -noupdate -radix unsigned /axi_stream/stream_in_data
add wave -noupdate -expand -group pointer /axi_stream/head
add wave -noupdate -expand -group pointer /axi_stream/head_next
add wave -noupdate -expand -group pointer /axi_stream/tail
add wave -noupdate -expand -group pointer /axi_stream/tail_next
add wave -noupdate -expand -group state /axi_stream/ready_i
add wave -noupdate -expand -group state /axi_stream/valid_i
add wave -noupdate -expand -group state /axi_stream/almost_empty
add wave -noupdate -expand -group state /axi_stream/almost_full
add wave -noupdate -expand -group state /axi_stream/full
add wave -noupdate -expand -group state /axi_stream/prev_empty
add wave -noupdate -expand -group state /axi_stream/empty
add wave -noupdate -expand -group read/write /axi_stream/read_tail
add wave -noupdate -expand -group read/write /axi_stream/read_tail_next
add wave -noupdate -expand -group read/write /axi_stream/write_head
add wave -noupdate -expand -group mem -radix unsigned /axi_stream/data_out
add wave -noupdate -expand -group mem -radix unsigned /axi_stream/data_out_next
add wave -noupdate -expand -group mem -radix unsigned /axi_stream/data_in
add wave -noupdate /axi_stream/empty
add wave -noupdate -expand -group read /axi_stream/valid_i
add wave -noupdate -expand -group read /axi_stream/tail
add wave -noupdate -expand -group read /axi_stream/tail_next
add wave -noupdate -expand -group read /axi_stream/prev2_empty
add wave -noupdate -expand -group read /axi_stream/almost_empty
add wave -noupdate -expand -group read /axi_stream/prev_empty
add wave -noupdate -expand -group read /axi_stream/axi_read_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14345 ps} 0} {{Cursor 2} {20745 ps} 0}
WaveRestoreCursorLinks {1 {2 {6400 ps}}} {2 {1 {-6400 ps}}}
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
WaveRestoreZoom {0 ps} {302401 ps}
