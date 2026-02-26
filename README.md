# Calculadora de Von Neumann

Simulador interactivo de la arquitectura de Von Neumann que permite visualizar paso a paso el ciclo **Fetch → Decode → Execute** sobre una arquitectura de 8 bits.

---

## Desarrollado por

- David Felipe Tovar Zurita
- Jhon Alejandro García Pareja
- Emmanuel Narváez Hernández

Facultad de Ingeniería — Universidad de Antioquia  
Arquitectura de Computadores y Laboratorio
2026-1
---

## Características

- Suma de 2 a 6 números ingresados por el usuario
- Visualización en tiempo real de registros PC, IR y AC
- Tabla de memoria con colores por tipo de celda (instrucción, dato, resultado)
- Ejecución paso a paso o automática con velocidad ajustable
- Validación de overflow para sumas que superan 255

---

## Cómo ejecutarlo

### 1. Clona el repositorio
```bash
git clone https://github.com/davidtzz/Laboratorio1_ArquiComp
cd Laboratorio1_ArquiComp
```

### 2. Ejecuta el servidor
```bash
python app.py
```

### 3. Abre en el navegador
```
http://localhost:5050
```

---

## Tecnologías utilizadas

- **Python** — lógica de simulación
- **Flask** — servidor web
- **HTML / CSS / JavaScript** — interfaz gráfica