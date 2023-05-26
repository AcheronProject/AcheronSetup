#!/usr/bin/env python3
import pcbnew
import numpy as np
from scipy.optimize import fsolve

target_board = pcbnew.GetBoard()
design_settings = target_board.GetDesignSettings()
# Usage: select two tracks

def get_highlighted_drawings(board):
	drawings = []
	for drawing in board.GetDrawings():
		if drawing.IsSelected():
			drawings.append(drawing)

	return drawings

match len(get_highlighted_drawings(target_board)):
	case 0:
		print('Error: no drawings are selected.')
		exit()
	case 1:
		print('Error: only a single drawing is selected.')
		exit()
	case 2: pass
	case _:
		print('Error: too many drawings are selected!')
		exit()

[lambda1, lambda2] = get_highlighted_drawings(target_board)
[[x1,y1],[x2,y2]] = [i.GetStart() for i in [lambda1, lambda2]]
r1, r2 = [i.GetRadius() for i in [lambda1, lambda2]]
d = np.sqrt( (x1-x2)**2 + (y1-y2)**2)

if ( d > r1 + r2 ):
	print('System is impossible: drawings do not cross  because circles are external to one another!')
	exit()
elif ( d < np.abs(r1 - r2) ):
	print('System is impossible: drawings do not cross; circles are internal to one another!')
	exit()

def circ_system(z):
    x = z[0]
    y = z[1]
    f1 = (x-x1)**2 + (y-y1)**2 - r1**2
    f2 = (x-x2)**2 + (y-y2)**2 - r2**2
    return f1,f2

sol1 = fsolve(circ_system, (x1-1,y1+1))
sol2 = fsolve(circ_system, (x2+1,y2-1))

inter_point1 =  pcbnew.wxPoint(sol1[0],sol1[1])
inter_point2 =  pcbnew.wxPoint(sol2[0],sol2[1])
dist_inter = np.sqrt((inter_point1[0] - inter_point2[0])**2 + (inter_point1[1] - inter_point2[1])**2)
center1 = pcbnew.wxPoint(x1,y1)
center2 =  pcbnew.wxPoint(x2,y2)

print(inter_point1, inter_point2)

angle1 = 2*np.arcsin(np.sqrt(dist_inter/(2*r1)))
angle1 = 2*np.arcsin(np.sqrt(dist_inter/(2*r2)))

arc1 = pcbnew.PCB_SHAPE(target_board)
arc1.SetShape(pcbnew.S_ARC)
arc1.SetCenter(center1)
arc1.SetArcGeometry(inter_point1,center1,inter_point2)
arc1.SetLayer(pcbnew.F_SilkS)
target_board.AddNative(arc1)


#print('{},{}'.format(sol1[0],sol1[1]))
#print('{},{}'.format(sol2[0],sol2[1]))


#[track1, track2] = get_highlighted_tracks(target_board)
#print('--> Track 1 start and end: {0}, {1}'.format(track1.GetStart(), track1.GetEnd()))
#print('--> Track 2 start and end: {0}, {1}'.format(track2.GetStart(), track2.GetEnd()))
#
#track1_start = track1.GetStart()
#track1_end = track1.GetEnd()
#track1_data = [track1_start[0], track1_start[1], track1_end[0], track1_end[1]]
#
#track2_start = track2.GetStart()
#track2_end = track2.GetEnd()
#track2_data = [track2_start[0], track2_start[1], track2_end[0], track2_end[1]]
#
## -----------------------------------------------
## The linear algebra stuff
## -----------------------------------------------
#def calc_m(line_data):
#	x1 = line_data[0]
#	y1 = line_data[1]
#	x2 = line_data[2]
#	y2 = line_data[3]
#        # Equation is x = x1
#	if x1==x2:
#		if y1==y2:
#			print('Line is a point')
#			return np.nan
#		else:
#			return np.inf
#	elif y1==y2: m = 0 
#	else:   m = (y1-y2)/(x1-x2)
#	return m
#
#def linear_equation(x,y,line_data):
#	x1 = line_data[0]
#	y1 = line_data[1]
#	x2 = line_data[2]
#	y2 = line_data[3]
#	if x1==x2:
#		if y1==y2: return np.nan # Line is actually a point
#		else: return x-x1 # Line is vertical
#	elif y1==y2: return y-y1 # Line is horizontal
#	else:
#		m = (y1-y2)/(x1-x2)
#		return m*x - y + (-m*x1 + y1)
#
#def define_wx_intersection(x0,y0):
#	print('--> Intersection: ({0}, {1})'.format(x0,y0))
#
#	x0 = round(x0)
#	y0 = round(y0)
#
#	return pcbnew.wxPoint(x0,y0)
#
#
#
#m1 = calc_m(track1_data)
#m2 = calc_m(track2_data)
#if (m1==np.inf and m2==np.inf):
#	print('Both lines are vertical')
#	exit()
#
#elif m1==np.inf:
#	print('Line 1 is vertical')
#	x0 = track1_start[0]
#	y0 = track2_start[1] + m2*(x0 - track2_start[0])
#	
#elif m2==np.inf:
#	print('Line 2 is vertical')
#	x0 = track2_start[0]
#	y0 = track1_start[1] + m1*(x0 - track1_start[0])
#else:
#	if m1 == m2 :
#		print('--> Error: selected lines are either parallel or coincident.')
#		exit()
#
#
#	c1 = m1*track1_data[0] - track1_data[1]
#	c2 = m2*track2_data[0] - track2_data[1]
#
#	x0 = (c2 - c1)/(m2 - m1)
#	y0 = (m1*c2 - m2*c1)/(m2 - m1)
#
#intersection = pcbnew.wxPoint(x0,y0)
#
#def cartesian_distance_2(point1,point2): return (point1[0]-point2[0])**2 + (point1[1]-point2[1])**2
#
## Resets end or start, depending on which is closer to intersection
#if cartesian_distance_2(intersection,track1_start) < cartesian_distance_2(intersection,track1_end): track1.SetStart(intersection)
#else: track1.SetEnd(intersection)
#
#if cartesian_distance_2(intersection,track2_start) < cartesian_distance_2(intersection,track2_end): track2.SetStart(intersection)
#else: track2.SetEnd(intersection)












#import numpy as np
#from scipy.optimize import fsolve
#
#x1 = 103.3205
#y1 = 122.468125
#r1 = 2 
#x2 = 100.74875
#y2 = 124.373125
#r2 = 1.8 
#
#def circ_system(z):
#    x = z[0]
#    y = z[1]
#    f1 = (x-x1)**2 + (y-y1)**2 - r1**2
#    f2 = (x-x2)**2 + (y-y2)**2 - r2**2
#    return f1,f2
#
#sol1 = fsolve(circ_system, (x1-1,y1+1))
#sol2 = fsolve(circ_system, (x2+1,y2-1))
#print('{},{}'.format(sol1[0],sol1[1]))
#print('{},{}'.format(sol2[0],sol2[1]))
