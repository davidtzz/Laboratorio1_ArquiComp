import subprocess
import sys

try:
    import flask
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install","--user", "flask"])
    import flask
from flask import Flask, jsonify, request
from flask import send_from_directory
import os


app = Flask(__name__, static_folder='static')

# ─── HELPERS ──────────────────────────────────────────────────
def decimal_a_binario_8bits(n):
    bits = ["0"] * 8
    for i in range(7, -1, -1):
        bits[i] = "1" if n % 2 == 1 else "0"
        n = n // 2
    return "".join(bits)

def binario_a_decimal(cadena):
    resultado = 0
    potencia = 1
    for i in range(len(cadena) - 1, -1, -1):
        bit = int(cadena[i])
        resultado += bit * potencia
        potencia *= 2
    return resultado

def dir_a_4bits(d):
    bits = ["0"] * 4
    for i in range(3, -1, -1):
        bits[i] = "1" if d % 2 == 1 else "0"
        d = d // 2
    return "".join(bits)

def construir_instruccion(opcode_bits, direccion):
    return opcode_bits + dir_a_4bits(direccion)

# ─── BUILD PROGRAM ────────────────────────────────────────────
@app.route('/api/cargar', methods=['POST'])
def cargar():
    data     = request.json
    numeros  = data.get('numeros', [])

    if len(numeros) < 2:
        return jsonify({'error': 'Se necesitan al menos 2 números'}), 400

    for n in numeros:
        if not (0 <= n <= 255):
            return jsonify({'error': f'El número {n} está fuera de rango (0-255)'}), 400

    resultado_esperado = sum(numeros)
    if resultado_esperado > 255:
        return jsonify({
            'overflow': True,
            'suma':     resultado_esperado,
            'bits_necesarios': resultado_esperado.bit_length(),
            'error': f'OVERFLOW: {" + ".join(str(n) for n in numeros)} = {resultado_esperado} > 255'
        }), 400

    cantidad      = len(numeros)
    dir_load      = 1
    dir_adds      = list(range(2, 1 + cantidad))
    dir_store     = 1 + cantidad
    dir_end       = 2 + cantidad
    dir_datos     = dir_end + 1
    dir_resultado = dir_datos + cantidad
    total_celdas  = dir_resultado + 1

    memoria  = [""] * total_celdas
    etiqueta = [""] * total_celdas
    tipo_mem = [""] * total_celdas

    memoria[dir_load]  = construir_instruccion("0001", dir_datos)
    etiqueta[dir_load] = f"LOAD dir[{dir_datos}]"
    tipo_mem[dir_load] = "instr"

    for idx, d in enumerate(dir_adds):
        target = dir_datos + 1 + idx
        memoria[d]  = construir_instruccion("0010", target)
        etiqueta[d] = f"ADD dir[{target}]"
        tipo_mem[d] = "instr"

    memoria[dir_store]  = construir_instruccion("0011", dir_resultado)
    etiqueta[dir_store] = f"STORE dir[{dir_resultado}]"
    tipo_mem[dir_store] = "instr"

    memoria[dir_end]  = "11110000"
    etiqueta[dir_end] = "END"
    tipo_mem[dir_end] = "instr"

    for idx, num in enumerate(numeros):
        d = dir_datos + idx
        memoria[d]  = decimal_a_binario_8bits(num)
        etiqueta[d] = f"DATO: {num}"
        tipo_mem[d] = "data"

    memoria[dir_resultado]  = "00000000"
    etiqueta[dir_resultado] = f"RESULTADO (→ {resultado_esperado})"
    tipo_mem[dir_resultado] = "result"

    celdas = []
    for i in range(1, total_celdas):
        celdas.append({
            'dir':      i,
            'bits':     memoria[i],
            'decimal':  binario_a_decimal(memoria[i]),
            'etiqueta': etiqueta[i],
            'tipo':     tipo_mem[i]
        })

    return jsonify({
        'ok':              True,
        'numeros':         numeros,
        'resultado':       resultado_esperado,
        'dir_resultado':   dir_resultado,
        'total_celdas':    total_celdas,
        'memoria':         celdas,
        'memoria_raw':     memoria,
        'tipo_mem':        tipo_mem,
    })

# ─── STEP EXECUTION ───────────────────────────────────────────
@app.route('/api/paso', methods=['POST'])
def paso():
    data         = request.json
    memoria      = data['memoria_raw']
    tipo_mem     = data['tipo_mem']
    PC           = data['PC']
    AC           = data['AC']
    IR           = data['IR']
    fase         = data['fase']       # 0=fetch, 1=decode, 2=execute
    opcode       = data.get('opcode', '')
    dir_bits     = data.get('dir_bits', '')
    RDir         = data.get('RDir', 0)
    ciclo        = data['ciclo']
    dir_resultado= data['dir_resultado']
    numeros      = data['numeros']

    log      = []
    changed  = -1
    active   = -1
    halt     = False
    new_fase = (fase + 1) % 3

    if fase == 0:  # FETCH
        ciclo += 1
        IR     = memoria[PC]
        log.append({'cls': 'sep',   'msg': f'── CICLO {ciclo} ───────────────────────────'})
        log.append({'cls': 'phase', 'msg': '▶ FASE 1: FETCH'})
        log.append({'cls': 'fetch', 'msg': f'  PC={PC} → leyendo mem[{PC}] = {IR}'})
        active = PC
        PC    += 1
        log.append({'cls': 'fetch', 'msg': f'  IR ← {IR}   |   PC++ → {PC}'})

    elif fase == 1:  # DECODE
        opcode   = IR[0:4]
        dir_bits = IR[4:8]
        RDir     = binario_a_decimal(dir_bits)
        ops      = {'0001': 'LOAD', '0010': 'ADD', '0011': 'STORE', '1111': 'END'}
        op_name  = ops.get(opcode, '???')
        log.append({'cls': 'phase',  'msg': '▶ FASE 2: DECODE'})
        log.append({'cls': 'decode', 'msg': f'  IR={IR}'})
        log.append({'cls': 'decode', 'msg': f'  OPCODE={opcode} ({op_name})  DIR={dir_bits} (→ {RDir})'})
        active = RDir

    elif fase == 2:  # EXECUTE
        log.append({'cls': 'phase', 'msg': '▶ FASE 3: EXECUTE'})
        if opcode == '0001':
            rd  = memoria[RDir]
            AC  = binario_a_decimal(rd)
            log.append({'cls': 'exec', 'msg': f'  LOAD mem[{RDir}]={rd} → AC={AC}'})
            active = RDir
        elif opcode == '0010':
            rd  = memoria[RDir]
            val = binario_a_decimal(rd)
            log.append({'cls': 'exec', 'msg': f'  ADD: AC({AC}) + mem[{RDir}]({val}) = {AC+val}'})
            AC += val
            log.append({'cls': 'exec', 'msg': f'  AC ← {AC}'})
            active = RDir
        elif opcode == '0011':
            bin_str = decimal_a_binario_8bits(AC)
            memoria[RDir] = bin_str
            log.append({'cls': 'exec', 'msg': f'  STORE: AC={AC} → mem[{RDir}]={bin_str}'})
            changed = RDir
        elif opcode == '1111':
            halt = True
            log.append({'cls': 'exec',   'msg': '  END → HALT'})
            log.append({'cls': 'sep',    'msg': '════════════════════════════════════════'})
            log.append({'cls': 'ok',     'msg': f'✓ {" + ".join(str(n) for n in numeros)} = {AC}'})
            log.append({'cls': 'result', 'msg': f'  mem[{dir_resultado}] = {memoria[dir_resultado]}'})
            log.append({'cls': 'sep',    'msg': '════════════════════════════════════════'})

        if halt:
            new_fase = 0

    # Rebuild memory view
    celdas = []
    for i in range(1, len(memoria)):
        if memoria[i] == '':
            continue
        celdas.append({
            'dir':      i,
            'bits':     memoria[i],
            'decimal':  binario_a_decimal(memoria[i]),
            'tipo':     tipo_mem[i],
            'changed':  i == changed,
            'active':   i == active,
            'is_pc':    i == PC,
        })

    return jsonify({
        'PC':          PC,
        'AC':          AC,
        'IR':          IR,
        'opcode':      opcode,
        'dir_bits':    dir_bits,
        'RDir':        RDir,
        'fase':        new_fase,
        'ciclo':       ciclo,
        'halt':        halt,
        'log':         log,
        'memoria':     celdas,
        'memoria_raw': memoria,
    })

@app.route('/')
def index():
    return send_from_directory('static', 'index.html')

if __name__ == '__main__':
    app.run(debug=True, port=5050)
