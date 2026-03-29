import os
from flask import Flask, render_template, request, jsonify
import anthropic

app = Flask(__name__)
client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

SYSTEM_PROMPT = """You are an expert at analyzing meeting minutes.
Extract and return a structured summary with exactly two sections:
1. Key Decisions - bullet list of decisions made during the meeting
2. Action Items - bullet list of tasks, each with the responsible person if mentioned

Be concise and clear. Use plain language."""

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/summarize", methods=["POST"])
def summarize():
    if "file" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["file"]
    if not file.filename.endswith(".txt"):
        return jsonify({"error": "Only .txt files are supported"}), 400

    content = file.read().decode("utf-8").strip()
    if not content:
        return jsonify({"error": "File is empty"}), 400

    message = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=1024,
        system=SYSTEM_PROMPT,
        messages=[
            {"role": "user", "content": f"Please summarize these meeting minutes:\n\n{content}"}
        ]
    )

    return jsonify({"summary": message.content[0].text})

if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0", port=5000)
