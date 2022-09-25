import re


def check_email(email: str) -> bool:
    regex = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)"
    return bool(re.search(regex, email))


def check_username(name: str) -> bool:
    return bool(re.search('^[a-zA-Z]+$', name))

def check_phone(phone: str) -> bool:
    return bool(re.match('\\+[0-9]{10,12}$', phone))
