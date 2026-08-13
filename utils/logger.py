from datetime import datetime


def log(
    message: str,
    level: str = "INFO",
) -> None:

    time = datetime.now().strftime(
        "%H:%M:%S"
    )

    print(
        f"[{level}] {time} - {message}"
    )