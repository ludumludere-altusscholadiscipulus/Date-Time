extends Node2D

onready var analogclock_long = $Time/AnalogClock/LongArrow
onready var analogclock_short = $Time/AnalogClock/ShotArrow
onready var analogclock_seconds = $Time/AnalogClock/SecondsArrow

onready var digital12hour_hour = $Time/Digital12Hour/Hour
onready var digital12hour_minute = $Time/Digital12Hour/Minute
onready var digital12hour_ampm = $Time/Digital12Hour/Base

onready var digital24hour_hour = $Time/Digital24Hour/Hour
onready var digital24hour_minute = $Time/Digital24Hour/Minute

onready var calendar_day = $Date/Calendar/DayBrackets/Day
onready var calendar_month = $Date/Calendar/MonthBrackets/Month
onready var calendar_year = $Date/Calendar/YearBracket/Year

onready var day_no_text = $Date/DayNo/Brackets/Day

onready var animation_player = $AnimationPlayer

var day_text : String
var month_text : String
var days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

const weekdays := ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
const months := ["January","February","March","April",'May',"June",'July','August','September','October','November','December']
const click_particles := preload("res://Particles.tscn")

func _ready():
	$Music.play()
	var year = Time.get_datetime_dict_from_system()["year"]
	if year % 400 == 0:
		days[1] = 29
	elif year % 100 == 0:
		days[1] = 28
	elif year % 4 == 0:
		days[1] = 29
	else:
		days[1] = 28
	

func _process(_delta):
	var date_dict = Time.get_datetime_dict_from_system()
	var day = date_dict["day"]
	var weekday = date_dict["weekday"]
	day_text = weekdays[weekday - 1]
	var hour = date_dict["hour"]
	var minute = date_dict["minute"]
	var second = date_dict["second"]
	var year = date_dict["year"]
	var month = date_dict["month"]
	month_text = months[month - 1]
	
	analogclock_long.rotation_degrees = 6 * minute
	analogclock_short.rotation_degrees = 30 * (hour % 12) + float((minute % 60) / 2)
	analogclock_seconds.rotation_degrees = 6 * second
		
	digital12hour_hour.text  = str(hour % 12) if hour % 12 != 0 else "12"
	digital12hour_minute.text = "0" + str(minute) if minute < 10 else str(minute)
	digital12hour_ampm.frame = 1 if hour >= 12 else 0
	
	digital24hour_hour.text  = "0" + str(hour) if hour < 10 else str(hour)
	digital24hour_minute.text = "0" + str(minute) if minute < 10 else str(minute)
	
	calendar_day.text = str(day)
	calendar_month.text = month_text
	calendar_year.text = str(year)
	
	day_no_text.text = "Day " + str(current_day(day,month))
	
	var time_in_seconds = second + hour * 3600 + minute * 60
	var time_frame = range_lerp(time_in_seconds,0,86400,0,24)
	animation_player.play("DayNightCycle")
	animation_player.seek(time_frame)
	
	if Input.is_action_just_pressed("click"):
		var pos = get_global_mouse_position()
		var obj = click_particles.instance()
		add_child(obj)
		obj.position = pos
	
	if $Time.visible:
		$Title.text = "Time"
	else:
		$Title.text = "Date"
	
func current_day(day : int, month : int):
	var curr = day
	for i in range(month-1):
		curr += days[i]
	return curr
	
func _on_Timer_timeout():
	if $Time.visible:
		$Time.visible = false
		$Date.visible = true
	else:
		$Time.visible = true
		$Date.visible = false


func _on_Music_finished():
	$Music.play()
