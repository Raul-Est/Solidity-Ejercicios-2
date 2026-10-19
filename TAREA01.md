 Contexto
Vas a construir un tablón de tareas público, como un "mini Trello en blockchain". Cualquiera puede publicar una tarea y, si quiere, ponerle una recompensa en ether. Cualquier otra persona puede completarla y, al hacerlo, se lleva la recompensa automáticamente.
Este ejercicio junta TODO lo que hemos visto en clase y añade tres piezas nuevas que ya hemos nombrado: payable (recibir y enviar ether), mapping (indexar datos por dirección) y recorrer arrays con bucles.

 Requisitos obligatorios
Tu contrato TablonTareas debe contener, como mínimo:
1. El struct Tarea
solidity
struct Tarea {
    string  descripcion;    // qué hay que hacer
    bool    completada;     // false al crearse
    address creador;        // quién la publicó
    uint256 recompensa;     // en wei (puede ser 0)
    address completadaPor;  // quién la completó (address(0) si nadie aún)
}
2. Variables de estado
Un array dinámico privado: Tarea[] private tareas;
Un mapping que, para cada dirección, guarde la lista de índices de las tareas que ha creado:
solidity
  mapping(address => uint256[]) private tareasPorCreador;
Un mapping que lleve la cuenta del total de recompensa ganada por cada dirección:
solidity
  mapping(address => uint256) public recompensaGanada;

 Funciones que debes implementar
Fíjate bien en la visibilidad y en si es view, pure o payable. Es parte de la nota.
#
Función
Visibilidad / tipo
Qué debe hacer
1
crearTarea(string _descripcion)
public payable
Crea una tarea nueva: completada = false, creador = msg.sender, recompensa = msg.value, completadaPor = address(0). La añade al array y guarda su índice en tareasPorCreador[msg.sender].
2
completar(uint256 _indice)
public
Valida el índice con require (usando _valido). Marca la tarea como completada, guarda quién la completó. Si tiene recompensa > 0, envía ese ether a quien completa y suma la cantidad en recompensaGanada. No se puede completar dos veces.
3
verTarea(uint256 _indice)
public view
Devuelve los 5 campos de la tarea: descripción, completada, creador, recompensa, completadaPor.
4
totalTareas()
public view
Devuelve cuántas tareas hay en total.
5
tareasDe(address _usuario)
public view
Devuelve el array uint256[] con los índices de las tareas creadas por esa dirección (léelo del mapping).
6
contarPendientes()
public view
Recorre el array y devuelve cuántas tareas siguen sin completar.
7
recompensaEnJuego()
public view
Recorre el array y devuelve la suma de las recompensas de todas las tareas aún no completadas (el ether que sigue "en el bote").
8
_valido(uint256 _indice)
private view
Devuelve true si el índice existe (< tareas.length). Úsala dentro de completar y verTarea.


 Requisitos técnicos transversales (los que dan la nota alta)
Tu solución debe demostrar que sabes:
payable para recibir → crearTarea acepta ether (msg.value) y lo guarda como recompensa.
payable para enviar → al completar, el ether sale del contrato hacia quien completa la tarea.
mapping → tareasPorCreador (dirección → lista de índices) y recompensaGanada (dirección → total).
Recorrer arrays → contarPendientes() y recompensaEnJuego() obligan a usar un bucle for.
require → validar índices y evitar completar una tarea ya completada.
Visibilidad correcta → nada public que pueda ser private/internal; lecturas como view.
