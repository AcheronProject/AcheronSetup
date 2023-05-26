#!/usr/bin/env python3
import pcbnew
import numpy as np
from scipy.optimize import fsolve

target_board = pcbnew.GetBoard()
# Usage: select two tracks

def get_highlighted_tracks(board):
	tracks = []
	for track in board.GetTracks():
		if track.IsSelected():
			tracks.append(track)

	return tracks

match len(get_highlighted_tracks(target_board)):
	case 0:
		print('Error: no tracks are selected.')
		exit()
	case 1:
		print('Error: only a single track is selected.')
		exit()
	case 2: pass
	case _:
		print('Error: too many tracks are selected!')
		exit()

[track1, track2] = get_highlighted_tracks(target_board)
print('--> Track 1 start and end: {0}, {1}'.format(track1.GetStart(), track1.GetEnd()))
print('--> Track 2 start and end: {0}, {1}'.format(track2.GetStart(), track2.GetEnd()))

track1_start = track1.GetStart()
track1_end = track1.GetEnd()
track1_data = [track1_start[0], track1_start[1], track1_end[0], track1_end[1]]

track2_start = track2.GetStart()
track2_end = track2.GetEnd()
track2_data = [track2_start[0], track2_start[1], track2_end[0], track2_end[1]]

# -----------------------------------------------
# The linear algebra stuff
# -----------------------------------------------
def calc_m(line_data):
	x1 = line_data[0]
	y1 = line_data[1]
	x2 = line_data[2]
	y2 = line_data[3]
        # Equation is x = x1
	if x1==x2:
		if y1==y2:
			print('Line is a point')
			return np.nan
		else:
			return np.inf
	elif y1==y2: m = 0 
	else:   m = (y1-y2)/(x1-x2)
	return m

def linear_equation(x,y,line_data):
	x1 = line_data[0]
	y1 = line_data[1]
	x2 = line_data[2]
	y2 = line_data[3]
	if x1==x2:
		if y1==y2: return np.nan # Line is actually a point
		else: return x-x1 # Line is vertical
	elif y1==y2: return y-y1 # Line is horizontal
	else:
		m = (y1-y2)/(x1-x2)
		return m*x - y + (-m*x1 + y1)

def define_wx_intersection(x0,y0):
	print('--> Intersection: ({0}, {1})'.format(x0,y0))

	x0 = round(x0)
	y0 = round(y0)

	return pcbnew.wxPoint(x0,y0)



m1 = calc_m(track1_data)
m2 = calc_m(track2_data)
if (m1==np.inf and m2==np.inf):
	print('Both lines are vertical')
	exit()

elif m1==np.inf:
	print('Line 1 is vertical')
	x0 = track1_start[0]
	y0 = track2_start[1] + m2*(x0 - track2_start[0])
	
elif m2==np.inf:
	print('Line 2 is vertical')
	x0 = track2_start[0]
	y0 = track1_start[1] + m1*(x0 - track1_start[0])
else:
	if m1 == m2 :
		print('--> Error: selected lines are either parallel or coincident.')
		exit()


	c1 = m1*track1_data[0] - track1_data[1]
	c2 = m2*track2_data[0] - track2_data[1]

	x0 = (c2 - c1)/(m2 - m1)
	y0 = (m1*c2 - m2*c1)/(m2 - m1)

intersection = pcbnew.VECTOR2I(round(x0),round(y0))
print('--> Intersection: {}'.format(intersection))
def cartesian_distance_2(point1,point2): return (point1[0]-point2[0])**2 + (point1[1]-point2[1])**2

import inspect

# Resets end or start, depending on which is closer to intersection
if cartesian_distance_2(intersection,track1_start) < cartesian_distance_2(intersection,track1_end):
	track1.SetStart(intersection)
else:
	track1.SetEnd(intersection)

if cartesian_distance_2(intersection,track2_start) < cartesian_distance_2(intersection,track2_end):
	track2.SetStart(intersection)
else:
	track2.SetEnd(intersection)
