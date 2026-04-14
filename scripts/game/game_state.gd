extends Node

# ── Phase ─────────────────────────────────────────────────────────────────────

enum Phase { DUNGEON, FINAL_BATTLE }
var phase: Phase = Phase.DUNGEON

# ── Match timer ───────────────────────────────────────────────────────────────

const MATCH_DURATION := 60.0          # seconds before final battle begins
var time_remaining: float = MATCH_DURATION

signal timer_tick(seconds_left: int)  # emitted each whole-second change
signal timer_expired                  # emitted once when time hits 0

# ── Player stats (survive scene transitions) ──────────────────────────────────

var p1_health:      int = 5
var p1_max_health:  int = 5
var p1_kills:       int = 0
var p2_health:      int = 5
var p2_max_health:  int = 5
var p2_kills:       int = 0

# ── Grace period ──────────────────────────────────────────────────────────────

const GRACE_DURATION := 3.0           # countdown length in seconds

var is_grace: bool = true             # true while countdown is running

signal grace_tick(seconds_left: int)  # emits 3, 2, 1 — drives HUD countdown
signal grace_ended                    # un-stuns players and enemies
signal grace_cleared                  # "BEGIN!" has shown; clear the HUD label

# ── Timer logic (driven by the active game scene) ─────────────────────────────

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
# Call this at the start of any phase that needs a freeze countdown.
# Drives the 3-2-1 countdown, then emits grace_ended (un-stuns everything),
# then after a short pause emits grace_cleared (HUD wipes the "BEGIN!" label).

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
	p2_health     = p2.health
	p2_max_health = p2.max_health
	p2_kills      = p2.kills
