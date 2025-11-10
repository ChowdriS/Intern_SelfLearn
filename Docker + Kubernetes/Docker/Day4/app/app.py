from flask import Flask
import os
import mysql.connector

app = Flask(__name__)

@app.route('/')
def hello():
    conn = mysql.connector.connect(
        host="db",
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
        database=os.environ['DB_NAME']
    )
    cur = conn.cursor()
    cur.execute('SELECT VERSION()')
    db_version = cur.fetchone()
    cur.close()
    conn.close()
    hostname = os.environ.get('HOSTNAME') or os.uname()[1]
    return f'Hello from {hostname}! Database version: {db_version[0]}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
