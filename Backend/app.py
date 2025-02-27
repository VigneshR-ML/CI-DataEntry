from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import csv,os


app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://soorya:soorya41080@localhost/bus_management'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
socketio = SocketIO(app, cors_allowed_origins="*")  

# -------------------------
# Database Models
# -------------------------
class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.Date, nullable=False)  
    
class DataEntry(db.Model):
    __tablename__ = 'data_entries'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete="CASCADE"), nullable=False)
    bus_no = db.Column(db.Integer, nullable=False)
    
    arrival_time = db.Column(db.Time, nullable=False)
    arrival_place = db.Column(db.String(100), nullable=False)
    departure_place = db.Column(db.String(100), nullable=False)
    checking_place = db.Column(db.String(100), nullable=False)
    checking_time = db.Column(db.Time, nullable=False)
    total_passengers = db.Column(db.Integer, nullable=False)
    free_passengers = db.Column(db.Integer, nullable=False)
    after_checking_place = db.Column(db.String(100), nullable=False)
    after_checking_time = db.Column(db.Time, nullable=False)
    case_details = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# -------------------------
# API Endpoints
# -------------------------
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password_str = data.get('password')
    password_date = datetime.strptime(password_str, '%Y-%m-%d').date()
    user = User.query.filter_by(username=username, password=password_date).first()
    if user:
        return jsonify({'message': 'Login successful', 'user_id': user.user_id}), 200
    else:
        return jsonify({'message': 'Invalid credentials.'}), 401

@app.route('/data-entry', methods=['POST'])
def add_data_entry():
    data = request.json
    user_id = data.get('user_id')
    if not user_id:
        return jsonify({'message': 'User ID required'}), 400

    try:
        new_entry = DataEntry(
            user_id=user_id,
            bus_no=data['bus_no'],
            arrival_time=datetime.strptime(data['arrival_time'], '%H:%M').time(),
            arrival_place=data['arrival_place'],
            departure_place=data['departure_place'],
            checking_place=data['checking_place'],
            checking_time=datetime.strptime(data['checking_time'], '%H:%M').time(),
            total_passengers=data['total_passengers'],
            free_passengers=data['free_passengers'],
            after_checking_place=data['after_checking_place'],
            after_checking_time=datetime.strptime(data['after_checking_time'], '%H:%M').time(),
            case_details=data['case_details']
        )
        db.session.add(new_entry)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Failed to add data entry', 'error': str(e)}), 500

    # Emit a real-time update event to all connected clients
    socketio.emit('new_data_entry', {
        'id': new_entry.id,
        'user_id': new_entry.user_id,
        'bus_no': new_entry.bus_no,
        'arrival_time': new_entry.arrival_time.strftime('%H:%M'),
        'arrival_place': new_entry.arrival_place,
        'departure_place': new_entry.departure_place,
        'checking_place': new_entry.checking_place,
        'checking_time': new_entry.checking_time.strftime('%H:%M'),
        'total_passengers': new_entry.total_passengers,
        'free_passengers': new_entry.free_passengers,
        'after_checking_place': new_entry.after_checking_place,
        'after_checking_time': new_entry.after_checking_time.strftime('%H:%M'),
        'case_details': new_entry.case_details,
        'created_at': new_entry.created_at.strftime('%Y-%m-%d %H:%M:%S')
    })

    return jsonify({'message': 'Data entry added successfully'}), 201


places = []
csv_file = 'Backend/places.csv'
with open(csv_file, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        row['PLCODE'] = row['PLCODE'].strip()
        row['PLACE1'] = row['PLACE1'].strip()
        places.append(row)

@app.route('/places')
def get_places():
    query = request.args.get('query', '').strip()
    if not query:
        return jsonify([])

    suggestions = [row['PLACE1'] for row in places if row['PLCODE'].startswith(query)]
    return jsonify(suggestions)

# -------------------------
# SocketIO Events
# -------------------------
@socketio.on('connect')
def handle_connect():
    print('Client connected')
    emit('message', {'data': 'Connected to server'})

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')


# -------------------------
# Create DB Tables and Run Server
# -------------------------
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    socketio.run(app, host="0.0.0.0", port=5000, debug=True)

