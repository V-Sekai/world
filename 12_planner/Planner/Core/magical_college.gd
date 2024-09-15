extends Domain

# https://robertheaton.com/2018/12/17/wavefunction-collapse-algorithm/

func _init() -> void:
	add_actions([set_tile_state, remove_possible_tiles])
	add_task_methods("collapse_wave_function", [collapse_wave_function])
	add_task_methods("meta_collapse_wave_function", [meta_collapse_wave_function])
	add_task_methods("update_possible_tiles", [update_possible_tiles])

# Function to calculate entropy of a square
func _calculate_entropy(square) -> int:
	return len(square["possible_tiles"])

func _find_lowest_entropy_square(state) -> Variant:
	var min_entropy = INF
	var min_squares = []
	for key in state:
		var square = state[key]
		if len(square["possible_tiles"]) <= 1: # Skip if the square is solved
			continue
		var entropy = len(square["possible_tiles"])
		if entropy < min_entropy:
			min_entropy = entropy
			min_squares = [key]
		elif entropy == min_entropy:
			min_squares.append(key)
	
	if len(min_squares) == 0:
		return null
	
	var chosen_key = min_squares[0]
	return chosen_key

# # Graph Grammars
# Graph grammars extend formal string-based grammars to graphs. We use the algebraic approach, specifically Double-Pushout Graph Grammars (DPO), borrowing terms from category theory.
# **Coding** and **GraphGrammars** are key concepts in this context.
# For more details, refer to the [source](https://liacs.leidenuniv.nl/assets/PDF/TechRep/tr95-34.pdf).
# # Definition 1: EdNCE Grammar
# An **edNCE grammar** is a structured set, or tuple, `G = (Λ, Ξ, Σ, Π, P, S)` where:
# - `Λ` represents the set of all possible node labels,
# - `Ξ`, which is a subset of `Λ`, represents the set of terminal node labels,
# - `Σ` represents the set of all possible edge labels,
# - `Π`, which is a subset of `Σ`, represents the set of final edge labels,
# - `P` is the finite set of production rules,
# - `S` is the initial nonterminal symbol, which belongs to the set difference of `Λ` and `Ξ`.
# A production rule is defined as `X -> (D, C)`, where `X` is a nonterminal symbol that belongs to the set difference of `Λ` and `Ξ`, `D` is a graph over `Λ` and `Σ`, and `C` is a subset of the Cartesian product of `Λ`, `Λ`, `V(D)`, and `fin; outg`.

const possible_types = {
  "@context": {
	"gg": "http://v-sekai.com/graphgrammar#",
	"ex": "http://v-sekai.com/ex#"
  },
  "@id": "ex:myGraphGrammar",
  "@type": "gg:GraphGrammar",
  "gg:nodeLabels": [
	"CITY_MESH_road_straight_01", "CITY_MESH_road_turn_right_01", "CITY_MESH_road_turn_left_01", 
	"CITY_MESH_road_intersection_T_01", "CITY_MESH_square_central_01", "CITY_MESH_park_common_01", 
	"CITY_MESH_kiosk_newspapers_01", "CITY_MESH_kiosk_snacks_01", "CITY_MESH_kiosk_flowers_01", 
	"CITY_MESH_building_dormitory_01", "CITY_MESH_building_lab_student_01", "CITY_MESH_building_library_01", 
	"CITY_MESH_station_train_01", "CITY_MESH_streetlamp_standard_01", "CITY_MESH_tree_park_01", 
	"BUILDING_MESH_hall_entrance_01", "BUILDING_MESH_corridor_school_01", "BUILDING_MESH_auditorium_main_01", 
	"BUILDING_MESH_classroom_standard_01", "BUILDING_MESH_hall_mess_01", "BUILDING_MESH_kitchen_main_01", 
	"BUILDING_MESH_hub_dormitory_01", "BUILDING_MESH_room_dorm_01", "BUILDING_MESH_bedroom_individual_01", 
	"BUILDING_MESH_courtyard_main_01", "BUILDING_MESH_garden_common_01", "BUILDING_MESH_lab_science_01", 
	"BUILDING_MESH_office_principal_01", "BUILDING_MESH_railing_standard_01", "BUILDING_MESH_lab_alchemy_01", 
	"BUILDING_MESH_lab_computer_01", "BUILDING_MESH_room_home_economics_01", "BUILDING_MESH_room_music_01", 
	"BUILDING_MESH_theatre_main_01", "BUILDING_MESH_gymnasium_main_01", "ROOM_MESH_door_standard_01", 
	"ROOM_MESH_window_standard_01", "ROOM_MESH_desk_office_01", "ROOM_MESH_chair_office_01", 
	"ROOM_MESH_blackboard_standard_01", "ROOM_MESH_board_bulletin_01", "ROOM_MESH_portrait_hall_01", 
	"ROOM_MESH_mirror_dressing_01", "ROOM_MESH_light_ceiling_01", "ROOM_MESH_chandelier_grand_01", 
	"ROOM_MESH_lamp_table_01", "ROOM_MESH_bookcase_standard_01", "ROOM_MESH_wardrobe_bedroom_01", 
	"ROOM_MESH_stove_kitchen_01", "ROOM_MESH_pot_flower_01"
  ],
  "gg:terminalNodeLabels": ["end"],
  "gg:edgeLabels": ["next"],
  "gg:finalEdgeLabels": ["next"],
  "gg:productionRules": [
	{
	  "@id": "ex:rule1",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_road_straight_01",
		"data": {
		  "Footprint": "2x1x0.1",
		  "FlavorText": "A simple straight road",
		  "Tags": ["Road", "Transport"],
		  "Requirements": ["Straight", "Cross"],
		  "Contents": []
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_turn_right_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_turn_left_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"},
		{"node": "CITY_MESH_streetlamp_standard_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule2",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_road_turn_right_01",
		"data": {
		  "Footprint": "2x2x0.1",
		  "FlavorText": "A right-angled corner road",
		  "Tags": ["Road", "Transport"],
		  "Requirements": ["Turn Right"],
		  "Contents": []
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_straight_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"}, 
		{"node": "CITY_MESH_streetlamp_standard_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule3",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_road_turn_left_01",
		"data": {
		  "Footprint": "2x2x0.1",
		  "FlavorText": "A left-angled corner road",
		  "Tags": ["Road", "Transport"],
		  "Requirements": ["Turn Left"],
		  "Contents": []
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_straight_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"}, 
		{"node": "CITY_MESH_streetlamp_standard_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule4",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_road_intersection_T_01",
		"data": {
		  "Footprint": "3x3x0.1",
		  "FlavorText": "T-junction road",
		  "Tags": ["Road", "Transport"],
		  "Requirements": ["3-way junction"],
		  "Contents": []
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_straight_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_turn_right_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_turn_left_01", "edge": "next"},
		{"node": "CITY_MESH_square_central_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule5",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_square_central_01",
		"data": {
		  "Footprint": "5x5x0.2",
		  "FlavorText": "A bustling city square",
		  "Tags": ["Social", "Area"],
		  "Requirements": ["Adjacent to roads"],
		  "Contents": ["Benches", "Statues"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"}, 
		{"node": "CITY_MESH_park_common_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_newspapers_01", "edge": "next"},
		{"node": "CITY_MESH_kiosk_snacks_01", "edge": "next"},
		{"node": "CITY_MESH_kiosk_flowers_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule6",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_park_common_01",
		"data": {
		  "Footprint": "1x1x1.5",
		  "FlavorText": "Newsstand selling papers",
		  "Tags": ["Commerce"],
		  "Requirements": ["Near pedestrian area"],
		  "Contents": ["Newspapers", "Magazines"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_square_central_01", "edge": "next"}, 
		{"node": "CITY_MESH_tree_park_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_garden_common_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule7",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_kiosk_newspapers_01",
		"data": {
		  "Footprint": "1x1x1.5",
		  "FlavorText": "Quick snacks on the go",
		  "Tags": ["Commerce", "Food"],
		  "Requirements

": ["Near pedestrian area"],
		  "Contents": ["Snack foods", "Beverages"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_square_central_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_snacks_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_flowers_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule8",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_kiosk_snacks_01",
		"data": {
		  "Footprint": "1x1x1.5",
		  "FlavorText": "Fresh flowers for sale",
		  "Tags": ["Commerce"],
		  "Requirements": ["Near pedestrian area"],
		  "Contents": ["Flower bouquets", "Potted plants"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_square_central_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_newspapers_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_flowers_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule9",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_kiosk_flowers_01",
		"data": {
		  "Footprint": "10x6x3",
		  "FlavorText": "Student housing facility",
		  "Tags": ["Housing"],
		  "Requirements": ["Near educational building"],
		  "Contents": ["Beds", "Desks", "Personal items"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_square_central_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_newspapers_01", "edge": "next"}, 
		{"node": "CITY_MESH_kiosk_snacks_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule10",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_building_dormitory_01",
		"data": {
		  "Footprint": "8x8x3",
		  "FlavorText": "Study and lecture halls",
		  "Tags": ["Education"],
		  "Requirements": ["On campus"],
		  "Contents": ["Chairs", "Projectors", "Lecterns"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_building_lab_student_01", "edge": "next"}, 
		{"node": "CITY_MESH_building_library_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_hub_dormitory_01", "edge": "next"},
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule11",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_building_lab_student_01",
		"data": {
		  "Footprint": "6x7x3",
		  "FlavorText": "Repository of knowledge",
		  "Tags": ["Education"],
		  "Requirements": ["Quiet area"],
		  "Contents": ["Books", "Reading tables", "Computers"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_building_dormitory_01", "edge": "next"}, 
		{"node": "CITY_MESH_building_library_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_classroom_standard_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule12",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_building_library_01",
		"data": {
		  "Footprint": "15x6x5",
		  "FlavorText": "Transit hub for city travel",
		  "Tags": ["Transport"],
		  "Requirements": ["Near roads"],
		  "Contents": ["Ticket counters", "Waiting areas"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_building_dormitory_01", "edge": "next"}, 
		{"node": "CITY_MESH_building_lab_student_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_lab_computer_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule13",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_station_train_01",
		"data": {
		  "Footprint": "0.2x0.2x3",
		  "FlavorText": "Provides light at night",
		  "Tags": ["Infrastructure"],
		  "Requirements": ["Alongside roads"],
		  "Contents": ["Light"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_straight_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"}, 
		{"node": "CITY_MESH_building_library_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule14",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_streetlamp_standard_01",
		"data": {
		  "Footprint": "1x1x2",
		  "FlavorText": "Oxygen provider",
		  "Tags": ["Nature"],
		  "Requirements": ["Soil patch"],
		  "Contents": ["Leaves", "Branches"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_road_straight_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_turn_right_01", "edge": "next"}, 
		{"node": "CITY_MESH_road_turn_left_01", "edge": "next"},
		{"node": "CITY_MESH_road_intersection_T_01", "edge": "next"},
		{"node": "CITY_MESH_station_train_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule15",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "CITY_MESH_tree_park_01",
		"data": {
		  "Footprint": "10x10x3",
		  "FlavorText": "Grand vestibule welcoming students and visitors alike",
		  "Tags": ["Entry", "Spacious"],
		  "Requirements": ["Main entryway"],
		  "Contents": ["Reception desk", "Notice boards", "Seating"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "CITY_MESH_park_common_01", "edge": "next"}, 
		{"node": "CITY_MESH_streetlamp_standard_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule16",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_hall_entrance_01",
		"data": {
		  "Dimensions": "10x6x3",
		  "Description": "The primary entrance hall of the building, welcoming students and staff.",
		  "Tags": ["Entryway", "Main Hall"],
		  "Requirements": [],
		  "Features": ["Reception Area", "Seating"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_auditorium_main_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_theatre_main_01", "edge": "next"},
		{"node": "CITY_MESH_building_dormitory_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule17",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_corridor_school_01",
		"data": {
		  "Dimensions": "20x15x5",
		  "Description": "Large space for assemblies and performances",
		  "Tags": ["Performance", "Assembly"],
		  "Requirements": ["Events"],
		  "Features": ["Stage", "Lighting", "Sound system"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_hall_entrance_01", "edge": "next"}, 
		{"node": "BUILDING_MESH_classroom_standard_01", "edge": "next"}, 


		{"node": "BUILDING_MESH_lab_science_01", "edge": "next"},
		{"node": "BUILDING_MESH_office_teacher_01", "edge": "next"},
		{"node": "BUILDING_MESH_staircase_main_01", "edge": "next"},
		{"node": "BUILDING_MESH_theatre_main_01", "edge": "next"},
		{"node": "BUILDING_MESH_kitchen_main_01", "edge": "next"},
		{"node": "BUILDING_MESH_lab_alchemy_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule18",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_auditorium_main_01",
		"data": {
		  "Dimensions": "20x15x5",
		  "Description": "A large space for school assemblies, presentations, and performances.",
		  "Tags": ["Auditorium", "Assembly Hall"],
		  "Requirements": [],
		  "Features": ["Stage", "Seating", "Audio-Visual Equipment"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_hall_entrance_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule19",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_classroom_standard_01",
		"data": {
		  "Dimensions": "12x8x3",
		  "Description": "Where students dine together",
		  "Tags": ["Dining", "Social"],
		  "Requirements": ["Meal times"],
		  "Features": ["Dining tables", "Buffet stations", "Waste bins"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule20",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_hall_mess_01",
		"data": {
		  "Dimensions": "6x4x2.5",
		  "Description": "The culinary heart of the school",
		  "Tags": ["Food prep", "Staff only"],
		  "Requirements": ["Certified staff"],
		  "Features": ["Stoves", "Sinks", "Prep tables", "Storage"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_kitchen_main_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule21",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_kitchen_main_01",
		"data": {
		  "Dimensions": "10x10x2.5",
		  "Description": "Common area for dorm residents",
		  "Tags": ["Housing", "Community"],
		  "Requirements": ["Residential access"],
		  "Features": ["Lounge furniture", "Entertainment units"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_hall_mess_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule22",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_hub_dormitory_01",
		"data": {
		  "Dimensions": "6x4x3",
		  "Description": "Shared living quarters for students",
		  "Tags": ["Housing", "Shared"],
		  "Requirements": ["Residents"],
		  "Features": ["Beds", "Desks", "Wardrobes", "Study lamps"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_room_dorm_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule23",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_room_dorm_01",
		"data": {
		  "Dimensions": "4x4x3",
		  "Description": "Private sleeping space for one",
		  "Tags": ["Housing", "Private"],
		  "Requirements": ["Single occupancy"],
		  "Features": ["Single bed", "Desk", "Closet", "Nightstand"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_hub_dormitory_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule24",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_bedroom_individual_01",
		"data": {
		  "Dimensions": "Variable",
		  "Description": "Outdoor area for recreation and relaxation",
		  "Tags": ["Nature", "Leisure"],
		  "Requirements": ["Surrounding buildings"],
		  "Features": ["Planters", "Sculptures", "Trees"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_hub_dormitory_01", "edge": "next"},
		{"node": "BUILDING_MESH_room_dorm_01", "edge": "next"},
		{"node": "BUILDING_MESH_office_teacher_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule25",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_courtyard_main_01",
		"data": {
		  "Dimensions": "5x5x1",
		  "Description": "A touch of nature within the school grounds",
		  "Tags": ["Nature", "Calm"],
		  "Requirements": ["Grounds maintenance"],
		  "Features": ["Vegetation", "Decorative stones", "Water features"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_classroom_standard_01", "edge": "next"},
		{"node": "BUILDING_MESH_area_communal_01", "edge": "next"},
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "BUILDING_MESH_garden_common_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule26",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_garden_common_01",
		"data": {
		  "Dimensions": "8x6x3",
		  "Description": "Equipped for experiments and scientific discovery",
		  "Tags": ["Education", "Science"],
		  "Requirements": ["Supervised access"],
		  "Features": ["Microscopes", "Bunsen burners", "Chemicals"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_courtyard_main_01", "edge": "next"},
		{"node": "CITY_MESH_park_common_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule27",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_lab_science_01",
		"data": {
		  "Dimensions": "7x7x3",
		  "Description": "Mystical room dedicated to the study of alchemy",
		  "Tags": ["Specialty", "Magic"],
		  "Requirements": ["Trained alchemist"],
		  "Features": ["Cauldrons", "Spell books", "Ingredient shelves"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule28",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_office_principal_01",
		"data": {
		  "Dimensions": "Variable",
		  "Description": "The principal's personal decision-making space",
		  "Tags": ["Administrative"],
		  "Requirements": ["Principal"],
		  "Features": ["Desk", "Files", "Communication devices"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_wing_administrative_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule29",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_railing_standard_01",
		"data": {
		  "Dimensions": "2m x 1m x 3m",
		  "Description": "Provides safety and division between open spaces",
		  "Tags": ["Safety", "Infrastructure"],
		  "Requirements": ["Along

 edges"],
		  "Features": ["Railings"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_balcony_01", "edge": "next"},
		{"node": "BUILDING_MESH_staircase_main_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule30",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_lab_alchemy_01",
		"data": {
		  "Dimensions": "8x6x3",
		  "Description": "Mystical room dedicated to the study of alchemy",
		  "Tags": ["Specialty", "Magic"],
		  "Requirements": ["Trained alchemist"],
		  "Features": ["Cauldrons", "Spell books", "Ingredient shelves"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "BUILDING_MESH_classroom_specialized_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule31",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_lab_computer_01",
		"data": {
		  "Dimensions": "6x6x3",
		  "Description": "High-tech room with computers for research and coding",
		  "Tags": ["Technology", "Education"],
		  "Requirements": ["Technical classes"],
		  "Features": ["Workstations", "Servers", "Software"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "CITY_MESH_building_library_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule32",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_room_home_economics_01",
		"data": {
		  "Dimensions": "7x7x2.5",
		  "Description": "Space for learning life skills and domestic crafts",
		  "Tags": ["Practical", "Skill building"],
		  "Requirements": ["Supervised classes"],
		  "Features": ["Appliances", "Textile tools", "Produce"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule33",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_room_music_01",
		"data": {
		  "Dimensions": "15x10x5",
		  "Description": "Soundproof room for practicing and learning music",
		  "Tags": ["Artistic", "Soundproof"],
		  "Requirements": ["Musical activities"],
		  "Features": ["Sheet music", "Amplifiers", "Recording equipment"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule34",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_theatre_main_01",
		"data": {
		  "Dimensions": "20x15x7",
		  "Description": "A stage for drama practices and performances",
		  "Tags": ["Drama", "Performance"],
		  "Requirements": ["Rehearsals and shows"],
		  "Features": ["Props", "Backdrops", "Costume racks"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "BUILDING_MESH_auditorium_main_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule35",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_gymnasium_main_01",
		"data": {
		  "Dimensions": "8x8x4",
		  "Description": "Indoor sports facility",
		  "Tags": ["Sports", "Large"],
		  "Requirements": ["Physical education"],
		  "Features": ["Equipment", "Scoreboards", "Bleachers"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_room_changing_01", "edge": "next"},
		{"node": "CITY_MESH_building_dormitory_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule36",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_room_gigachad_01",
		"data": {
		  "Dimensions": "3x3x2",
		  "Description": "Exclusive gym for top-tier athletes",
		  "Tags": ["Elite", "Fitness"],
		  "Requirements": ["Athletic excellence"],
		  "Features": ["Premium equipment", "Tracking systems"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_gymnasium_main_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule37",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_room_janitor_01",
		"data": {
		  "Dimensions": "4x4x2.5",
		  "Description": "Storage and workspace for cleaning staff",
		  "Tags": ["Storage", "Staff"],
		  "Requirements": ["Staff"],
		  "Features": ["Mops", "Buckets", "Maintenance tools"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule38",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_office_teacher_01",
		"data": {
		  "Dimensions": "4x4x2.5",
		  "Description": "Workspace for faculty staff",
		  "Tags": ["Work", "Faculty"],
		  "Requirements": ["Faculty staff"],
		  "Features": ["Bookshelf", "Printer", "Stationery"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "BUILDING_MESH_bedroom_individual_01", "edge": "next"},
		{"node": "BUILDING_MESH_dorms_teacher_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule39",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_room_break_teacher_01",
		"data": {
		  "Dimensions": "Variable",
		  "Description": "Relaxation area for staff during breaks",
		  "Tags": ["Rest", "Staff only"],
		  "Requirements": ["Staff"],
		  "Features": ["Microwave", "Water dispenser", "Lounge chairs"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_office_teacher_01", "edge": "next"},
		{"node": "BUILDING_MESH_office_faculty_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule40",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_staircase_main_01",
		"data": {
		  "Dimensions": "6x6x3",
		  "Description": "Connects different floors in the school",
		  "Tags": ["Vertical", "Accessible"],
		  "Requirements": ["Multiple Floors"],
		  "Features": ["Escalators (if applicable)", "Signage"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_corridor_school_01", "edge": "next"},
		{"node": "BUILDING_MESH_floor_all_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule41",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_dorms_teacher_01",
		"data": {
		  "Dimensions": "5x5x2.5",
		  "Description": "On-site living accommodations for teachers",
		  "Tags": ["Housing", "Faculty"],
		  "Requirements": ["Faculty staff"],
		  "Features": ["Bed", "Desk", "Small dining area", "Bathroom"]
		}
	  },
	  "gg:rightHandSide": [
	   

 {"node": "BUILDING_MESH_facility_school_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule42",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "BUILDING_MESH_office_headmaster_01",
		"data": {
		  "Dimensions": "5x5x2.5",
		  "Description": "Administrative nexus and leader's workspace",
		  "Tags": ["Leadership", "Private"],
		  "Requirements": ["Headmaster"],
		  "Features": ["Executive chair", "Safe", "Credentials"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "BUILDING_MESH_wing_administrative_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule43",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_door_standard_01",
		"data": {
		  "Dimensions": "1.5m x 0.2m x 2m",
		  "Description": "Standard door providing room access and privacy",
		  "Tags": ["Access", "Privacy"],
		  "Requirements": ["Doorway"],
		  "Features": ["Handle", "Lock"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_room_to_room_01", "edge": "next"},
		{"node": "ROOM_MESH_corridor_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule44",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_window_standard_01",
		"data": {
		  "Dimensions": "1.2m x 0.8m x 0.07m",
		  "Description": "Large double-paneled window letting in light",
		  "Tags": ["Transparent", "Lite"],
		  "Requirements": ["Exterior Wall"],
		  "Features": ["Glass Panes", "Openable"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_view_outside_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule45",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_desk_office_01",
		"data": {
		  "Dimensions": "1.2m x 0.6m x 0.75m",
		  "Description": "Solid oak desk with multiple drawers",
		  "Tags": ["Furniture", "Study"],
		  "Requirements": ["Floor Space"],
		  "Features": ["Drawers", "Surface Space"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_chair_near_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule46",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_chair_office_01",
		"data": {
		  "Dimensions": "0.6m x 0.6m x 1.2m",
		  "Description": "Comfortable rolling office chair",
		  "Tags": ["Seating", "Mobile"],
		  "Requirements": ["Underneath Desk"],
		  "Features": ["Wheels", "Adjustable Height"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_area_office_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule47",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_blackboard_standard_01",
		"data": {
		  "Dimensions": "2m x 0.05m x 1.2m",
		  "Description": "Classic green blackboard with chalk traces",
		  "Tags": ["Educational", "Writable"],
		  "Requirements": ["Classroom Wall"],
		  "Features": ["Chalk", "Eraser"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_desk_in_front_of_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule48",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_board_bulletin_01",
		"data": {
		  "Dimensions": "1m x 0.02m x 1.5m",
		  "Description": "Cork bulletin board for announcements and notices",
		  "Tags": ["Informative", "Pinnable"],
		  "Requirements": ["Accessible Wall Area"],
		  "Features": ["Flyers", "Notices"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_space_public_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule49",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_portrait_hall_01",
		"data": {
		  "Dimensions": "0.5m x 0.01m x 1.8m",
		  "Description": "Framed portrait of a historical figure",
		  "Tags": ["Art", "Decorative"],
		  "Requirements": ["Wall space"],
		  "Features": ["Frame", "Portrait"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_hall_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule50",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_mirror_dressing_01",
		"data": {
		  "Dimensions": "0.5m x 0.01m x 1.8m",
		  "Description": "Full-length wall mirror for reflection.",
		  "Tags": ["Reflective", "Glass"],
		  "Requirements": ["Vertical Wall Space"],
		  "Features": ["Mirror", "Frame"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_area_dressing_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule51",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_light_ceiling_01",
		"data": {
		  "Dimensions": "0.3m x 0.3m x 0.2m",
		  "Description": "Bright LED ceiling light fixture.",
		  "Tags": ["Illumination", "Energy-Efficient"],
		  "Requirements": ["Ceiling Access"],
		  "Features": ["LED Bulbs", "Mounting Hardware"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_room_any_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule52",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_chandelier_grand_01",
		"data": {
		  "Dimensions": "1m x 1m x 1.5m",
		  "Description": "Ornate crystal chandelier with dimming capability.",
		  "Tags": ["Luxurious", "Light-Source"],
		  "Requirements": ["High Ceiling"],
		  "Features": ["Crystals", "Dimmer Switch"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_room_grand_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule53",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_lamp_table_01",
		"data": {
		  "Dimensions": "0.3m x 0.3m x 0.5m",
		  "Description": "Modern table lamp with an adjustable neck.",
		  "Tags": ["Portable", "Light"],
		  "Requirements": ["Power Source"],
		  "Features": ["Adjustable Neck", "Switch"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_desk_01", "edge": "next"},
		{"node": "ROOM_MESH_table_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule54",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_bookcase_standard_01",
		"data": {
		  "Dimensions": "1m x 0.3m x 2m",
		  "Description": "Tall mahogany bookcase full of volumes.",
		  "Tags": ["Storage", "Wooden"],
		  "Requirements": ["Stable Wall Support"],
		 

 "Features": ["Shelves", "Books"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_study_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule55",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_wardrobe_bedroom_01",
		"data": {
		  "Dimensions": "2m x 0.6m x 2.2m",
		  "Description": "Spacious wardrobe with sliding doors.",
		  "Tags": ["Clothing", "Storage"],
		  "Requirements": ["Bedroom Corner"],
		  "Features": ["Clothes", "Hangers"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_bed_near_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule56",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_stove_kitchen_01",
		"data": {
		  "Dimensions": "0.8m x 0.6m x 0.9m",
		  "Description": "Four-burner gas stove with an oven.",
		  "Tags": ["Cooking", "Appliance"],
		  "Requirements": ["Kitchen Placement"],
		  "Features": ["Burners", "Oven"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_countertop_near_01", "edge": "next"},
		{"node": "end"}
	  ]
	},
	{
	  "@id": "ex:rule57",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": {
		"node": "ROOM_MESH_pot_flower_01",
		"data": {
		  "Dimensions": "0.3m x 0.3m x 0.4m",
		  "Description": "Terracotta flower pot with a blooming plant.",
		  "Tags": ["Decorative", "Natural"],
		  "Requirements": ["Sunlight Exposure"],
		  "Features": ["Soil", "Plant"]
		}
	  },
	  "gg:rightHandSide": [
		{"node": "ROOM_MESH_windowsill_01", "edge": "next"},
		{"node": "ROOM_MESH_table_01", "edge": "next"},
		{"node": "end"}
	  ]
	}
  ],
  "gg:initialNonterminalSymbol": "CITY_MESH_road_straight_01"
}

func update_possible_tiles(state, coordinates, chosen_tile):
	var todos = []
	
	# Return early if chosen_tile is null
	if chosen_tile == null:
		return todos

	if state.has(coordinates) and "possible_tiles" in state[coordinates]:
		var possible_tiles = state[coordinates]["possible_tiles"]
		
		# Find the right-hand side nodes for the chosen tile
		var next_nodes = []
		for rule in possible_types["gg:productionRules"]:
			if rule["gg:leftHandSide"] == chosen_tile:
				for node in rule["gg:rightHandSide"]:
					next_nodes.append(node['node'])
				break
		
		var difference = array_difference(possible_tiles, next_nodes)
		
		# Remove the tiles that are not in the next nodes
		for tile in difference:
			possible_tiles.erase(tile)
		
		todos.append(["remove_possible_tiles", coordinates, difference])
		todos.append(["set_tile_state", coordinates, possible_tiles])
	return todos

static func array_difference(a1: Array, a2: Array) -> Array:
	var diff = []
	for element in a1:
		if element not in a2:
			diff.append(element)
	return diff

func collapse_wave_function(state: Dictionary) -> Array:
	var result = [["set_tile_state"]]
	var key = _find_lowest_entropy_square(state)

	if key == null:
		if all_tiles_have_state(state):
			return []
		else:
			return []

	var possible_tiles: Array = state[key]["possible_tiles"]
	var chosen_tile = null

	# If this is the first tile, choose a starting tile
	if key == 0:
		chosen_tile = "root"
	else:
		# Otherwise, choose a tile based on the previous tile and the graph grammar rules
		var previous_tile = state[key - 1]["tile"]
		for rule in possible_types["gg:productionRules"]:
			if rule["gg:leftHandSide"]["node"] == previous_tile:
				for node in rule["gg:rightHandSide"]:
					if node['node'] in possible_tiles:
						chosen_tile = node['node']
						break
			if chosen_tile != null:
				break

	if chosen_tile == null:
		# If no valid tile was found, choose a random tile
		chosen_tile = possible_tiles[0]

		possible_tiles.erase(chosen_tile)
		result[0].append(key)
		result[0].append(chosen_tile)
	return result

func set_tile_state(state, coordinate, chosen_tile) -> Dictionary:
	if state.has(coordinate):
		state[coordinate]["tile"] = chosen_tile
		state[coordinate]["possible_tiles"] = [chosen_tile]
	return state

func remove_possible_tiles(state, coordinate, chosen_tiles: Array) -> Dictionary:
	if state.has(coordinate):
		if state[coordinate].has("possible_tiles"):
			var possible_tiles = state[coordinate]["possible_tiles"]
			for tile in chosen_tiles:
				possible_tiles.erase(tile)
	return state

## Function to find the square with the lowest entropy
func calculate_square(state):
	return _find_lowest_entropy_square(state)

# Function to check if all tiles have a state
func all_tiles_have_state(state):
	for key in state:
		var square = state[key]
		if square["tile"] == null or len(square["possible_tiles"]) != 1: # If a square's tile is null or doesn't have exactly one possible tile, it doesn't have a state yet
			return false
	return true
	
func meta_collapse_wave_function(state):
	var old_state = state.duplicate()  # Save the old state for comparison
	for key in state:
		if 'type' in state[key] and state[key]['type'] == "gg:initialNonterminalSymbol":
			return []
	if not all_tiles_have_state(state):
		var todo_list = [["collapse_wave_function"]]
		todo_list.append(["meta_collapse_wave_function"])
		return todo_list
	elif old_state == state:  # If the state hasn't changed, stop the recursion
		return []
	else:
		var possible_tiles = []
		for graph in possible_types["gg:nodeLabels"]:
			possible_tiles.append(graph)
		state[0] = { "tile": null, "possible_tiles": possible_tiles }
		
		# Remove null states if 'end' is found
		for key in state:
			if state[key]['tile'] == "gg:initialNonterminalSymbol":
				var new_state = {}
				for k in state.keys():
					if state[k]['tile'] != null:
						new_state[k] = state[k]
				state = new_state
				break
		return [["meta_collapse_wave_function"]]


func is_valid_sequence(state: Dictionary) -> bool:
	# Convert the gg:productionRules array into a dictionary for easier access
	var possible_types_dict = {}
	for rule in possible_types["gg:productionRules"]:
		var item_id = rule["@id"]
		var next_items = []
		for node in rule["gg:rightHandSide"]:
			next_items.append(node['node'])
		possible_types_dict[item_id] = next_items

	print("Possible types dict: ", possible_types_dict)

	var keys = state.keys()
	for i in range(keys.size() - 1):
		var currentType = state[keys[i]]["tile"]
		if currentType != null:
			var nextType = state[keys[i + 1]]["tile"]
			if nextType != null:
				print("Current type: ", currentType)
				print("Next type: ", nextType)
				if not possible_types_dict.has(currentType):
					print("Current type not in possible types dict")
					return false
				elif not possible_types_dict[currentType].has(nextType):
					print("Next type not in current type's list")
					return false
	return true
