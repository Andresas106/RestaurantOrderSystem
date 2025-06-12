import firebase_admin
from firebase_admin import credentials, firestore
import random
import csv
from datetime import datetime, timedelta

# Inicializa Firebase (ajusta el path a tu archivo de credenciales)
cred = credentials.Certificate("restaurantsystem-911b3-firebase-adminsdk-7a182-7aa1b39807.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Carga los platos desde la colección 'dishes'
def cargar_dishes():
    dishes_ref = db.collection('dishes')
    docs = dishes_ref.stream()
    platos = []
    for doc in docs:
        data = doc.to_dict()
        platos.append({
            'id': data['id'],
            'name': data['name'],
            'prepTime': data['totalTime']
        })
    return platos

# Simula un número de pedidos
def simular_pedidos(platos, num_pedidos=1000):
    pedidos = []
    for i in range(num_pedidos):
        num_platos = random.randint(1, 5)
        platos_seleccionados = random.sample(platos, num_platos)

        dish_ids = []
        dish_names = []
        prep_times = []
        quantities = []

        for plato in platos_seleccionados:
            cantidad = random.randint(1, 3)
            dish_ids.append(plato['id'])
            dish_names.append(plato['name'])
            prep_times.append(plato['prepTime'])
            quantities.append(cantidad)

        # Añadir un poco de aleatoriedad (simula retrasos o eficiencia)
        max_prep_time = max(prep_times)
        extra_time = random.randint(3, 10)
        total_time = max_prep_time + extra_time

        pedidos.append({
            'order_id': i + 1,
            'datetime': (datetime.now() - timedelta(days=random.randint(0, 30))).strftime("%Y-%m-%d %H:%M"),
            'dish_ids': dish_ids,
            'dish_names': dish_names,
            'prep_times': prep_times,
            'quantities': quantities,
            'total_time': total_time
        })

    return pedidos

# Guarda los pedidos simulados en un archivo CSV
def guardar_en_csv(pedidos, nombre_archivo='simulated_orders.csv'):
    with open(nombre_archivo, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['order_id', 'datetime', 'dish_ids', 'dish_names', 'prep_times', 'quantities', 'total_time'])
        writer.writeheader()
        for pedido in pedidos:
            writer.writerow(pedido)
    print(f"✅ {len(pedidos)} pedidos guardados en {nombre_archivo}")

# MAIN
if __name__ == "__main__":
    platos = cargar_dishes()
    pedidos_simulados = simular_pedidos(platos, num_pedidos=1000)
    guardar_en_csv(pedidos_simulados)
