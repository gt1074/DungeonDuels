extends Node

# ── Phase ─────────────────────────────────────────────────────────────────────

enum Phase { DUNGEON, FINAL_BATTLE }
var phase: Phase = Phase.DUNGEON

# ── Match timer ───────────────────────────────────────────────────────────────

const MATCH_DURATION := 63.0
var time_remaining: float = MATCH_DURATION

signal timer_tick(seconds_left: int)
signal timer_expired

# ── Player stats (survive scene transitions) ──────────────────────────────────

var p1_health:      int = 5
var p1_max_health:  int = 5
var p1_kills:       int = 0
var p1_speed:       float = 75.0
var p2_health:      int = 5
var p2_max_health:  int = 5
var p2_kills:       int = 0
var p2_speed:       float = 75.0

# ── Upgrade stats (weapon + shield + bullet mode) ─────────────────────────────

var p1_fire_rate:               float = 0.3
var p1_bullet_mode:             String = ""
var p1_shield_max_health:       int   = 10
var p1_shield_cooldown_time:    float = 2.2
var p1_shield_recharge_interval:float = 0.3
var p1_shield_recharge_delay:   float = 0.5

var p2_fire_rate:               float = 0.3
var p2_bullet_mode:             String = ""
var p2_shield_max_health:       int   = 10
var p2_shield_cooldown_time:    float = 2.2
var p2_shield_recharge_interval:float = 0.3
var p2_shield_recharge_delay:   float = 0.5

# ── Opponent event ticker ─────────────────────────────────────────────────────
# Emitted by either RoomManager when something noteworthy happens.
# from_prefix: "" for P1, "p2_" for P2. The HUD shows it on the OTHER side.
signal opponent_event(from_prefix: String, message: String)

func notify_opponent(from_prefix: String, message: String) -> void:
	opponent_event.emit(from_prefix, message)

# ── Grace period ──────────────────────────────────────────────────────────────

const GRACE_DURATION := 3.0
var is_grace: bool = true

signal grace_tick(seconds_left: int)
signal grace_ended
signal grace_cleared

# ── Timer logic ───────────────────────────────────────────────────────────────

var _timer_active := false
var _last_whole_second: int = -1

func start_match_timer() -> void:
	time_remaining = MATCH_DURATION
	_last_whole_second = int(ceil(time_remaining))
	_timer_active = true

func tick(delta: float) -> void:
	if not _timer_active or phase == Phase.FINAL_BATTLE:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_timer_active = false
		timer_expired.emit()
		return
	var whole := int(ceil(time_remaining))
	if whole != _last_whole_second:
		_last_whole_second = whole
		timer_tick.emit(whole)

# ── Grace period logic ────────────────────────────────────────────────────────

func start_grace_period() -> void:
	is_grace = true
	_run_grace_countdown()

func _run_grace_countdown() -> void:
	for i in range(int(GRACE_DURATION), 0, -1):
		grace_tick.emit(i)
		await get_tree().create_timer(1.0).timeout
	is_grace = false
	grace_ended.emit()
	await get_tree().create_timer(1.2).timeout
	grace_cleared.emit()

# ── Player stat persistence ───────────────────────────────────────────────────

func save_player_stats(p1: CharacterBody2D, p2: CharacterBody2D) -> void:
	p1_health     = p1.health
	p1_max_health = p1.max_health
	p1_kills      = p1.kills
	p1_speed      = p1.speed
	p2_health     = p2.health
	p2_max_health = p2.max_health
	p2_kills      = p2.kills
	p2_speed      = p2.speed

	if p1.current_weapon != null:
		p1_fire_rate   = p1.current_weapon.fire_rate
		p1_bullet_mode = p1.current_weapon.bullet_mode if "bullet_mode" in p1.current_weapon else ""
	if p2.current_weapon != null:
		p2_fire_rate   = p2.current_weapon.fire_rate
		p2_bullet_mode = p2.current_weapon.bullet_mode if "bullet_mode" in p2.current_weapon else ""

	var s1: Shield = p1.get_node_or_null("Shield")
	if s1 != null:
		p1_shield_max_health        = s1.MAX_HEALTH
		p1_shield_cooldown_time     = s1.cooldown_time
		p1_shield_recharge_interval = s1.recharge_interval
		p1_shield_recharge_delay    = s1.recharge_delay

	var s2: Shield = p2.get_node_or_null("Shield")
	if s2 != null:
		p2_shield_max_health        = s2.MAX_HEALTH
		p2_shield_cooldown_time     = s2.cooldown_time
		p2_shield_recharge_interval = s2.recharge_interval
		p2_shield_recharge_delay    = s2.recharge_delay
