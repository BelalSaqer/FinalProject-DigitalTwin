import json
import time
from pathlib import Path

import paho.mqtt.client as mqtt

BROKER = 'broker.hivemq.com'
PORT = 1883
TOPIC = 'ahmed/elhadyy/engine1'
DATA_FILE = Path(__file__).with_name('test_FD004.txt')

client = mqtt.Client()


def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print('✅ Connected to MQTT Broker!')
    else:
        print(f'❌ Failed to connect, return code {rc}')


client.on_connect = on_connect
client.connect(BROKER, PORT, 60)
client.loop_start()

try:
    with DATA_FILE.open('r', encoding='utf-8') as f:
        lines = f.readlines()

    print('🚀 Starting Engine 1 Simulation...')

    for line in lines:
        values = line.strip().split()
        if not values:
            continue

        engine_id = int(values[0])
        cycle = int(values[1])

        # if engine_id != 5:
        #     continue

        payload = {
            "setting_1": float(values[2]),
            "setting_2": float(values[3]),
            "s_2": float(values[6]),
            "s_3": float(values[7]),
            "s_4": float(values[8]),
            "s_7": float(values[11]),
            "s_8": float(values[12]),
            "s_9": float(values[13]),
            "s_11": float(values[15]),
            "s_12": float(values[16]),
            "s_13": float(values[17]),
            "s_14": float(values[18]),
            "s_15": float(values[19]),
            "s_17": float(values[21]),
            "s_20": float(values[24]),
            "s_21": float(values[25]),    
        }

        client.publish(TOPIC, json.dumps(payload))
        print(f'📡 Sent data for Engine 1 (Cycle {cycle})')
        time.sleep(0.1)

except FileNotFoundError:
    print('❌ Error: test_FD004.txt not found!')
except Exception as exc:
    print(f'❌ An error occurred: {exc}')
finally:
    client.loop_stop()
    client.disconnect()
    print('🏁 Simulation finished.')
