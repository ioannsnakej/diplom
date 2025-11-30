import psycopg2
import os

def get_env_or_raise(name: str) -> str:
    val = os.getenv(name)
    if not val:
        raise RuntimeError(f"Required environment variable {name} is not set")
    return val

def get_connection():
    host = os.getenv('DB_HOST', 'db')  # default для docker-compose
    dbname = get_env_or_raise('DB_NAME')
    user = get_env_or_raise('DB_USER')
    password = get_env_or_raise('DB_PASS')

    return psycopg2.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password
    )
