class_name Sigil extends Node
 
static var sigils : Array[String] = [
	"res://sprites/sigils/1.png",
	"res://sprites/sigils/2.png",
	"res://sprites/sigils/3.png",
	"res://sprites/sigils/4.png",
	"res://sprites/sigils/5.png",
	"res://sprites/sigils/6.png",
	"res://sprites/sigils/7.png",
	"res://sprites/sigils/8.png",
	"res://sprites/sigils/9.png",
	"res://sprites/sigils/10.png",
	"res://sprites/sigils/11.png",
	"res://sprites/sigils/12.png",
	"res://sprites/sigils/13.png",
	"res://sprites/sigils/14.png",
	"res://sprites/sigils/15.png",
	"res://sprites/sigils/16.png",
]

static var used_sigils : Array[String] = []

static func get_unused_sigil() -> String:
	var unused_sigils : Array[String] = []
	for sigil in sigils:
		if(used_sigils.find(sigil) < 0):
			unused_sigils.append(sigil)
	var unused_sigil = unused_sigils[randi_range(0,unused_sigils.size()-1)]
	checkout_sigil(unused_sigil)
	return unused_sigil

static func checkout_sigil(sigil : String):
	used_sigils.append(sigil)

static func return_sigil(sigil : String):
	used_sigils.erase(sigil)
	
