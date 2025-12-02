from flask import Flask
import os
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

@app.route('/')
def hello():
    try:
        # Validate environment variables
        required_env = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"]
        for var in required_env:
            if var not in os.environ:
                return f"ERROR: Missing environment variable: {var}", 500

        # Attempt database connection
        conn = mysql.connector.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            database=os.environ['DB_NAME']
        )

        if not conn.is_connected():
            return "ERROR: Failed to connect to MySQL database.", 500

        cur = conn.cursor()

        # Execute query
        try:
            cur.execute("SELECT VERSION()")
            db_version = cur.fetchone()
        except Error as query_err:
            return f"ERROR running SQL query: {query_err}", 500

        cur.close()
        conn.close()

        hostname = os.environ.get('HOSTNAME') or os.uname()[1]
        return f"Hello from {hostname}! Database version: {db_version[0]}"

    except Error as db_err:
        return f"MySQL ERROR: {db_err}", 500

    except Exception as e:
        return f"Unexpected ERROR: {e}", 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
