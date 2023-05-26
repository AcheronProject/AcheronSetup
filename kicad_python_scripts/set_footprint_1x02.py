import pcbnew

def get_selected_texts():
	selected_texts = []
	for selected_object in pcbnew.GetCurrentSelection():
	    if type(selected_object).__name__ == 'FP_TEXT':
                selected_texts.append(selected_object)
	
	return selected_texts

def get_selected_footprints():
	selected_footprints = []
	for selected_object in pcbnew.GetCurrentSelection():
	    if type(selected_object).__name__ == 'FOOTPRINT':
	        selected_footprints.append(selected_object)
	
	return selected_footprints

unit = 10**6
for text in get_selected_texts():
	text.SetTextWidth     (int(0.5*unit))
	text.SetTextHeight    (int(0.5*unit))
	text.SetTextThickness (int(0.1*unit))
