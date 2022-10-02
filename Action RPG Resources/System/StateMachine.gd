extends Node

class_name StateMatchine

const NoticeBoard = preload("res://Action RPG Resources/asset/NoticeBoard.tscn")

var m_Owner
var m_CurrentState : StateTemp
var currentState : StateTemp setget _set_CurrentState, _get_CurrentState
var m_PreviousState : StateTemp
var previousState : StateTemp setget _set_PreviousState, _get_PreviousState
var m_GlobalState : StateTemp
var globalState setget _set_GlobalState, _get_GlobalState


func _set_CurrentState(value : StateTemp):
	m_CurrentState = value

func _get_CurrentState():
	return m_CurrentState
	
func _set_PreviousState(value : StateTemp):
	m_PreviousState = value

func _get_PreviousState():
	return m_PreviousState
	
func _set_GlobalState(value : StateTemp):
	m_GlobalState = value

func _get_GlobalState():
	return m_GlobalState

func _init(owner):
	m_Owner = owner
	m_CurrentState = NullState.new()
	m_PreviousState = NullState.new()
	m_GlobalState = NullState.new()
	
func Update():
#	m_GlobalState.Execute(m_Owner)
	m_CurrentState._execute(m_Owner)

func ChangeState(newState : StateTemp):
	m_PreviousState = m_CurrentState
	m_CurrentState._exit(m_Owner)
	m_CurrentState = newState
	m_CurrentState._enter(m_Owner)
	
func RevertToPreviousState():
	ChangeState(m_PreviousState)
	
class NullState extends StateTemp:
	func _enter(m_Owner):
		pass
		
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
		pass

