import cairo
width_cm = 15
height_cm = 15
nb_signals = 150
convert_ratio = (1.0/72.0)*2.54
width = width_cm/convert_ratio
height = height_cm/convert_ratio
filename = "gen1"
with cairo.SVGSurface(filename + '.svg', width, height) as surface:
    context = cairo.Context(surface)
    context.scale(width, height)
    context.set_line_width(1/width)
    context.move_to(0, 1)
    context.set_font_size(0.1)
    context.show_text("Essai")
    context.stroke()
#    for i in range(nb_signals):
#        context.move_to(0, i/nb_signals)
#        context.line_to(1, i/nb_signals)
#    context.stroke()
    """x, y, x1, y1 = 0.1, 0.5, 0.4, 0.9
    x2, y2, x3, y3 = 0.6, 0.1, 0.9, 0.5
    context.scale(width, height)
    context.set_line_width(0.04)
    context.move_to(x, y)
    context.curve_to(x1, y1, x2, y2, x3, y3)
    context.stroke()
    context.set_source_rgba(1, 0.2, 0.2, 0.6)
    context.set_line_width(0.02)
    context.move_to(x, y)
    context.line_to(x1, y1)
    context.move_to(x2, y2)
    context.line_to(x3, y3)
    context.stroke()"""
