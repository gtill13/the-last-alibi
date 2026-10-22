extends RefCounted
class_name DebugLog

var enabled: bool = true

func log(message: String, level: String = "INFO") -> void:
    if not enabled:
        return
    var time: String = Time.get_datetime_string_from_system("%H:%M:%S")
    print("[%s] [%s] %s" % [time, level, message])

func warn(message: String) -> void:
    log(message, "WARN")

func error(message: String) -> void:
    log(message, "ERROR")
