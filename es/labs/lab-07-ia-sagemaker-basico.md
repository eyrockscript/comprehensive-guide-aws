# Laboratorio 07: IA/ML con SageMaker

## 🎯 Objetivo del Laboratorio

Crear un notebook en Amazon SageMaker, entrenar un modelo de machine learning simple y desplegarlo como endpoint para realizar predicciones en tiempo real.

**Tiempo estimado:** 90 minutos  
**Nivel:** Intermedio  
**Costo:** Dentro del Free Tier (SageMaker incluye 250 horas de instancia ml.t2.medium/m5.large/m5.xlarge para notebooks)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS configurada)
- Conocimientos básicos de Python
- Familiaridad con conceptos de machine learning (datasets, entrenamiento, predicción)

---

## 🚀 Paso 1: Crear un Notebook Instance

### 1.1 Acceder al Servicio SageMaker

1. Inicia sesión en la Consola de AWS
2. En la barra de búsqueda, escribe "SageMaker"
3. Selecciona "Amazon SageMaker"
4. Asegúrate de estar en la región **us-east-1** (N. Virginia)

### 1.2 Crear Notebook Instance

1. En el menú lateral izquierdo, ve a "Notebooks" → "Notebook instances"
2. Clic en "Create notebook instance"
3. Configura:

**Notebook instance settings:**
```
Notebook instance name: lab-sagemaker-notebook
Notebook instance type: ml.t2.medium (recomendado para desarrollo)
Platform identifier: Amazon Linux 2, Jupyter Lab 3
```

**Permissions and encryption:**
```
IAM role: Create a new role
   - Selecciona: "Any S3 bucket" (para permitir acceso a datos)
   - Clic en "Create role"
```

**Network:**
```
VPC: Default
Subnet: No preference
Security group: Default
```

**Git repositories:**
```
Repository: None (crearemos los archivos manualmente)
```

4. Clic en "Create notebook instance"
5. Espera unos minutos hasta que el estado cambie a "In service"

---

## 📝 Paso 2: Preparar el Dataset

### 2.1 Abrir JupyterLab

1. Una vez que el notebook esté "In service", haz clic en "Open JupyterLab"
2. Se abrirá la interfaz de JupyterLab en una nueva pestaña

### 2.2 Crear el Archivo de Dataset

1. En el panel izquierdo, haz clic derecho en el área de archivos
2. Selecciona "New Folder" y nombra: `lab-ml-project`
3. Haz doble clic para entrar a la carpeta
4. Crea un archivo Python: "New" → "File" → nombra `prepare_data.py`

5. Pega el siguiente código:

```python
import pandas as pd
import numpy as np
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
import os

# Crear directorio para datos
os.makedirs('data', exist_ok=True)

# Cargar dataset Iris
iris = load_iris()
X = pd.DataFrame(iris.data, columns=iris.feature_names)
y = pd.Series(iris.target, name='species')

# Combinar features y target
df = pd.concat([X, y], axis=1)

# Agregar nombres de especies
species_map = {0: 'setosa', 1: 'versicolor', 2: 'virginica'}
df['species_name'] = df['species'].map(species_map)

# Dividir en train y test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Guardar datasets
train_df = pd.concat([X_train, y_train], axis=1)
test_df = pd.concat([X_test, y_test], axis=1)

train_df.to_csv('data/train.csv', index=False)
test_df.to_csv('data/test.csv', index=False)
full_df = df.copy()
full_df.to_csv('data/iris_full.csv', index=False)

print("Dataset preparado exitosamente!")
print(f"\nTotal de muestras: {len(df)}")
print(f"Muestras de entrenamiento: {len(train_df)}")
print(f"Muestras de prueba: {len(test_df)}")
print(f"\nPrimeras filas:")
print(df.head())
print(f"\nDistribución de clases:")
print(df['species_name'].value_counts())
```

6. Guarda el archivo (Ctrl+S)
7. Abre un terminal: "File" → "New" → "Terminal"
8. Ejecuta: `cd lab-ml-project && python prepare_data.py`

---

## 🤖 Paso 3: Entrenar Modelo con scikit-learn

### 3.1 Crear Notebook de Entrenamiento

1. En JupyterLab, ve a "File" → "New" → "Notebook"
2. Selecciona kernel "Python 3"
3. Guarda como `train_model.ipynb`

### 3.2 Código del Notebook de Entrenamiento

Copia y pega cada celda:

**Celda 1: Imports**
```python
import pandas as pd
import numpy as np
import joblib
import os
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns

print("Imports completados")
```

**Celda 2: Cargar Datos**
```python
# Cargar datos de entrenamiento y prueba
train_df = pd.read_csv('data/train.csv')
test_df = pd.read_csv('data/test.csv')

# Separar features y target
X_train = train_df.drop(['species'], axis=1)
y_train = train_df['species']
X_test = test_df.drop(['species'], axis=1)
y_test = test_df['species']

print(f"Features: {list(X_train.columns)}")
print(f"\nEntrenamiento: {X_train.shape[0]} muestras")
print(f"Prueba: {X_test.shape[0]} muestras")
```

**Celda 3: Entrenar Modelo**
```python
# Crear y entrenar modelo
model = RandomForestClassifier(
    n_estimators=100,
    max_depth=5,
    random_state=42
)

print("Entrenando modelo...")
model.fit(X_train, y_train)
print("Entrenamiento completado!")

# Mostrar importancia de features
feature_importance = pd.DataFrame({
    'feature': X_train.columns,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)

print("\nImportancia de características:")
print(feature_importance)
```

**Celda 4: Evaluar Modelo**
```python
# Predicciones
y_pred = model.predict(X_test)

# Métricas de evaluación
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy:.4f}")

print("\nClassification Report:")
species_names = ['setosa', 'versicolor', 'virginica']
print(classification_report(y_test, y_pred, target_names=species_names))

# Matriz de confusión
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=species_names,
            yticklabels=species_names)
plt.title('Matriz de Confusión')
plt.ylabel('Real')
plt.xlabel('Predicción')
plt.savefig('confusion_matrix.png')
plt.show()
print("Matriz de confusión guardada como 'confusion_matrix.png'")
```

**Celda 5: Guardar Modelo**
```python
# Crear directorio para el modelo
os.makedirs('model', exist_ok=True)

# Guardar modelo entrenado
model_path = 'model/iris_model.joblib'
joblib.dump(model, model_path)
print(f"Modelo guardado en: {model_path}")

# Guardar también los nombres de features para referencia
feature_names = list(X_train.columns)
joblib.dump(feature_names, 'model/feature_names.joblib')
print("Nombres de features guardados")

# Listar archivos creados
print("\nArchivos en directorio 'model/':")
for f in os.listdir('model'):
    size = os.path.getsize(f'model/{f}')
    print(f"  - {f} ({size} bytes)")
```

### 3.3 Ejecutar el Notebook

1. Ve a "Kernel" → "Restart Kernel and Run All Cells"
2. Espera a que todas las celdas se ejecuten
3. Verifica que el modelo se haya guardado correctamente

---

## 🚀 Paso 4: Desplegar Modelo en SageMaker

### 4.1 Crear Script de Inference

1. Crea un archivo llamado `inference.py`:

```python
import json
import joblib
import numpy as np
import os

# Directorio del modelo (SageMaker lo monta en /opt/ml/model)
MODEL_DIR = os.environ.get('SM_MODEL_DIR', 'model')

def model_fn(model_dir):
    """Carga el modelo desde el directorio"""
    model_path = os.path.join(model_dir, 'iris_model.joblib')
    model = joblib.load(model_path)
    return model

def input_fn(request_body, request_content_type):
    """Parsea el input de la request"""
    if request_content_type == 'application/json':
        data = json.loads(request_body)
        # Esperar lista de features: [[5.1, 3.5, 1.4, 0.2], [...]]
        return np.array(data['features'])
    else:
        raise ValueError(f"Content type {request_content_type} no soportado")

def predict_fn(input_data, model):
    """Realiza predicciones"""
    predictions = model.predict(input_data)
    probabilities = model.predict_proba(input_data)
    return {
        'predictions': predictions.tolist(),
        'probabilities': probabilities.tolist(),
        'species_names': ['setosa', 'versicolor', 'virginica']
    }

def output_fn(prediction, response_content_type):
    """Formatea la respuesta"""
    if response_content_type == 'application/json':
        return json.dumps(prediction), response_content_type
    raise ValueError(f"Content type {response_content_type} no soportado")
```

### 4.2 Crear Notebook para Deployment

1. Crea un nuevo notebook: `deploy_model.ipynb`
2. Copia el siguiente código:

**Celda 1: Imports y Configuración**
```python
import sagemaker
from sagemaker.sklearn.model import SKLearnModel
from sagemaker.serializers import JSONSerializer
from sagemaker.deserializers import JSONDeserializer
import boto3
import json

# Obtener sessión y rol
session = sagemaker.Session()
role = sagemaker.get_execution_role()
bucket = session.default_bucket()

print(f"SageMaker Role: {role}")
print(f"S3 Bucket: {bucket}")
```

**Celda 2: Subir Modelo a S3**
```python
# Subir el modelo a S3
model_artifact = session.upload_data(
    path='model/iris_model.joblib',
    bucket=bucket,
    key_prefix='lab-sagemaker/model'
)

print(f"Modelo subido a: {model_artifact}")

# También subir el script de inference
import shutil
shutil.copy('inference.py', 'model/inference.py')
```

**Celda 3: Crear y Desplegar Endpoint**
```python
# Crear modelo de SageMaker
# Nota: Para scikit-learn, usamos el container pre-construido
from sagemaker.sklearn import SKLearnModel

# Framework version y Python version
sklearn_model = SKLearnModel(
    model_data=model_artifact,
    role=role,
    entry_point='inference.py',
    framework_version='1.2-1',  # scikit-learn 1.2
    py_version='py3'
)

# Desplegar endpoint
print("Desplegando endpoint (esto puede tardar 5-10 minutos)...")
predictor = sklearn_model.deploy(
    initial_instance_count=1,
    instance_type='ml.t2.medium',  # Free tier eligible
    serializer=JSONSerializer(),
    deserializer=JSONDeserializer()
)

print(f"Endpoint desplegado: {predictor.endpoint_name}")
```

**Celda 4: Probar Endpoint**
```python
# Datos de prueba (Iris dataset - setosa)
test_samples = {
    "features": [
        [5.1, 3.5, 1.4, 0.2],   # setosa
        [6.2, 3.4, 5.4, 2.3],   # virginica
        [5.9, 3.0, 4.2, 1.5]    # versicolor
    ]
}

print("Enviando predicciones...")
result = predictor.predict(test_samples)

print("\nResultados:")
for i, (pred, probs) in enumerate(zip(result['predictions'], result['probabilities'])):
    species = result['species_names'][pred]
    print(f"\nMuestra {i+1}:")
    print(f"  Predicción: {species} (clase {pred})")
    print(f"  Probabilidades:")
    for j, (name, prob) in enumerate(zip(result['species_names'], probs)):
        print(f"    - {name}: {prob:.4f}")
```

3. Ejecuta todas las celdas y espera a que el endpoint esté disponible

---

## 🧪 Paso 5: Probar el Endpoint desde Fuera de SageMaker

### 5.1 Obtener URL del Endpoint

1. En la consola de AWS, ve a SageMaker → Endpoints
2. Copia el nombre del endpoint (ejemplo: `sklearn-model-2025-04-29-12-34-56`)

### 5.2 Crear Script de Prueba Local

1. Crea un archivo `test_endpoint.py` en tu computadora local:

```python
import boto3
import json
from botocore.config import Config

# Configuración
region = 'us-east-1'
endpoint_name = 'NOMBRE-DE-TU-ENDPOINT'  # Reemplazar

# Cliente de SageMaker Runtime
runtime = boto3.client('sagemaker-runtime', region_name=region)

# Datos de prueba
test_data = {
    "features": [
        [5.1, 3.5, 1.4, 0.2],   # Debería ser setosa
        [6.7, 3.0, 5.2, 2.3],   # Debería ser virginica
        [5.5, 2.5, 4.0, 1.3]    # Debería ser versicolor
    ]
}

# Llamar al endpoint
response = runtime.invoke_endpoint(
    EndpointName=endpoint_name,
    ContentType='application/json',
    Body=json.dumps(test_data)
)

# Parsear respuesta
result = json.loads(response['Body'].read().decode())

print("=" * 50)
print("PREDICCIONES DEL MODELO")
print("=" * 50)

for i, (pred, probs) in enumerate(zip(result['predictions'], result['probabilities'])):
    species = result['species_names'][pred]
    confidence = max(probs) * 100
    
    print(f"\nFlor {i+1}:")
    print(f"  Especie predicha: {species.upper()}")
    print(f"  Confianza: {confidence:.2f}%")
    print(f"  Probabilidades:")
    for name, prob in zip(result['species_names'], probs):
        bar = "█" * int(prob * 20)
        print(f"    {name:12s}: {prob:.4f} {bar}")

print("\n" + "=" * 50)
```

2. Ejecuta el script (requiere AWS CLI configurado):
```bash
python test_endpoint.py
```

---

## 📊 Paso 6: Monitorear el Endpoint

### 6.1 CloudWatch Metrics

1. En la consola de SageMaker, selecciona tu endpoint
2. Ve a la pestaña "Monitoring"
3. Verás métricas como:
   - **Invocations**: Número de llamadas al endpoint
   - **Invocation Errors**: Errores en las llamadas
   - **Latency**: Tiempo de respuesta
   - **CPUUtilization**: Uso de CPU de la instancia

### 6.2 Configurar Alarma

1. Ve a CloudWatch → Alarms → Create alarm
2. Selecciona métrica: `SageMaker` → `Endpoint` → `InvocationErrors`
3. Configura:
   - Umbral: Greater than 10
   - Período: 5 minutos
4. Configura notificación SNS para recibir alertas

---

## 🎯 Bonus: Entrenamiento con SageMaker Training Jobs

### 7.1 Crear Script de Entrenamiento

Crea `train_sagemaker.py`:

```python
import argparse
import os
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--n-estimators', type=int, default=100)
    parser.add_argument('--max-depth', type=int, default=5)
    return parser.parse_known_args()

def main():
    args, _ = parse_args()
    
    # Rutas de SageMaker
    input_path = os.environ.get('SM_CHANNEL_TRAINING', 'data')
    output_path = os.environ.get('SM_MODEL_DIR', 'model')
    
    # Cargar datos
    train_file = os.path.join(input_path, 'train.csv')
    train_df = pd.read_csv(train_file)
    
    X_train = train_df.drop(['species'], axis=1)
    y_train = train_df['species']
    
    # Entrenar
    print(f"Entrenando con n_estimators={args.n_estimators}, max_depth={args.max_depth}")
    model = RandomForestClassifier(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        random_state=42
    )
    model.fit(X_train, y_train)
    
    # Guardar
    os.makedirs(output_path, exist_ok=True)
    joblib.dump(model, os.path.join(output_path, 'model.joblib'))
    print("Modelo guardado exitosamente")

if __name__ == '__main__':
    main()
```

### 7.2 Ejecutar Training Job

En un nuevo notebook:

```python
from sagemaker.sklearn import SKLearn

# Configurar estimator
sklearn_estimator = SKLearn(
    entry_point='train_sagemaker.py',
    role=sagemaker.get_execution_role(),
    instance_count=1,
    instance_type='ml.m5.large',  # Puede ser spot para ahorrar costos
    framework_version='1.2-1',
    py_version='py3',
    hyperparameters={
        'n-estimators': 150,
        'max-depth': 6
    }
)

# Subir datos a S3
input_s3 = session.upload_data(
    path='data/train.csv',
    bucket=bucket,
    key_prefix='lab-sagemaker/input'
)

# Ejecutar entrenamiento
sklearn_estimator.fit('s3://{}/lab-sagemaker/input'.format(bucket))
print("Training job completado!")
```

---

## ✅ Verificación

- [ ] Notebook instance creado exitosamente
- [ ] Dataset preparado y cargado
- [ ] Modelo entrenado con scikit-learn
- [ ] Métricas de evaluación generadas
- [ ] Modelo guardado en formato joblib
- [ ] Script de inference creado
- [ ] Modelo subido a S3
- [ ] Endpoint desplegado y "In service"
- [ ] Predicciones exitosas desde el notebook
- [ ] Predicciones exitosas desde script local (opcional)
- [ ] CloudWatch metrics visibles
- [ ] Training job ejecutado (bonus)

---

## 🧹 Limpieza

### IMPORTANTE: Eliminar para evitar costos

1. **Eliminar Endpoint:**
   - SageMaker → Endpoints
   - Selecciona el endpoint → Actions → Delete
   - Espera a que se elimine

2. **Eliminar Notebook Instance:**
   - SageMaker → Notebook instances
   - Selecciona tu notebook → Actions → Stop (si está running)
   - Luego: Actions → Delete

3. **Eliminar Modelos y Configuraciones:**
   - SageMaker → Models → Elimina el modelo creado
   - SageMaker → Endpoint configurations → Elimina la configuración

4. **Eliminar Archivos S3:**
   ```bash
   aws s3 rm s3://tu-bucket/lab-sagemaker/ --recursive
   ```

5. **Eliminar CloudWatch Logs:**
   - CloudWatch → Log Groups
   - Busca `/aws/sagemaker/` → Elimina logs del notebook

---

## 📚 Recursos Adicionales

- [Guía de SageMaker](https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html)
- [Scikit-learn en SageMaker](https://sagemaker.readthedocs.io/en/stable/frameworks/sklearn/using_sklearn.html)
- [SageMaker Examples GitHub](https://github.com/aws/amazon-sagemaker-examples)
- [Pricing SageMaker](https://aws.amazon.com/sagemaker/pricing/)
- [Mejores Prácticas ML en AWS](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/welcome.html)

---

## 🎯 Siguiente Laboratorio

→ [Lab 08: CI/CD con CodePipeline](lab-08-ci-cd-codepipeline.md)

---

*Última actualización: Abril 2025*
