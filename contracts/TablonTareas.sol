// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TablonTareas {
    // Datos que guardamos de cada tarea.
    struct Tarea {
        string descripcion; // qué hay que hacer
        bool completada; // false al crearse
        address creador; // quién la publicó
        uint256 recompensa; // en wei (puede ser 0)
        address completadaPor; // quién la completó (address(0) si nadie aún)
        bool cancelada; // variable de estado
    }

    // Lista de tareas y sus indices agrupados por creador.
    Tarea[] private tareas;
    mapping(address => uint256[]) private tareasPorCreador;

    /* 
    Total de recompensas que ha cobrado cada usuario.
    - mapping(address => uint256) public recompensaGanada;
    Funciones 
    que debes implementarFíjate bien en la y en si es view, pure o payable. Es parte de la nota.
    */
    mapping(address => uint256) public recompensaGanada;
    event TareaCreada(uint256 indice, address creador, uint256 recompensa);
    event TareaCompletada(
        uint256 indice,
        address completadaPor,
        uint256 recompensa
    );

    // Publicamos una tarea y damos ether como recompensa.
    function crearTarea(string calldata _descripcion) public payable {
        require(bytes(_descripcion).length > 0, "La descripcion esta vacia");

        uint256 indice = tareas.length;

        tareas.push(
            Tarea({
                descripcion: _descripcion,
                completada: false,
                creador: msg.sender,
                recompensa: msg.value,
                completadaPor: address(0),
                cancelada: false
            })
        );

        tareasPorCreador[msg.sender].push(indice);
        emit TareaCreada(indice, msg.sender, msg.value);
    }

    // Otra persona puede completar la tarea y cobrar la recompensa.
    function completarTarea(uint256 _indice) public {
        require(_valido(_indice), "Indice no valido");

        Tarea storage tarea = tareas[_indice];

        require(tarea.completada == false, "La tarea ya esta completada");
        require(tarea.cancelada == false, "La tarea esta cancelada");
        require(
            msg.sender != tarea.creador,
            "No puedes completar tu propia tarea"
        );

        tarea.completada = true;
        tarea.completadaPor = msg.sender;

        uint256 cantidad = tarea.recompensa;
        if (cantidad > 0) {
            tarea.recompensa = 0;
            recompensaGanada[msg.sender] += cantidad;

            (bool enviado, ) = payable(msg.sender).call{value: cantidad}("");
            require(enviado, "No se pudo pagar la recompensa");
        }

        emit TareaCompletada(_indice, msg.sender, cantidad);
    }

    // Consultamos los datos del ejercicio.
    function verTarea(
        uint256 _indice
    )
        public
        view
        returns (
            string memory descripcion,
            bool completada,
            address creador,
            uint256 recompensa,
            address completadaPor
        )
    {
        require(_valido(_indice), "Indice no valido");

        Tarea storage tarea = tareas[_indice];
        return (
            tarea.descripcion,
            tarea.completada,
            tarea.creador,
            tarea.recompensa,
            tarea.completadaPor
        );
    }

    function totalTareas() public view returns (uint256) {
        return tareas.length;
    }

    function tareasDe(address _usuario) public view returns (uint256[] memory) {
        return tareasPorCreador[_usuario];
    }

    // Contamos las tareas que siguen pendientes.
    function contarPendientes() public view returns (uint256) {
        uint256 pendientes = 0;

        for (uint256 i = 0; i < tareas.length; i++) {
            Tarea storage tarea = tareas[i];

            // Esta pendiente si no esta completada ni cancelada.
            if (tarea.completada == false && tarea.cancelada == false) {
                pendientes++;
            }
        }

        return pendientes;
    }

    // Sumamos ether de las tareas pendientes de completar.
    function recompensaEnJuego() public view returns (uint256) {
        uint256 total = 0;

        for (uint256 i = 0; i < tareas.length; i++) {
            Tarea storage tarea = tareas[i];

            // Esta pendiente si no esta completada ni cancelada.
            if (tarea.completada == false && tarea.cancelada == false) {
                total += tarea.recompensa;
            }
        }

        return total;
    }

    // El creador puede cancelar su tarea y recuperar el dinero.
    function cancelar(uint256 _indice) public {
        require(_valido(_indice), "Indice no valido");

        Tarea storage tarea = tareas[_indice];

        require(msg.sender == tarea.creador, "Solo el creador puede cancelar");
        require(tarea.completada == false, "La tarea ya esta completada");
        require(tarea.cancelada == false, "La tarea ya esta cancelada");

        tarea.cancelada = true;

        uint256 cantidad = tarea.recompensa;
        if (cantidad > 0) {
            tarea.recompensa = 0;

            (bool enviado, ) = payable(msg.sender).call{value: cantidad}("");
            require(enviado, "No se pudo devolver la recompensa");
        }
    }
    function _valido(uint256 _indice) private view returns (bool) {
        return _indice < tareas.length;
    }
}
