@uid("uid://ca5ywjfcs4l86") # Generated automatically, do not modify.
extends Resource

const dollar = preload("res://q_dollar/core/q_dollar.gd")

@export
var predefined_point_cloud: Dictionary = {}

func _init():
	predefined_point_cloud = {
		"T":
		[
			dollar.RecognizerPoint.new(30, 7, str(1)),
			dollar.RecognizerPoint.new(103, 7, str(1)),
			dollar.RecognizerPoint.new(66, 7, str(2)),
			dollar.RecognizerPoint.new(66, 87, str(2))
		],
		"N":
		[
			dollar.RecognizerPoint.new(177, 92, str(1)),
			dollar.RecognizerPoint.new(177, 2, str(1)),
			dollar.RecognizerPoint.new(182, 1, str(2)),
			dollar.RecognizerPoint.new(246, 95, str(2)),
			dollar.RecognizerPoint.new(247, 87, str(3)),
			dollar.RecognizerPoint.new(247, 1, str(3))
		],
		"D":
		[
			dollar.RecognizerPoint.new(345, 9, str(1)),
			dollar.RecognizerPoint.new(345, 87, str(1)),
			dollar.RecognizerPoint.new(351, 8, str(2)),
			dollar.RecognizerPoint.new(363, 8, str(2)),
			dollar.RecognizerPoint.new(372, 9, str(2)),
			dollar.RecognizerPoint.new(380, 11, str(2)),
			dollar.RecognizerPoint.new(386, 14, str(2)),
			dollar.RecognizerPoint.new(391, 17, str(2)),
			dollar.RecognizerPoint.new(394, 22, str(2)),
			dollar.RecognizerPoint.new(397, 28, str(2)),
			dollar.RecognizerPoint.new(399, 34, str(2)),
			dollar.RecognizerPoint.new(400, 42, str(2)),
			dollar.RecognizerPoint.new(400, 50, str(2)),
			dollar.RecognizerPoint.new(400, 56, str(2)),
			dollar.RecognizerPoint.new(399, 61, str(2)),
			dollar.RecognizerPoint.new(397, 66, str(2)),
			dollar.RecognizerPoint.new(394, 70, str(2)),
			dollar.RecognizerPoint.new(391, 74, str(2)),
			dollar.RecognizerPoint.new(386, 78, str(2)),
			dollar.RecognizerPoint.new(382, 81, str(2)),
			dollar.RecognizerPoint.new(377, 83, str(2)),
			dollar.RecognizerPoint.new(372, 85, str(2)),
			dollar.RecognizerPoint.new(367, 86, str(2)),
			dollar.RecognizerPoint.new(360, 87, str(2)),
			dollar.RecognizerPoint.new(355, 87, str(2)),
			dollar.RecognizerPoint.new(349, 86, str(2))
		],
		"P":
		[
			dollar.RecognizerPoint.new(507, 8, str(1)),
			dollar.RecognizerPoint.new(507, 87, str(1)),
			dollar.RecognizerPoint.new(513, 7, str(2)),
			dollar.RecognizerPoint.new(528, 7, str(2)),
			dollar.RecognizerPoint.new(537, 8, str(2)),
			dollar.RecognizerPoint.new(544, 10, str(2)),
			dollar.RecognizerPoint.new(550, 12, str(2)),
			dollar.RecognizerPoint.new(555, 15, str(2)),
			dollar.RecognizerPoint.new(558, 18, str(2)),
			dollar.RecognizerPoint.new(560, 22, str(2)),
			dollar.RecognizerPoint.new(561, 27, str(2)),
			dollar.RecognizerPoint.new(562, 33, str(2)),
			dollar.RecognizerPoint.new(561, 37, str(2)),
			dollar.RecognizerPoint.new(559, 42, str(2)),
			dollar.RecognizerPoint.new(556, 45, str(2)),
			dollar.RecognizerPoint.new(550, 48, str(2)),
			dollar.RecognizerPoint.new(544, 51, str(2)),
			dollar.RecognizerPoint.new(538, 53, str(2)),
			dollar.RecognizerPoint.new(532, 54, str(2)),
			dollar.RecognizerPoint.new(525, 55, str(2)),
			dollar.RecognizerPoint.new(519, 55, str(2)),
			dollar.RecognizerPoint.new(513, 55, str(2)),
			dollar.RecognizerPoint.new(510, 55, str(2))
		],
		"X":
		[
			dollar.RecognizerPoint.new(30, 146, str(1)),
			dollar.RecognizerPoint.new(106, 222, str(1)),
			dollar.RecognizerPoint.new(30, 225, str(2)),
			dollar.RecognizerPoint.new(106, 146, str(2))
		],
		"H":
		[
			dollar.RecognizerPoint.new(188, 137, str(1)),
			dollar.RecognizerPoint.new(188, 225, str(1)),
			dollar.RecognizerPoint.new(188, 180, str(2)),
			dollar.RecognizerPoint.new(241, 180, str(2)),
			dollar.RecognizerPoint.new(241, 137, str(3)),
			dollar.RecognizerPoint.new(241, 225, str(3))
		],
		"I":
		[
			dollar.RecognizerPoint.new(371, 149, str(1)),
			dollar.RecognizerPoint.new(371, 221, str(1)),
			dollar.RecognizerPoint.new(341, 149, str(2)),
			dollar.RecognizerPoint.new(401, 149, str(2)),
			dollar.RecognizerPoint.new(341, 221, str(3)),
			dollar.RecognizerPoint.new(401, 221, str(3))
		],
		"exclamation":
		[
			dollar.RecognizerPoint.new(526, 142, str(1)),
			dollar.RecognizerPoint.new(526, 204, str(1)),
			dollar.RecognizerPoint.new(526, 221, str(2))
		],
		"line": [dollar.RecognizerPoint.new(12, 347, str(1)), dollar.RecognizerPoint.new(119, 347, str(1))],
		"five-point star":
		[
			dollar.RecognizerPoint.new(177, 396, str(1)),
			dollar.RecognizerPoint.new(223, 299, str(1)),
			dollar.RecognizerPoint.new(262, 396, str(1)),
			dollar.RecognizerPoint.new(168, 332, str(1)),
			dollar.RecognizerPoint.new(278, 332, str(1)),
			dollar.RecognizerPoint.new(184, 397, str(1))
		],
		"null":
		[
			dollar.RecognizerPoint.new(382, 310, str(1)),
			dollar.RecognizerPoint.new(377, 308, str(1)),
			dollar.RecognizerPoint.new(373, 307, str(1)),
			dollar.RecognizerPoint.new(366, 307, str(1)),
			dollar.RecognizerPoint.new(360, 310, str(1)),
			dollar.RecognizerPoint.new(356, 313, str(1)),
			dollar.RecognizerPoint.new(353, 316, str(1)),
			dollar.RecognizerPoint.new(349, 321, str(1)),
			dollar.RecognizerPoint.new(347, 326, str(1)),
			dollar.RecognizerPoint.new(344, 331, str(1)),
			dollar.RecognizerPoint.new(342, 337, str(1)),
			dollar.RecognizerPoint.new(341, 343, str(1)),
			dollar.RecognizerPoint.new(341, 350, str(1)),
			dollar.RecognizerPoint.new(341, 358, str(1)),
			dollar.RecognizerPoint.new(342, 362, str(1)),
			dollar.RecognizerPoint.new(344, 366, str(1)),
			dollar.RecognizerPoint.new(347, 370, str(1)),
			dollar.RecognizerPoint.new(351, 374, str(1)),
			dollar.RecognizerPoint.new(356, 379, str(1)),
			dollar.RecognizerPoint.new(361, 382, str(1)),
			dollar.RecognizerPoint.new(368, 385, str(1)),
			dollar.RecognizerPoint.new(374, 387, str(1)),
			dollar.RecognizerPoint.new(381, 387, str(1)),
			dollar.RecognizerPoint.new(390, 387, str(1)),
			dollar.RecognizerPoint.new(397, 385, str(1)),
			dollar.RecognizerPoint.new(404, 382, str(1)),
			dollar.RecognizerPoint.new(408, 378, str(1)),
			dollar.RecognizerPoint.new(412, 373, str(1)),
			dollar.RecognizerPoint.new(416, 367, str(1)),
			dollar.RecognizerPoint.new(418, 361, str(1)),
			dollar.RecognizerPoint.new(419, 353, str(1)),
			dollar.RecognizerPoint.new(418, 346, str(1)),
			dollar.RecognizerPoint.new(417, 341, str(1)),
			dollar.RecognizerPoint.new(416, 336, str(1)),
			dollar.RecognizerPoint.new(413, 331, str(1)),
			dollar.RecognizerPoint.new(410, 326, str(1)),
			dollar.RecognizerPoint.new(404, 320, str(1)),
			dollar.RecognizerPoint.new(400, 317, str(1)),
			dollar.RecognizerPoint.new(393, 313, str(1)),
			dollar.RecognizerPoint.new(392, 312, str(1)),
			dollar.RecognizerPoint.new(418, 309, str(2)),
			dollar.RecognizerPoint.new(337, 390, str(2))
		],
		"arrowhead":
		[
			dollar.RecognizerPoint.new(506, 349, str(1)),
			dollar.RecognizerPoint.new(574, 349, str(1)),
			dollar.RecognizerPoint.new(525, 306, str(2)),
			dollar.RecognizerPoint.new(584, 349, str(2)),
			dollar.RecognizerPoint.new(525, 388, str(2))
		],
		"pitchfork":
		[
			dollar.RecognizerPoint.new(38, 470, str(1)),
			dollar.RecognizerPoint.new(36, 476, str(1)),
			dollar.RecognizerPoint.new(36, 482, str(1)),
			dollar.RecognizerPoint.new(37, 489, str(1)),
			dollar.RecognizerPoint.new(39, 496, str(1)),
			dollar.RecognizerPoint.new(42, 500, str(1)),
			dollar.RecognizerPoint.new(46, 503, str(1)),
			dollar.RecognizerPoint.new(50, 507, str(1)),
			dollar.RecognizerPoint.new(56, 509, str(1)),
			dollar.RecognizerPoint.new(63, 509, str(1)),
			dollar.RecognizerPoint.new(70, 508, str(1)),
			dollar.RecognizerPoint.new(75, 506, str(1)),
			dollar.RecognizerPoint.new(79, 503, str(1)),
			dollar.RecognizerPoint.new(82, 499, str(1)),
			dollar.RecognizerPoint.new(85, 493, str(1)),
			dollar.RecognizerPoint.new(87, 487, str(1)),
			dollar.RecognizerPoint.new(88, 480, str(1)),
			dollar.RecognizerPoint.new(88, 474, str(1)),
			dollar.RecognizerPoint.new(87, 468, str(1)),
			dollar.RecognizerPoint.new(62, 464, str(2)),
			dollar.RecognizerPoint.new(62, 571, str(2))
		],
		"six-point star":
		[
			dollar.RecognizerPoint.new(177, 554, str(1)),
			dollar.RecognizerPoint.new(223, 476, str(1)),
			dollar.RecognizerPoint.new(268, 554, str(1)),
			dollar.RecognizerPoint.new(183, 554, str(1)),
			dollar.RecognizerPoint.new(177, 490, str(2)),
			dollar.RecognizerPoint.new(223, 568, str(2)),
			dollar.RecognizerPoint.new(268, 490, str(2)),
			dollar.RecognizerPoint.new(183, 490, str(2))
		],
		"asterisk":
		[
			dollar.RecognizerPoint.new(325, 499, str(1)),
			dollar.RecognizerPoint.new(417, 557, str(1)),
			dollar.RecognizerPoint.new(417, 499, str(2)),
			dollar.RecognizerPoint.new(325, 557, str(2)),
			dollar.RecognizerPoint.new(371, 486, str(3)),
			dollar.RecognizerPoint.new(371, 571, str(3))
		],
		"half-note":
		[
			dollar.RecognizerPoint.new(546, 465, str(1)),
			dollar.RecognizerPoint.new(546, 531, str(1)),
			dollar.RecognizerPoint.new(540, 530, str(2)),
			dollar.RecognizerPoint.new(536, 529, str(2)),
			dollar.RecognizerPoint.new(533, 528, str(2)),
			dollar.RecognizerPoint.new(529, 529, str(2)),
			dollar.RecognizerPoint.new(524, 530, str(2)),
			dollar.RecognizerPoint.new(520, 532, str(2)),
			dollar.RecognizerPoint.new(515, 535, str(2)),
			dollar.RecognizerPoint.new(511, 539, str(2)),
			dollar.RecognizerPoint.new(508, 545, str(2)),
			dollar.RecognizerPoint.new(506, 548, str(2)),
			dollar.RecognizerPoint.new(506, 554, str(2)),
			dollar.RecognizerPoint.new(509, 558, str(2)),
			dollar.RecognizerPoint.new(512, 561, str(2)),
			dollar.RecognizerPoint.new(517, 564, str(2)),
			dollar.RecognizerPoint.new(521, 564, str(2)),
			dollar.RecognizerPoint.new(527, 563, str(2)),
			dollar.RecognizerPoint.new(531, 560, str(2)),
			dollar.RecognizerPoint.new(535, 557, str(2)),
			dollar.RecognizerPoint.new(538, 553, str(2)),
			dollar.RecognizerPoint.new(542, 548, str(2)),
			dollar.RecognizerPoint.new(544, 544, str(2)),
			dollar.RecognizerPoint.new(546, 540, str(2)),
			dollar.RecognizerPoint.new(546, 536, str(2))
		]
	}
