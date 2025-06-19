
from flask import Flask, session
from flask_session import Session
import redis

app = Flask(__name__)
app.secret_key = 'super-secret-key'
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.Redis(host='localhost', port=6379)
Session(app)

@app.route('/')
def index():
    session['visits'] = session.get('visits', 0) + 1
    return f"Visit #: {session['visits']} (Session stored in Redis)"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
