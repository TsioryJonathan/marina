import os
import subprocess
from flask import Flask, request, jsonify

app = Flask(__name__)
MARINA_BIN = "/usr/local/bin/marina"


@app.route("/")
def index():
    return "marina is up. Try /solve?prop=<proposition>\n"


@app.route("/solve")
def solve():
    prop = request.args.get("prop")
    if not prop:
        return jsonify(error="missing 'prop' query parameter"), 400

    try:
        result = subprocess.run(
            [MARINA_BIN, prop], capture_output=True, text=True, timeout=5
        )
    except subprocess.TimeoutExpired:
        return jsonify(error="solver timed out"), 504

    if result.returncode != 0:
        return jsonify(error=result.stderr.strip()), 400

    return jsonify(result=result.stdout.strip())


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
