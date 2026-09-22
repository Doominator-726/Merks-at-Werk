extends Node
#autoload so that crt can load correctly when toggled
const SAVE_PATH := "user://crt_settings.cfg"

const CRT_PARAMS := {
	"shader_parameter/scanlines_thickness": 1.0,
	"shader_parameter/scanlines_opacity": 0.25,
	"shader_parameter/scanlines_interval": 3.0,
	"shader_parameter/curve_power": 1.0,
	"shader_parameter/wiggle": 0.0,
	"shader_parameter/smearing_strength": 0.2,
	"shader_parameter/enable_slotmask": true,
	"shader_parameter/enable_gridmask": false,
	"shader_parameter/mask_strength": 0.4,
	"shader_parameter/pixel_size": 3.0,
	"shader_parameter/grain_strength": 0.05,
	"shader_parameter/colored_grain": true,
}
const BLOOM_PARAMS := {
	"shader_parameter/bloom_threshold": 0.05,
	"shader_parameter/bloom_intensity": 0.7,
}
const BLURX_RADIUS := 4.0
const BLURY_RADIUS := 2.0
const DOWNSCALE := 3.0

var enabled: bool = false
var _crt: Node = null


func _ready() -> void:
	_crt = get_node_or_null("/root/flowerwall_crt")
	if _crt == null:
		push_warning("Flowerwall CRT singleton not found. Is the plugin enabled in Project Settings -> Plugins?")
		return

	_apply_params()
	enabled = _load_saved_state()
	_apply_enabled_state(enabled)


func set_crt_enabled(value: bool) -> void:
	if _crt == null:
		return
	enabled = value
	_apply_enabled_state(enabled)
	_save_state(enabled)


func _apply_params() -> void:
	for key in CRT_PARAMS:
		_crt.CRT_SHADER.set(key, CRT_PARAMS[key])
	for key in BLOOM_PARAMS:
		_crt.BLOOM_SHADER.set(key, BLOOM_PARAMS[key])
	_crt.BLURX_SHADER.set("shader_parameter/radius", BLURX_RADIUS)
	_crt.BLURY_SHADER.set("shader_parameter/radius", BLURY_RADIUS)
	_crt.current_scale = 1.0 / DOWNSCALE


func _apply_enabled_state(value: bool) -> void:
	_crt.is_enabled = value
	if value:
		_crt.get_viewport().scaling_3d_scale = _crt.current_scale
		_crt.should_enable_blur()
		_crt.should_enable_crt()
		_crt.should_enable_bloom()
	else:
		_crt.get_viewport().scaling_3d_scale = 1.0
		for n in _crt.get_children():
			n.visible = false


func _load_saved_state() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	return cfg.get_value("crt", "enabled", false)


func _save_state(value: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("crt", "enabled", value)
	cfg.save(SAVE_PATH)
