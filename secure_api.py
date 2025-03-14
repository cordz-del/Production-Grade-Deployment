# secure_api.py
from flask import Flask, request, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_talisman import Talisman
import jwt
import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_jwt_secret_key'

# Set up rate limiting (e.g., 100 requests per hour)
limiter = Limiter(app, key_func=get_remote_address, default_limits=["100 per hour"])

# Secure headers using Flask-Talisman
Talisman(app, content_security_policy=None)

def token_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'error': 'Token is missing!'}), 401
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        except Exception as e:
            return jsonify({'error': 'Token is invalid!'}), 403
        return f(*args, **kwargs)
    return decorated

@app.route('/api/secure-data', methods=['GET'])
@limiter.limit("10 per minute")
@token_required
def secure_data():
    return jsonify({"data": "This is protected data"})

@app.route('/api/login', methods=['POST'])
def login():
    auth = request.json
    if not auth or not auth.get('username') or not auth.get('password'):
        return jsonify({'error': 'Missing credentials'}), 400
    # In production, verify username and password from database
    token = jwt.encode({
        'user': auth.get('username'),
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    }, app.config['SECRET_KEY'], algorithm="HS256")
    return jsonify({'token': token})

if __name__ == '__main__':
    app.run(debug=True)
