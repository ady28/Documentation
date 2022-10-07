#!/usr/bin/env python3

import json, os
from flask import Flask, jsonify
app = Flask(__name__)

env = os.environ.get("PYTHON_ENV")

@app.route('/')
def index():
    return jsonify({'success': True,
                    'data': 'Hello'})
@app.route('/greet/<user>')
def greet(user):
    return jsonify({'success': True,
                    'data': f"Hello {user}!"})
            

if __name__ == "__main__":
    if env == "prod":
        from waitress import serve
        serve(app, host="0.0.0.0", port=8080)
    else:
        app.run(debug=True)