from datetime import datetime

def log(message, level="INFO"):
    time = datetime.now().strftime("%H:%M:%S")
    print(f"[{level}] {time} - {message}")