extends Area2D


#extends KinematicBody2D

var velocity = Vector2.ZERO
const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500
#var speed = 3

#_ready()と同じタイミングで実行してくれる変数
onready var animationPlayer = $AnimationPlayer
#$を使うことで、子ノードの機能のパスを入れることができる。

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

#---------z軸ジャンプ変数------------
#export (int) var shadow_offset
#export (int) var body_offset

var z            = 0           # 最終的にY座標に足し引きする値、Z座標（高さ） 
var z_floor      = 0           # Z座標の０地点（地面の高さ） 
var z_speed      = 4           # ジャンプ上昇時の勢い
var z_grav       = 0           # ジャンプ下降時の勢い 
var grav_rate    = 0.25        # ジャンプ下降時の勢いに加算する値
var jump         = false       # ジャンプ状態かどうか判定するbool値
#---------------------

func _ready():#Sceneが全て実体化(インスタンス化)が終わってから実行
	pass

func _physics_process(delta):#設定された秒数ごとに一定間隔で呼び出される関数。unityのrun()

	var input_vector = Vector2.ZERO
	input_vector.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	input_vector.y = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
#	velocity = move_and_slide(velocity)# * delta
	#移動処理
	position += input_vector
	
	# 影の位置を調整
	$Shadow.global_position.y = global_position.y + 10
	
	#ーーーーーーージャンプ機構ーーーーーーーーー
	# スペースキーを押してジャンプ状態になる
	if Input.is_action_just_pressed("ui_select"):  
		if z <= z_floor: 
			jump = true 
	
	# ジャンプ状態である間、Z座標にz_speedの値を加算
	if jump == true: 
		z += z_speed 
	
	# Z座標が地面の高さより大きい（空中にいる）場合は少しずつ下降する力が増えていく
	if z >= z_floor: 
		z -= z_grav * 0.9
		z_grav = z_grav + grav_rate 
	
	# Z座標が地面の高さより小さい（地上にいる）場合はジャンプ状態を終了する
	if z <= z_floor + 1: 
		z = z_floor 
		z_grav = 0 
		jump = false 

	# ジャンプに合わせてプレイヤーの画像と当たり判定を動かす 
	$PlayerIcon.global_position.y = global_position.y - z 
	$CollisionShape2D.global_position.y = global_position.y - z + 10 
	

