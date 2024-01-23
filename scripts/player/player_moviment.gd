extends CharacterBody2D
class_name Player

# Scripts filhos / Objetos filhos.
@export var animations: PlayerAnimations = null
@export var attacks: PlayerAttacks = null
@export var respawn: Respawn = null
@export var collision: CollisionShape2D = null

# Variáveis para gravidade
@export_category("Gravity")
@export var gravity: float = 250.0

# Variáveis para movimento
@export_category("Movement")
@export var speed: float = 80.0
@export var max_speed: float = 160.0

# Variáveis para pulo
@export_category("Jump")
@export var jump_timer: float = 0
@export var max_jump_timer: float = 0
@export var jump_force: float = 150

# Controller
@onready var controller: ControllerPlayer = get_parent()

# Condições para pulo.
var is_jumping: bool = false
var is_falling: bool = false
var can_jump: bool = false

# Variáveis para auxiliar verificações
var default_speed: float = speed
var direction: float = 1
var can_move: bool = true
var fire_pressed: bool = false
var can_throw: bool = true
var pushed: bool = false

# Variáveis de input. Passados pelo Controller
@onready var move_left: String = get_parent().left
@onready var move_right: String = get_parent().right
@onready var move_jump: String = get_parent().jump
@onready var move_fire: String = get_parent().fire

@onready var controller_number: int = get_parent().controller_number


# Physics, função de atualização a cada frame.
func _physics_process(delta) -> void:
	apply_gravity(delta)
	move(delta)
	move_and_slide()


# Aplicar gravidade.
func apply_gravity(delta) -> void:
	if is_jumping || !is_on_floor():
		velocity.y += (gravity * 3) * delta


# Função para a movimentação horizontal do player
func move(delta) -> void:
	if can_move :
		var mdirection: float = Input.get_axis(move_left, move_right)
		if mdirection != 0:
			direction = mdirection
		velocity.x = speed * mdirection
		check_fire_pressed()
		jump(delta)
		return
	elif pushed:
		return
	else:
		velocity.x = 0


# Função para os pulos do player
func jump(delta) -> void:
	if velocity.y > 0:
		can_jump = false
	
	if is_on_floor():
		jump_timer = 0.0
		is_jumping = false
		can_jump = true
	
	if Input.is_action_pressed(move_jump) && can_jump && (jump_timer < max_jump_timer):
		jump_timer += delta
		is_jumping = true
		velocity.y = -jump_force
	
	elif Input.is_action_just_released(move_jump) && is_jumping:
		is_jumping = false
		can_jump = false


# Função para checar quando o botão fire é pressionado e resolver as condições quando possível.
func check_fire_pressed() -> void:
	if Input.is_action_pressed(move_fire):
		fire_pressed = true
		if can_throw:
			attacks.throw_item()
			can_throw = false
		if is_on_floor():
			speed = max_speed
	elif Input.is_action_just_released(move_fire):
		can_throw = true
	else:
		if is_on_floor():
			speed = default_speed
		fire_pressed = false
