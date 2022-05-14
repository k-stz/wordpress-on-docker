from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>My awesome Timer App!</h1>'


app.run(debug=True, host='0.0.0.0') 

print("\U0001f600")
print("N\{grinning_face}")
