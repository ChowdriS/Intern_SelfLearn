from flask import Flask, jsonify, render_template
import pymysql
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')  # serve your HTML page

@app.route('/get-time')
def get_time():
    try:
        conn = pymysql.connect(
            host=os.getenv('DB_ENDPOINT'),
            user=os.getenv('DB_USERNAME'),
            password=os.getenv('DB_PASSWORD'),
            database='appdb'
        )
        with conn.cursor() as cursor:
            cursor.execute("SELECT NOW()")
            result = cursor.fetchone()
        conn.close()
        return jsonify({"status": "success", "time": str(result[0])})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
