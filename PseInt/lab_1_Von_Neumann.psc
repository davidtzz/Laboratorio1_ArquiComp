Algoritmo VonNeumann_5mas11
	
	Definir memoria Como Caracter
	Dimension memoria[7]
	
	Definir etiqueta Como Caracter
	Dimension etiqueta[7]
	
	Definir bits Como Caracter
	Dimension bits[8]
	
	Definir PC, AC, RDir, i, potencia, bit, n Como Entero
	Definir IR, opcode, dir_bits, RD, cadena Como Caracter
	Definir halt Como Logico
	
	// --- Carga de memoria ---
	// Formato: [OPCODE 4 bits][DIRECCION 4 bits]
	// La direccion apunta a donde esta el dato en memoria
	memoria[1] <- "00010101"  // LOAD  dir[5] -> carga mem[5]=5 en AC
	memoria[2] <- "00100110"  // ADD   dir[6] -> suma  mem[6]=11 al AC
	memoria[3] <- "00110111"  // STORE dir[7] -> guarda AC en mem[7]
	memoria[4] <- "11110000"  // END           -> termina programa
	memoria[5] <- "00000101"  // DATO: 5  en binario
	memoria[6] <- "00001011"  // DATO: 11 en binario
	memoria[7] <- "00000000"  // RESULTADO: aqui se guardara 16
	
	etiqueta[1] <- "INSTRUCCION: LOAD  dir[5]"
	etiqueta[2] <- "INSTRUCCION: ADD   dir[6]"
	etiqueta[3] <- "INSTRUCCION: STORE dir[7]"
	etiqueta[4] <- "INSTRUCCION: END"
	etiqueta[5] <- "DATO: 5  (00000101 en binario)"
	etiqueta[6] <- "DATO: 11 (00001011 en binario)"
	etiqueta[7] <- "RESULTADO: aqui se guardara 16"
	
	PC   <- 1
	AC   <- 0
	halt <- Falso
	
	// =====================================================
	//  PRESENTACION INICIAL
	// =====================================================
	Escribir ""
	Escribir "########################################################"
	Escribir "#                                                      #"
	Escribir "#     SIMULADOR DE LA MAQUINA DE VON NEUMANN           #"
	Escribir "#          Operacion: 5 + 11 = ?                       #"
	Escribir "#                                                      #"
	Escribir "########################################################"
	Escribir ""
	Escribir ">>> QUE ES ESTO?"
	Escribir "    Von Neumann propuso en 1945 que instrucciones"
	Escribir "    Y datos vivan en la MISMA memoria."
	Escribir "    La CPU las lee una por una con el ciclo:"
	Escribir "    FETCH -> DECODE -> EXECUTE"
	Escribir ""
	Escribir ">>> COMPONENTES QUE VEREMOS EN ACCION:"
	Escribir "    [PC]           Contador de Programa"
	Escribir "                   Dice cual direccion de memoria leer"
	Escribir "    [IR]           Registro de Instrucciones"
	Escribir "                   Guarda la instruccion que se esta ejecutando"
	Escribir "    [DECODIFICADOR] Separa los 8 bits en OPCODE y DIRECCION"
	Escribir "    [ALU]          Unidad Aritmetica y Logica"
	Escribir "                   Hace la suma"
	Escribir "    [AC]           Acumulador"
	Escribir "                   Registro que guarda el resultado parcial"
	Escribir ""
	Escribir ">>> FORMATO DE CADA PALABRA EN MEMORIA (8 bits):"
	Escribir "    [ bit1 bit2 bit3 bit4 | bit5 bit6 bit7 bit8 ]"
	Escribir "    [  OPCODE: que hacer  |  DIRECCION: donde   ]"
	Escribir ""
	Escribir ">>> TABLA DE OPCODES:"
	Escribir "    0001 = LOAD  -> Carga dato al Acumulador"
	Escribir "    0010 = ADD   -> Suma dato al Acumulador"
	Escribir "    0011 = STORE -> Guarda Acumulador en memoria"
	Escribir "    1111 = END   -> Termina el programa"
	Escribir ""
	Escribir "--- ESTADO INICIAL DE LA MEMORIA ---"
	Escribir "DIR | CONTENIDO   | DESCRIPCION"
	Escribir "----+------------+-----------------------------------"
	Para i <- 1 Hasta 7 Hacer
		Escribir " [", i, "]  ", memoria[i], "   ", etiqueta[i]
	FinPara
	Escribir ""
	Escribir "NOTA: Instrucciones (dir 1-4) y Datos (dir 5-6)"
	Escribir "      conviven en la misma memoria. Eso es Von Neumann."
	Escribir ""
	Escribir "Presiona ENTER para comenzar la ejecucion..."
	Leer i
	
	// =====================================================
	//  CICLO PRINCIPAL: FETCH -> DECODE -> EXECUTE
	// =====================================================
	Mientras No halt Hacer
		
		Escribir ""
		Escribir "========================================================"
		Escribir "  NUEVO CICLO  |  PC apunta a dir[", PC, "]"
		Escribir "========================================================"
		
		// -----------------------------------------------
		// FASE 1: FETCH
		// -----------------------------------------------
		Escribir ""
		Escribir "  +--------------------------------------------------+"
		Escribir "  |  FASE 1: FETCH  (Busqueda en memoria)            |"
		Escribir "  +--------------------------------------------------+"
		Escribir "  El [PC] vale: ", PC
		Escribir "  Esto significa: la proxima instruccion esta en dir[", PC, "]"
		Escribir ""
		Escribir "  La Unidad de Control va a memoria[", PC, "] y lee su contenido."
		IR <- memoria[PC]
		Escribir "  Contenido encontrado: ", IR
		Escribir "  Ese valor se carga en el [IR] (Registro de Instrucciones)"
		Escribir "  [IR] = ", IR
		Escribir ""
		PC <- PC + 1
		Escribir "  El [PC] se incrementa automaticamente: ahora PC = ", PC
		Escribir "  (Ya apunta a la siguiente instruccion para el proximo ciclo)"
		Escribir ""
		Escribir "  Presiona ENTER para DECODE..."
		Leer i
		
		// -----------------------------------------------
		// FASE 2: DECODE
		// -----------------------------------------------
		Escribir ""
		Escribir "  +--------------------------------------------------+"
		Escribir "  |  FASE 2: DECODE  (Decodificacion)                |"
		Escribir "  +--------------------------------------------------+"
		Escribir "  El [DECODIFICADOR] analiza el [IR]: ", IR
		Escribir ""
		Escribir "  Divide los 8 bits en dos partes:"
		opcode   <- Subcadena(IR, 1, 4)
		dir_bits <- Subcadena(IR, 5, 8)
		Escribir "  -> Bits 1 al 4 (OPCODE)    : ", opcode, "  <- que operacion hacer"
		Escribir "  -> Bits 5 al 8 (DIRECCION) : ", dir_bits, "  <- donde esta el dato"
		Escribir ""
		
		// Convertir direccion binaria a decimal
		RDir <- 0
		potencia <- 1
		Para i <- 4 Hasta 1 Con Paso -1 Hacer
			bit  <- ConvertirANumero(Subcadena(dir_bits, i, i))
			RDir <- RDir + bit * potencia
			potencia <- potencia * 2
		FinPara
		Escribir "  La direccion ", dir_bits, " convertida a decimal = ", RDir
		Escribir "  Entonces el dato esta en memoria[", RDir, "]"
		Escribir ""
		
		Si opcode = "0001" Entonces
			Escribir "  El DECODIFICADOR reconoce 0001 = INSTRUCCION: LOAD"
			Escribir "  Significado: carga en el Acumulador el dato de memoria[", RDir, "]"
		FinSi
		Si opcode = "0010" Entonces
			Escribir "  El DECODIFICADOR reconoce 0010 = INSTRUCCION: ADD"
			Escribir "  Significado: suma al Acumulador el dato de memoria[", RDir, "]"
		FinSi
		Si opcode = "0011" Entonces
			Escribir "  El DECODIFICADOR reconoce 0011 = INSTRUCCION: STORE"
			Escribir "  Significado: guarda el Acumulador en memoria[", RDir, "]"
		FinSi
		Si opcode = "1111" Entonces
			Escribir "  El DECODIFICADOR reconoce 1111 = INSTRUCCION: END"
			Escribir "  Significado: el programa ha terminado"
		FinSi
		
		Escribir ""
		Escribir "  Presiona ENTER para EXECUTE..."
		Leer i
		
		// -----------------------------------------------
		// FASE 3: EXECUTE
		// -----------------------------------------------
		Escribir ""
		Escribir "  +--------------------------------------------------+"
		Escribir "  |  FASE 3: EXECUTE  (Ejecucion)                    |"
		Escribir "  +--------------------------------------------------+"
		
		Si opcode = "0001" Entonces
			RD <- memoria[RDir]
			Escribir "  LOAD: La Unidad de Control va a memoria[", RDir, "]"
			Escribir "  Encuentra el valor binario: ", RD
			Escribir "  Convirtiendo ", RD, " de binario a decimal..."
			AC <- 0
			potencia <- 1
			Para i <- 8 Hasta 1 Con Paso -1 Hacer
				bit <- ConvertirANumero(Subcadena(RD, i, i))
				AC  <- AC + bit * potencia
				potencia <- potencia * 2
			FinPara
			Escribir "  Resultado de conversion: ", RD, " = ", AC, " en decimal"
			Escribir "  La ALU carga ese valor en el [ACUMULADOR]"
			Escribir ""
			Escribir "  >>> [ACUMULADOR AC] = ", AC, " <<<"
			Escribir "      (El acumulador ahora tiene el primer numero: 5)"
		FinSi
		
		Si opcode = "0010" Entonces
			RD <- memoria[RDir]
			Escribir "  ADD: La Unidad de Control va a memoria[", RDir, "]"
			Escribir "  Encuentra el valor binario: ", RD
			Escribir "  Convirtiendo ", RD, " de binario a decimal..."
			n <- 0
			potencia <- 1
			Para i <- 8 Hasta 1 Con Paso -1 Hacer
				bit <- ConvertirANumero(Subcadena(RD, i, i))
				n   <- n + bit * potencia
				potencia <- potencia * 2
			FinPara
			Escribir "  Resultado de conversion: ", RD, " = ", n, " en decimal"
			Escribir ""
			Escribir "  La ALU recibe dos entradas:"
			Escribir "  -> Entrada A (Acumulador actual) : ", AC
			Escribir "  -> Entrada B (dato de memoria[", RDir, "]) : ", n
			Escribir ""
			Escribir "  La ALU calcula: ", AC, " + ", n, " = ", AC + n
			AC <- AC + n
			Escribir ""
			Escribir "  >>> [ACUMULADOR AC] = ", AC, " <<<"
			Escribir "      (La ALU guarda el resultado parcial en el Acumulador)"
		FinSi
		
		Si opcode = "0011" Entonces
			Escribir "  STORE: El Acumulador tiene el valor: ", AC
			Escribir "  Hay que guardarlo en memoria[", RDir, "] en formato binario."
			Escribir "  Convirtiendo ", AC, " de decimal a binario de 8 bits..."
			cadena <- ""
			n <- AC
			Para i <- 8 Hasta 1 Con Paso -1 Hacer
				Si n MOD 2 = 1 Entonces
					bits[i] <- "1"
				SiNo
					bits[i] <- "0"
				FinSi
				n <- TRUNC(n / 2)
			FinPara
			Para i <- 1 Hasta 8 Hacer
				cadena <- cadena + bits[i]
			FinPara
			Escribir "  Resultado de conversion: ", AC, " decimal = ", cadena, " binario"
			memoria[RDir] <- cadena
			Escribir "  La Unidad de Control escribe en memoria[", RDir, "]"
			Escribir ""
			Escribir "  >>> memoria[", RDir, "] = ", memoria[RDir], " <<<"
			Escribir "      (El resultado quedo guardado en memoria)"
		FinSi
		
		Si opcode = "1111" Entonces
			Escribir "  END: La Unidad de Control recibe la senal de HALT."
			Escribir "  El ciclo Fetch-Decode-Execute se detiene."
			Escribir "  No hay mas instrucciones que ejecutar."
			halt <- Verdadero
		FinSi
		
		Si No halt Entonces
			Escribir ""
			Escribir "  ---- Estado actual de la CPU ----"
			Escribir "  [PC] = ", PC, "   [AC] = ", AC
			Escribir "  ----------------------------------"
			Escribir ""
			Escribir "  Presiona ENTER para el siguiente ciclo..."
			Leer i
		FinSi
		
	FinMientras
	
	// =====================================================
	//  RESULTADO FINAL
	// =====================================================
	Escribir ""
	Escribir "########################################################"
	Escribir "#                                                      #"
	Escribir "#   RESULTADO FINAL                                    #"
	Escribir "#                                                      #"
	Escribir "########################################################"
	Escribir ""
	Escribir "  La operacion 5 + 11 se ejecuto en 4 ciclos:"
	Escribir ""
	Escribir "  Ciclo 1 -> FETCH dir[1] | DECODE: LOAD dir[5] | EXECUTE: AC = 5"
	Escribir "  Ciclo 2 -> FETCH dir[2] | DECODE: ADD  dir[6] | EXECUTE: AC = 5 + 11 = 16"
	Escribir "  Ciclo 3 -> FETCH dir[3] | DECODE: STORE dir[7]| EXECUTE: mem[7] = 16"
	Escribir "  Ciclo 4 -> FETCH dir[4] | DECODE: END         | EXECUTE: HALT"
	Escribir ""
	Escribir "  Resultado guardado en memoria[7] = ", memoria[7]
	Escribir "  En decimal: 16"
	Escribir ""
	Escribir "  5 + 11 = 16   CORRECTO"
	Escribir ""
	Escribir "  Eso es Von Neumann: la CPU no sabe nada de antemano."
	Escribir "  Solo sigue instrucciones en memoria, una por una,"
	Escribir "  usando siempre el mismo ciclo: Fetch -> Decode -> Execute."
	Escribir ""
	
FinAlgoritmo
