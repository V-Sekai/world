## MIT License
## 
## Copyright (c) 2023 Ronald van Wijnen
## 
## Permission is hereby granted, free of charge, to any person obtaining a
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and/or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS IN THE SOFTWARE.

extends Node

class_name Spectral

const SIZE = 32
const GAMMA = 2.4
const GAMMA_INV = 1.0 / 2.4
const EPSILON = 0.00000001

const CIE_CMF_X = [
	0.00006469, 0.00021941, 0.00112057, 0.00376661, 0.01188055,
	0.02328644, 0.03455942, 0.03722379, 0.03241838,
	0.02123321, 0.01049099, 0.00329584, 0.00050704, 0.00094867,
	0.00627372, 0.01686462, 0.02868965, 0.04267481, 0.05625475,
	0.0694704, 0.08305315, 0.0861261, 0.09046614, 0.08500387,
	0.07090667, 0.05062889, 0.03547396, 0.02146821,
	0.01251646, 0.00680458, 0.00346457, 0.00149761, 0.0007697,
	0.00040737, 0.00016901, 0.00009522, 0.00004903, 0.00002
]

const CIE_CMF_Y = [
	0.00000184, 0.00000621, 0.00003101, 0.00010475, 0.00035364,
	0.00095147, 0.00228226, 0.00420733, 0.0066888, 0.0098884,
	0.01524945, 0.02141831, 0.03342293, 0.05131001,
	0.07040208, 0.08783871, 0.09424905, 0.09795667, 0.09415219,
	0.08678102, 0.07885653, 0.0635267, 0.05374142,
	0.04264606, 0.03161735, 0.02088521, 0.01386011, 0.00810264,
	0.0046301, 0.00249138, 0.0012593, 0.00054165, 0.00027795,
	0.00014711, 0.00006103, 0.00003439, 0.00001771, 0.00000722
]

const CIE_CMF_Z = [
	0.00030502, 0.00103681, 0.00531314, 0.01795439, 0.05707758,
	0.11365162, 0.17335873, 0.19620658, 0.18608237,
	0.13995048, 0.08917453, 0.04789621, 0.02814563, 0.01613766,
	0.0077591, 0.00429615, 0.00200551, 0.00086147, 0.00036904,
	0.00019143, 0.00014956, 0.00009231, 0.00006813,
	0.00002883, 0.00001577, 0.00000394, 0.00000158,
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
]

const SPD_C = [
	0.96853629, 0.96855103, 0.96859338, 0.96877345, 0.96942204,
	0.97143709, 0.97541862, 0.98074186, 0.98580992,
	0.98971194, 0.99238027, 0.99409844, 0.995172, 0.99576545,
	0.99593552, 0.99564041, 0.99464769, 0.99229579, 0.98638762,
	0.96829712, 0.89228016, 0.53740239, 0.15360445,
	0.05705719, 0.03126539, 0.02205445, 0.01802271, 0.0161346,
	0.01520947, 0.01475977, 0.01454263, 0.01444459, 0.01439897,
	0.0143762, 0.01436343, 0.01435687, 0.0143537, 0.01435408
]

const SPD_M = [
	0.51567122, 0.5401552, 0.62645502, 0.75595012, 0.92826996,
	0.97223624, 0.98616174, 0.98955255, 0.98676237,
	0.97312575, 0.91944277, 0.32564851, 0.13820628, 0.05015143,
	0.02912336, 0.02421691, 0.02660696, 0.03407586, 0.04835936,
	0.0001172, 0.00008554, 0.85267882, 0.93188793,
	0.94810268, 0.94200977, 0.91478045, 0.87065445, 0.78827548,
	0.65738359, 0.59909403, 0.56817268, 0.54031997, 0.52110241,
	0.51041094, 0.50526577, 0.5025508, 0.50126452, 0.50083021
]

const SPD_Y = [
	0.02055257, 0.02059936, 0.02062723, 0.02073387, 0.02114202,
	0.02233154, 0.02556857, 0.03330189, 0.05185294,
	0.10087639, 0.24000413, 0.53589066, 0.79874659, 0.91186529,
	0.95399623, 0.97137099, 0.97939505, 0.98345207, 0.98553736,
	0.98648905, 0.98674535, 0.98657555, 0.98611877,
	0.98559942, 0.98507063, 0.98460039, 0.98425301, 0.98403909,
	0.98388535, 0.98376116, 0.98368246, 0.98365023, 0.98361309,
	0.98357259, 0.98353856, 0.98351247, 0.98350101, 0.98350852
]

const SPD_R = [
	0.03147571, 0.03146636, 0.03140624, 0.03119611, 0.03053888,
	0.02856855, 0.02459485, 0.0192952, 0.01423112,
	0.01033111, 0.00765876, 0.00593693, 0.00485616, 0.00426186,
	0.00409039, 0.00438375, 0.00537525, 0.00772962, 0.0136612,
	0.03181352, 0.10791525, 0.46249516, 0.84604333,
	0.94275572, 0.96860996, 0.97783966, 0.98187757, 0.98377315,
	0.98470202, 0.98515481, 0.98537114, 0.98546685, 0.98550011,
	0.98551031, 0.98550741, 0.98551323, 0.98551563, 0.98551547
]

const SPD_G = [
	0.49108579, 0.46944057, 0.4016578, 0.2449042, 0.0682688,
	0.02732883, 0.013606, 0.01000187, 0.01284127, 0.02636635,
	0.07058713, 0.70421692, 0.85473994, 0.95081565, 0.9717037,
	0.97651888, 0.97429245, 0.97012917, 0.9425863, 0.99989207,
	0.99989891, 0.13823139, 0.06968113, 0.05628787,
	0.06111561, 0.08987709, 0.13656016, 0.22169624, 0.32176956,
	0.36157329, 0.4836192, 0.46488579, 0.47440306, 0.4857699,
	0.49267971, 0.49625685, 0.49807754, 0.49889859
]

const SPD_B = [
	0.97901834, 0.97901649, 0.97901118, 0.97892146, 0.97858555,
	0.97743705, 0.97428075, 0.96663223, 0.94822893,
	0.89937713, 0.76070164, 0.4642044, 0.20123039, 0.08808402,
	0.04592894, 0.02860373, 0.02060067, 0.01656701, 0.01451549,
	0.01357964, 0.01331243, 0.01347661, 0.01387181,
	0.01435472, 0.01479836, 0.0151525, 0.01540513, 0.01557233,
	0.0156571, 0.01571025, 0.01571916, 0.01572133, 0.01572502,
	0.01571717, 0.01571905, 0.01571059, 0.01569728, 0.0157002
]

const XYZ_RGB = [
	[ 3.24306333,  -1.53837619, -0.49893282 ],
	[ -0.96896309, 1.87542451,  0.04154303 ],
	[ 0.05568392,  -0.20417438, 1.05799454 ]
]

## Clamps a number between a lower and upper bound.
func clamp(v, mn, mx):
	return min(max(v, mn), mx)


## Converts a color channel from linear sRGB to standard RGB. x is expected to be in [0.0, 1.0].
func compand(x):
	if x < 0.0031308:
		return x * 12.92
	return 1.055 * pow(x, GAMMA_INV) - 0.055

## Finds the dot product of number arrays a and b, or the sum of the product of each element in a with that in b.
func dot_product(a: Array, b: Array):
	var mnLen = min(a.size(), b.size())
	var sum = 0
	for i in range(mnLen):
		sum += a[i] * b[i]
	return sum


## Calculates the concentration from linear values l1, l2 and t.
func linear_to_concentration(l1, l2, t):
	var t1 = l1 * pow((1 - t), 2)
	var t2 = l2 * pow(t, 2)

	return t2 / (t1 + t2)

## Converts a linear RGB table to reflectance values.
func linear_to_reflectance(lrgb):
	var weights = spectral_upsampling(lrgb)
	var R = []

	for i in range(SIZE):
		R.append(max(
			EPSILON,
			weights[0]
			+ weights[1] * SPD_C[i]
			+ weights[2] * SPD_M[i]
			+ weights[3] * SPD_Y[i]
			+ weights[4] * SPD_R[i]
			+ weights[5] * SPD_G[i]
			+ weights[6] * SPD_B[i])
		)

	return R


# Mixes an origin sRGB table to a destination according to a factor.
# Expects tables to be in the range [0, 255].
func mix(srgb1: Color, srgb2: Color, t: float) -> Color:
	var lrgb1: Color = srgb1.srgb_to_linear()
	var lrgb2: Color = srgb2.srgb_to_linear()

	var R1: Array = linear_to_reflectance(lrgb1)
	var R2: Array = linear_to_reflectance(lrgb2)

	var l1: float = dot_product(R1, CIE_CMF_Y)
	var l2: float = dot_product(R2, CIE_CMF_Y)

	var t2: float = linear_to_concentration(l1, l2, t)

	var R: Array = []
	for i in range(SIZE):
		var KS: float = (1 - t2) * pow((1 - R1[i]), 2) / (2 * R1[i]) + t2 * pow((1 - R2[i]), 2) / (2 * R2[i])
		var KM: float = 1 + KS - sqrt(KS * KS + 2 * KS)
		R.append(KM)

	return xyz_to_srgb(reflectance_to_xyz(R))

# Creates a ramp of mixed colors from the origin to the destination with the given number of steps.
# Includes the origin and destination colors at indices 0 and size-1.
func palette(srgb1: Color, srgb2: Color, size: int) -> Array:
	var g = []  # Initialize an empty array to hold the gradient colors.
	var toFac = 0.0  # Initialize the factor to use for interpolation.
	
	if size > 1:
		toFac = 1.0 / (size - 1)  # If there are more than one steps, calculate the interpolation factor.
		
	for i in range(size):
		g.append(mix(srgb1, srgb2, i * toFac))
		
	return g

## Converts reflectance to xyz.
func reflectance_to_xyz(R):
	var x = dot_product(R, CIE_CMF_X)
	var y = dot_product(R, CIE_CMF_Y)
	var z = dot_product(R, CIE_CMF_Z)

	return [x, y, z]

## Performs spectral upsampling on lrgb table.
func spectral_upsampling(lrgb):
	var w = min(min(lrgb[0], lrgb[1]), lrgb[2])
	var lrgbnw = [lrgb[0] - w, lrgb[1] - w, lrgb[2] - w]

	var c = min(lrgbnw[1], lrgbnw[2])
	var m = min(lrgbnw[0], lrgbnw[2])
	var y = min(lrgbnw[0], lrgbnw[1])
	var r = max(0, min(lrgbnw[0] - lrgbnw[1], lrgbnw[0] - lrgbnw[2]))
	var g = max(0, min(lrgbnw[1] - lrgbnw[0], lrgbnw[1] - lrgbnw[2]))
	var b = max(0, min(lrgbnw[2] - lrgbnw[0], lrgbnw[2] - lrgbnw[1]))

	return [w, c, m, y, r, g, b]

## Converts a color channel from standard RGB to linear sRGB. x is expected to be in [0.0, 1.0].
func uncompand(x):
	if x < 0.04045:
		return x / 12.92
	return pow((x + 0.055) / 1.055, GAMMA)

## Converts xyz to sRGB.
func xyz_to_srgb(xyz: Array):
	var r = dot_product(XYZ_RGB[0], xyz)
	var g = dot_product(XYZ_RGB[1], xyz)
	var b = dot_product(XYZ_RGB[2], xyz)

	return Color(r, g, b).linear_to_srgb()


var orig_color: Color 
var dest_color: Color
var swatch_count = 7

var hbox = HBoxContainer.new() 
var textureRect = TextureRect.new() 
	
func _ready():
	var dialog = Panel.new()
	dialog.custom_minimum_size = Vector2i(2000, 500)
	add_child(dialog)

	dialog.add_child(hbox)

	var origColorPicker = ColorPicker.new()
	origColorPicker.color = Color(1, 1, 1)
	origColorPicker.connect("color_changed", _on_orig_color_changed)
	origColorPicker.presets_visible = false
	origColorPicker.sampler_visible = false
	origColorPicker.sliders_visible = false
	origColorPicker.edit_alpha = false
	hbox.add_child(origColorPicker) 

	var destColorPicker = ColorPicker.new()
	destColorPicker.color = Color(0, 0, 0)
	destColorPicker.connect("color_changed", _on_dest_color_changed)
	destColorPicker.presets_visible = false
	destColorPicker.sampler_visible = false
	destColorPicker.sliders_visible = false
	origColorPicker.edit_alpha = false
	hbox.add_child(destColorPicker) 

	var slider = HSlider.new()
	slider.min_value = 3
	slider.max_value = 32
	slider.value = swatch_count
	slider.connect("value_changed", _on_swatch_count_changed)
	slider.custom_minimum_size = Vector2(200, 200)
	hbox.add_child(slider)

	hbox.add_child(textureRect) 

func _on_orig_color_changed(color: Color):
	orig_color = color
	update_gradient()

func _on_dest_color_changed(color: Color):
	dest_color = color
	update_gradient()

func _on_swatch_count_changed(value: float):
	swatch_count = value
	update_gradient()

func update_gradient():
	var orig_srgb: Color = Color(orig_color.r, orig_color.g, orig_color.b)
	var dest_srgb: Color = Color(dest_color.r, dest_color.g, dest_color.b)
	print_verbose("Orig Color: ", orig_color)
	print_verbose("Dest Color: ", dest_color)
	print_verbose("Swatch Count: ", swatch_count)
	var step = 1.0 / (swatch_count - 1)

	# Count the number of ColorRects before the update.
	var color_rect_count_before = 0
	for child in hbox.get_children():
		if child is ColorRect:
			color_rect_count_before += 1
	print_verbose("ColorRect count before: ", color_rect_count_before)
	var color_rects_to_remove = []
	for i in range(hbox.get_child_count()):
		var child = hbox.get_child(i)
		if child is ColorRect:
			color_rects_to_remove.append(child)

	for color_rect in color_rects_to_remove:
		hbox.remove_child(color_rect)
		color_rect.queue_free()
		
	for i in range(swatch_count):
		var fac = i * step
		print_verbose("Interpolation Factor: ", fac)
		var trg_srgb: Color = mix(orig_srgb, dest_srgb, fac)
		print_verbose("Mixed Color: ", trg_srgb)

		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2i(20, 20)
		hbox.add_child(color_rect)

		# Set the color of the ColorRect.
		color_rect.color = trg_srgb
		print_verbose("ColorRect Color: ", color_rect.color)

	# Count the number of ColorRects after the update.
	var color_rect_count_after = 0
	for child in hbox.get_children():
		if child is ColorRect:
			color_rect_count_after += 1
	print_verbose("ColorRect count after: ", color_rect_count_after)
	print_verbose("ColorRect count after: ", color_rect_count_after)
