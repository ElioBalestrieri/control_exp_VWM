function DrawFixationMarker(window, x, y, marker_color, background_color)

	Screen('FillOval', window, marker_color, [x-4, y-4, x+4, y+4]);
	Screen('FillOval', window, background_color, [x-2, y-2, x+2, y+2]);

