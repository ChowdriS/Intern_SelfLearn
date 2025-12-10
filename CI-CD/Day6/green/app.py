from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "<h1 style='color:green'>GREEN VERSION</h1>"

app.run(host="0.0.0.0", port=5001)
