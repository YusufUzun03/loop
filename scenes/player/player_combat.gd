class_name PlayerCombat
extends Node
## Basic attack and parry rules for melee characters.
##
## Attack (Memo, decided):
##   tap left click   -> light attack
##   hold left click  -> charge, release -> heavy attack
##   a dodge cancels the attack at any moment
##
## Parry (Memo, decided): attack into an enemy attack while facing it.
##   light: press attack at most `parry_window` before the enemy hit lands
##   heavy: the heavy strike must land at the same moment as the enemy hit
##          (`heavy_parry_tolerance`, about 2 frames)
##   A parrying swing deals no damage. A parry opens the skill bonus window.
##
## This node only keeps time and rules; the Player moves the body and the
## hitbox deals the damage. That keeps every rule testable without physics.

signal attack_started(kind: Kind)
## The swing reaches its target: the moment the weapon lands.
signal strike_landed(kind: Kind)
## The swing is decided: `deals_damage` is false when this swing parried.
signal strike_resolved(kind: Kind, deals_damage: bool)
signal parried(kind: Kind)

enum Kind { LIGHT, HEAVY }
enum Phase { IDLE, CHARGING, WINDUP, ACTIVE, RECOVERY }

@export_group("Attack")
## Holding the button at least this long turns the attack into a heavy one.
@export var heavy_hold_time: float = 0.3
@export var light_windup: float = 0.1
@export var light_active: float = 0.1
@export var light_recovery: float = 0.2
## Wind-up after releasing a charged heavy attack.
@export var heavy_windup: float = 0.15
@export var heavy_active: float = 0.12
@export var heavy_recovery: float = 0.4
## Walking speed while attacking, as a share of normal speed.
@export_range(0.0, 1.0) var attack_move_multiplier: float = 0.35
@export var light_damage: int = 10
@export var heavy_damage: int = 25

@export_group("Parry")
## Light attack: press at most this long before the enemy hit lands.
@export var parry_window: float = 0.1
## Heavy attack: how close (seconds) the strike and the enemy hit must be.
## 0.035 covers 2 physics frames at 60 per second (Memo: about 2 frames).
@export var heavy_parry_tolerance: float = 0.035
## You must face the attacker: max angle between facing and the attacker.
@export_range(0.0, 180.0) var parry_facing_angle_degrees: float = 60.0
## How long skills get the parry bonus (GDD). Skills come later.
@export var parry_bonus_duration: float = 2.0

@export_group("Input buffer")
## An attack pressed this close to the end of the current one still happens.
@export var input_buffer: float = 0.1

var phase: Phase = Phase.IDLE
var kind: Kind = Kind.LIGHT

var _time: float = 0.0
var _phase_time_left: float = 0.0
var _charge_time: float = 0.0
var _press_time: float = -INF
var _strike_time: float = -INF
var _resolve_time: float = INF
var _resolved: bool = true
var _parried_this_swing: bool = false
var _buffered_press_time: float = -INF
var _bonus_time_left: float = 0.0


func is_busy() -> bool:
	return phase != Phase.IDLE


func is_bonus_active() -> bool:
	return _bonus_time_left > 0.0


func get_move_multiplier() -> float:
	return attack_move_multiplier if is_busy() else 1.0


## True while holding long enough that releasing gives a heavy attack.
func is_charged() -> bool:
	return phase == Phase.CHARGING and _charge_time >= heavy_hold_time


func get_damage() -> int:
	return heavy_damage if kind == Kind.HEAVY else light_damage


## The attack button went down.
func press_attack() -> void:
	if is_busy():
		_buffered_press_time = _time
		return
	phase = Phase.CHARGING
	kind = Kind.LIGHT
	_charge_time = 0.0
	_press_time = _time
	_parried_this_swing = false
	_resolved = false
	_resolve_time = INF


## The attack button came up.
func release_attack() -> void:
	if phase != Phase.CHARGING:
		return
	kind = Kind.HEAVY if _charge_time >= heavy_hold_time else Kind.LIGHT
	_enter(Phase.WINDUP)
	attack_started.emit(kind)


## Stops the attack right away (a dodge does this). A cancelled swing never
## lands and never deals damage.
func cancel() -> void:
	phase = Phase.IDLE
	_resolved = true
	_resolve_time = INF


## Advances time by one physics step.
func tick(delta: float) -> void:
	_time += delta
	_bonus_time_left = maxf(_bonus_time_left - delta, 0.0)

	if phase == Phase.CHARGING:
		_charge_time += delta
	elif phase != Phase.IDLE:
		_phase_time_left -= delta
		if _phase_time_left <= 0.0:
			_advance_phase()

	# Damage waits a moment after the strike lands, so a heavy strike that
	# parries in that moment can still be stopped from dealing damage.
	if not _resolved and _time > _resolve_time:
		_resolved = true
		strike_resolved.emit(kind, not _parried_this_swing)

	if phase == Phase.IDLE and _time - _buffered_press_time <= input_buffer:
		_buffered_press_time = -INF
		press_attack()


## Called when an enemy hit lands on the player. `to_attacker` points from
## the player to the attacker. Returns true if the hit was parried.
func try_parry(to_attacker: Vector3, facing: Vector3) -> bool:
	if not _is_facing(to_attacker, facing):
		return false
	var light_ok := (
		kind == Kind.LIGHT
		and phase != Phase.IDLE
		and _time - _press_time >= 0.0
		and _time - _press_time <= parry_window
	)
	var heavy_ok := (
		kind == Kind.HEAVY
		and _time - _strike_time >= 0.0
		and _time - _strike_time <= heavy_parry_tolerance
	)
	if not (light_ok or heavy_ok):
		return false
	_parried_this_swing = true
	_bonus_time_left = parry_bonus_duration
	parried.emit(kind)
	return true


func _is_facing(to_attacker: Vector3, facing: Vector3) -> bool:
	var flat_to := Vector3(to_attacker.x, 0.0, to_attacker.z)
	var flat_facing := Vector3(facing.x, 0.0, facing.z)
	if flat_to.is_zero_approx() or flat_facing.is_zero_approx():
		return false
	var angle := rad_to_deg(flat_facing.angle_to(flat_to))
	return angle <= parry_facing_angle_degrees


func _advance_phase() -> void:
	match phase:
		Phase.WINDUP:
			_enter(Phase.ACTIVE)
			_strike_time = _time
			_resolve_time = _time + heavy_parry_tolerance
			strike_landed.emit(kind)
		Phase.ACTIVE:
			_enter(Phase.RECOVERY)
		Phase.RECOVERY:
			phase = Phase.IDLE


func _enter(next: Phase) -> void:
	phase = next
	var light := kind == Kind.LIGHT
	match next:
		Phase.WINDUP:
			_phase_time_left = light_windup if light else heavy_windup
		Phase.ACTIVE:
			_phase_time_left = light_active if light else heavy_active
		Phase.RECOVERY:
			_phase_time_left = light_recovery if light else heavy_recovery
