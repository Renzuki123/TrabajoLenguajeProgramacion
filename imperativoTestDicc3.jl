# Creating a Typed Dictionary
global Dicc = Dict{String, Float64}()

while(true)
    function mostrarGanador()
        min = 100000000 # Suposicion de que ninguno llegara a ese tiempo
        jugador = ""
        # Hallamos el que tenga menor tiempo con un bucle for
        for (key, value) in Dicc
            if (value < min)
                min = value
                jugador = key
            end
        end

        if (min == 100000000) # En caso no se registre ningun jugador
            println("No hay jugadores registrados o no hay jugadores que completaron el juego")
        else
            println(" ========= TENEMOS UN GANADOR! =========")
            println("El ganador es: ", jugador, " con un tiempo: ", min, " segundos")
        end
    end
    # ESCENARIO DEFAULT: Estas 3 variables son predeterminadas

    global field_size = 8
    global mine_count = 9
    global is_game_over = false

    print("Ingrese el nombre de jugador (en caso ya no juegue ponga 'stop'): ")
    jugador = string(readline())

    if (jugador == "stop")
            mostrarGanador()
        break # se cierra el juego
    end

    println("`easy`: campo 6x6 con 6 minas")
    println("Otros niveles de juego estarán disponible más adelante")
    print("Escoge la dificultad: ")
    diff = string(readline()) # readline() es el input

    if diff === "easy"
        global field_size = 6 # global es para que todas las funciones puedan accederla
        global mine_count = 6
    end

    # -1 Means the cell is a mine
    # 0 Means Empty
    # 1 Means 1 mine is around the cell
    # 2 Means 2 mines is around the cell
    # 3 Means 3 mines is around the cell
    # 4 Means 4 mines is around the cell
    # 5 Means 5 mines is around the cell
    # ...
    # 8 Means 8 mines is around the cell

    # zeros(Tipo de dato de la matriz, dimension, dimension) sirve para matriz o array
    global field = zeros(Int32, field_size, field_size)
    global field_view = Array{Union{String,Int32}}(undef, field_size, field_size) # Union para mezclar tipos de datos
    global field_view .= "■" # El operador . realiza operacion para cada elemento del arreglo
    global revealed_cells = 0

    instructions = """
    Tipea las coordenadas de la celda que quieres chequear.
    Tipea `m 1 2` para minar (1, 2) o `f 1 2` para marcar (1, 2) o tipea `exit` para salir.
    Nota: columna y fila (NO FILA Y COLUMNA!)
    """

    # Generating random coordinate to place mine
    function generateRandomCoord(min, max)
        return rand(1:field_size)
    end

    # Checking surrounding cells for mines
    function checkSurroundingCells(field, x, y)
        noOfMines = 0
        surroundingCells = [
            (x - 1, y - 1),
            (x - 1, y),
            (x - 1, y + 1),
            (x, y - 1),
            (x, y + 1),
            (x + 1, y - 1),
            (x + 1, y),
            (x + 1, y + 1),
        ]
        for c in surroundingCells # Por cada coordenada...
            # Nota: En Julia el index empieza en 1
            # Si la abscisa es mayor a 0 y la ordenada es menor al tamaño del field...
            if (0 < c[1] <= field_size && 0 < c[2] <= field_size) # Verifica que las celdas no sean las esquinas
                if (field[c[2], c[1]] == -1) 
                    noOfMines += 1
                end
            end
        end
        return noOfMines
    end

    # Adding numbers to cells
    function addNumbersToCells()
        for y = 1:field_size
            for x = 1:field_size
                if (field[y, x] != -1) # Si no es mina...
                    field[y, x] = checkSurroundingCells(field, x, y) # Da el valor de los vecinos
                end
            end
        end
    end

    # Function to add mines
    function add_mines()
        x = generateRandomCoord(1, field_size)
        y = generateRandomCoord(1, field_size)
        if (field[y, x] != -1)
            field[y, x] = -1
        else
            add_mines()
        end
    end

    # Adding Mines to field
    for i = 1:mine_count add_mines() end

    # Adding numbers to cells
    addNumbersToCells()

    # Displays field and gridlines
    function displayField(field)
        # Adding column numbers
        finalStr = "   "
        for x = 1:field_size
            finalStr *= "  $(x)" # *= es para concatenar
        end
        finalStr *= "\n   "
        for x = 1:field_size
            finalStr *= "___"
        end
        finalStr *= "\n"

        for y = 1:field_size
            # Adding row numbers
            finalStr *= "$(y) |"

            # Replacing numbers with specific values
            for x = 1:field_size
                val = field[y, x]
                if (val == -1)
                    finalStr *= "  *"
                else
                    finalStr *= "  $(val)"
                end
            end
            finalStr *= "\n"
        end
        return finalStr
    end

    # This function is triggered when user clicks on a tile with no mines around it.
    # It clears the field around it.
    function clickOnZero(x, y)
        global field_view[y, x] = "0"
        global revealed_cells += 1
        surroundingCells = [
            (x - 1, y - 1),
            (x - 1, y),
            (x - 1, y + 1),
            (x, y - 1),
            (x, y + 1),
            (x + 1, y - 1),
            (x + 1, y),
            (x + 1, y + 1),
        ]
        for c in surroundingCells
            if (0 < c[1] <= field_size && 0 < c[2] <= field_size)
                # Checks if surrounding tile is also zero and does recursion.
                if (field[c[2], c[1]] == 0 && field_view[c[2], c[1]] == "■")
                    clickOnZero(c[1], c[2])

                elseif (field[c[2], c[1]] != -1 && field_view[c[2], c[1]] == "■")
                    field_view[c[2], c[1]] = field[c[2], c[1]]
                    global revealed_cells += 1
                end
            end
        end
    end

    # Clicks on a tile in the game
    function simulateClick(x, y)
        if (field[y, x] == -1)
            global is_game_over = true
            println("You Lost !!")
            displayFinalField()
            exit()
        elseif (field[y, x] == 0)
            clickOnZero(x, y)
        else
            field_view[y, x] = field[y, x]
            global revealed_cells += 1
        end
    end

    # Parses user input and performs actions accordingly
    function parseInput(task, x, y)
        if (task == "m")
            simulateClick(x, y)
        elseif (task == "f")
            if (field_view[y, x] == "■")
                field_view[y, x] = "?"
            end
        end
    end

    # Desplay field with revealed cells and mines at the end of the game.
    function displayFinalField()
        for y in 1:field_size, x in 1:field_size
            if (field[y, x] == -1)
                field_view[y, x] = "*"
            end
        end
        println(displayField(field_view))
    end

    # Repeats the loop until game is over
    function jugar()
        while (!is_game_over)
            println("---------------------------------------------------------------------")
            println(displayField(field_view))
            # Uncomment the line below to see the finished field
            # println(displayField(field))
            displayFinalField() # REMOVER
            println(instructions)
            print("Ingrese comando: ")
            inp = chomp(readline()) # Remueve los saltos de línea en caso existan
            inpList = split(inp) # Convierte a lista y separa cada elemento del input

            if (inp == "exit")
                displayFinalField()
                exit()
            elseif (length(inpList) == 3) # Evalua si la longitud sean 3 elementos
                x = parse(Int32, inpList[2])
                y = parse(Int32, inpList[3])
                parseInput(inpList[1], x, y)
                #  Ganas en caso celdas reveladas sea igual a la diferencia entre el tamaño del campo y las minas
                if (revealed_cells == (field_size^2) - mine_count)
                    println("Completaste el juego !!")
                    displayFinalField()
                    global is_game_over = true # Esto es mejor que exit() en este caso
                    #exit() No va porque terminaría todo el programa y no calcularía el tiempo de ejecucion
                end
            else
                println("Por favor, ingrese el comando correcto")
                exit()
            end
        end
    end;

    tiempo = @elapsed jugar() # Solo calculara el tiempo en caso gane (mirar la funcion jugar)
    Dicc[jugador] = tiempo
    println("Record de jugadores que completaron el juego: \n\t", Dicc)
end
