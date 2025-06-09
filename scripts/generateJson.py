import json
import random
import string
from datetime import datetime, timedelta

def random_string(length=10):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def random_date(start, end):
    return start + timedelta(seconds=random.randint(0, int((end - start).total_seconds())))

def random_entry():
    return {
        "id": random.randint(1, 10**9),
        "name": random_string(12),
        "email": f"{random_string(7)}@{random_string(5)}.com",
        "age": random.randint(18, 90),
        "registered_on": random_date(datetime(2000, 1, 1), datetime(2025, 1, 1)).isoformat(),
        "is_active": random.choice([True, False]),
        "preferences": {
            "newsletter": random.choice([True, False]),
            "notifications": random.choice(["email", "sms", "push", "none"]),
            "theme": random.choice(["dark", "light"])
        },
        "tags": [random_string(5) for _ in range(random.randint(1, 5))],
        "address": {
            "street": random_string(15),
            "city": random_string(10),
            "zip": random.randint(10000, 99999)
        }
    }

def generate_json_file(filename, num_entries):
    data = [random_entry() for _ in range(num_entries)]
    with open(filename, 'w') as f:
        json.dump(data, f, separators=(',', ':'))
    print(f"Generated {num_entries} entries in {filename}")

if __name__ == "__main__":
    generate_json_file("large_data.json", 2000)  # You can adjust the number here
