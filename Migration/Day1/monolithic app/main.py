from flask import Flask
import os
import sqlite3

app = Flask(__name__)
DB_PATH = "app.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS meta (id INTEGER PRIMARY KEY, version TEXT)")
    
    cur.execute("SELECT COUNT(*) FROM meta")
    if cur.fetchone()[0] == 0:
        cur.execute("INSERT INTO meta (version) VALUES (?)", ("1.0",))
    
    conn.commit()
    cur.close()
    conn.close()

@app.route('/')
def hello():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute("SELECT version FROM meta LIMIT 1")
    db_version = cur.fetchone()[0]
    cur.close()
    conn.close()

    hostname = os.environ.get('HOSTNAME') or os.uname().nodename
    return f"Hello from {hostname}! Database version: {db_version}"

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=80)
