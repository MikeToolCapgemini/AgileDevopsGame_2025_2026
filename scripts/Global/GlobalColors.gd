extends Node

const TeamColors = {
	"BuildOrange": Color("ff6500"),
	"PlanYellow": Color("d7cd00ff"),
	"ReleasePurple": Color("7c00ff"),
	"OperateBrown": Color("5e301c"),
	"MonitorBlue": Color("0028ff"),
	"TestGreen": Color("00a500"),
	"DeployTeal": Color("00b0ff"),
	"CodeRed": Color("e50000"),
	"CapgeminiBlue": Color("2c85d2")
}



var BuildOrange = Color("ff6500")
var PlanningYellow = Color("d7cd00ff")
var ReleasePurple = Color("7c00ff")
var OperateBrown = Color("5e301c")
var MonitorBlue = Color("0028ff")
var TestGreen = Color("00a500")
var DeployTeal = Color("00b0ff")
var CodeRed = Color("e50000")
var CapgeminiBlue = Color("2c85d2")

var BuildOrangeStyle:StyleBoxFlat = StyleBoxFlat.new()
var PlanningYellowStyle:StyleBoxFlat = StyleBoxFlat.new()
var ReleasePurpleStyle:StyleBoxFlat = StyleBoxFlat.new()
var OperateBrownStyle:StyleBoxFlat = StyleBoxFlat.new()
var MonitorBlueStyle:StyleBoxFlat = StyleBoxFlat.new()
var TestGreenStyle:StyleBoxFlat = StyleBoxFlat.new()
var DeployTealStyle:StyleBoxFlat = StyleBoxFlat.new()
var CodeRedStyle:StyleBoxFlat = StyleBoxFlat.new()
var CapgeminiBlueStyle:StyleBoxFlat = StyleBoxFlat.new()

#const TeamThemes = {
	#"BuildOrange": BuildOrangeStyle,
	#"PlanningYellow": PlanningYellowStyle,
	#"ReleasePurple": ReleasePurpleStyle,
	#"OperateBrown": OperateBrownStyle,
	#"MonitorBlue": MonitorBlueStyle,
	#"TestGreen": TestGreenStyle,
	#"DeployTeal": DeployTealStyle,
	#"CodeRed": CodeRedStyle,
	#"CapgeminiBlue": CapgeminiBlueStyle
	#
#}

func _ready():
	PlanningYellowStyle.bg_color = PlanningYellow
	BuildOrangeStyle.bg_color = BuildOrange
	TestGreenStyle.bg_color = TestGreen
	DeployTealStyle.bg_color = DeployTeal
	CapgeminiBlueStyle.bg_color = CapgeminiBlue

	ReleasePurpleStyle.bg_color = ReleasePurple
	OperateBrownStyle.bg_color = OperateBrown
	MonitorBlueStyle.bg_color = MonitorBlue
	CodeRedStyle.bg_color = CodeRed

	
