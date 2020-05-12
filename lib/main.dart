import 'dart:math';
import 'package:flutter/material.dart';

//Metodo Main, donde empieza a correr la aplicacion.

void main() {

  return runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey.shade800,
        appBar: AppBar(
          title: Center(child: Text('Dice Game')),
          backgroundColor: Colors.indigo.shade800,
        ),
        body: DicePage(),
      ),
    ),
  );
}

//Stateful Widget, el cual representa el juego de dados en sí.

class Game extends StatefulWidget {
  Game({Key key, this.activado = false, @required this.empezar, this.rondas = 1, this.jugadores = 2})
      :super(key: key);

  bool activado = false;
  ValueChanged<bool> empezar;
  int rondas;
  int jugadores;


  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  /*
    Declaración de variables, los cuales registran el puntaje obtenido,
    la ronda actual, el ganador de la ronda, el turno del jugador, etc.
   */
  int dado_izquierdo = 1;
  int dado_derecho = 1;
  //  Contar: Es que determina el turno del jugador.
  int contar = 1;
  int puntaje_alto = 0;
  int MaxRondas = 0;
  int ronda_actual = 1;
  int ganadorJugadores = 0;
  String ganadorSesion;
  String ganadorRonda;

  //Los Mapas 'Maps' que registraran la puntuacion de cada Jugador en la ronda actual, así como las rondas ganadas de cada Jugador.

  var puntuacion = {'Jugador1': 0, 'Jugador2': 0,'Jugador3': 0,'Jugador4': 0};
  var rondasGanadas = {'Jugador1': 0, 'Jugador2': 0,'Jugador3': 0,'Jugador4': 0};

  //Función que se ejecuta al dar click en los dados.
  void cambiarDados(){
    dado_izquierdo = Random().nextInt(6) + 1;
    dado_derecho = Random().nextInt(6) + 1;

    //Cuando empiece una ronda nueva....

    if(contar > widget.jugadores)
    {
      //...se resetea las puntuaciones para la siguiente ronda
      for(int i = 1; i < contar; i++)
      {
        puntuacion['Jugador$i'] = 0;
      }

      //Así como las variables que determinan el turno y el puntaje alto de la ronda.
      contar = 1;
      puntaje_alto = 0;

      //Si no hubo un empate, continua a la ronda siguiente.
      if(ganadorJugadores == 1) {
        ronda_actual = ronda_actual + 1;
      }

      ganadorJugadores = 0;
    }

    //Una vez que se tiren los dados, se registra la puntuacion al jugador actual.
    puntuacion['Jugador$contar'] = dado_izquierdo + dado_derecho;

    //Si la puntuacion es la mas alta hasta ahora, se toma en cuenta para determinar el jugador que va ganando hasta el momento.
    if(puntuacion['Jugador$contar'] > puntaje_alto)
    {
      puntaje_alto = puntuacion['Jugador$contar'];
    }

    //Si todos los jugadores ya participaron...
    if(contar == widget.jugadores)
    {
      //Se revisa si hay uno o varios ganadores en la ronda actual
      puntuacion.forEach((String k, int i) {
        if(i == puntaje_alto)
        {
          ganadorJugadores++;
        }
      });

      //Si hay mas de un ganador, se imprime un mensaje que indique que hubo un empate.
      if(ganadorJugadores > 1)
        {
          _showDialog(false);
        }

      //Si hubo un solo ganador, imprimir un mensaje que indique el jugador que ganó la ronda actual.
      else {
        ganadorRonda = puntuacion.keys.firstWhere(
                (k) => puntuacion[k] == puntaje_alto,
            orElse: () => null);

        rondasGanadas[ganadorRonda] = rondasGanadas[ganadorRonda] + 1;


        if (rondasGanadas[ganadorRonda] > MaxRondas) {
          MaxRondas = rondasGanadas[ganadorRonda];
        }

        _showDialog(true);
      }

      //Si era la ultima ronda de la sesion..
      if(ronda_actual == widget.rondas || MaxRondas == (widget.rondas - (widget.rondas * 0.5).floor()))
        {
          //Se revisa si hubo uno o varios ganadores de la sesion (con la misma cantidad de rondas ganadas).
          ganadorJugadores = 0;
          rondasGanadas.forEach((String k, int i) {
          if(i == MaxRondas)
            {
              ganadorJugadores++;
            }
          });

          //Si hubo mas de un ganador, se imprime un mensaje que indique un empate en la sesion actual.
          if(ganadorJugadores > 1)
            {
              _GanadorMensaje(false);
            }

          //Si solo hubo un ganador, se imprime un mensaje con el Jugador que ganó la sesion actual.
          else {
            ganadorSesion = rondasGanadas.keys.firstWhere(
                    (k) => rondasGanadas[k] == MaxRondas,
                orElse: () => null);
            _GanadorMensaje(true);
          }
        }
    }

    //Cambio de turno
    contar = contar + 1;
  }

  //Mensaje para indicar el ganador de la ronda actual.
  void _showDialog(bool unicoGanador){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: new Text('Fin de la Ronda'),
          content: unicoGanador ? new Text('El $ganadorRonda gano la ronda $ronda_actual con : $puntaje_alto puntos!') : new Text('$ganadorJugadores empataron la ronda con : $puntaje_alto puntos'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //Mensaje para indicar el ganador de la sesion actual.
  void _GanadorMensaje(bool unicoGanador){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: new Text('Fin del la Sesion'),
          content: unicoGanador ? new Text('El $ganadorSesion gano la sesion con un total de $MaxRondas rondas ganadas!') :
          new Text('$ganadorJugadores empataron la sesion con : $MaxRondas rondas ganadas!'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cerrar'),
              onPressed: () {
                _resetGame();
                widget.empezar(!widget.activado);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //Función que reinicia los valores de las variables, una vez que se acabe la sesión actual.
  void _resetGame()
  {
    dado_izquierdo = 1;
    dado_derecho = 1;
    contar = 1;
    puntaje_alto = 0;
    MaxRondas = 0;
    ronda_actual = 1;
    ganadorJugadores = 0;

    for(int i = 1; i <= 4; i++)
    {
      puntuacion['Jugador$i'] = 0;
    }

    for(int j = 1; j <= 4; j++)
    {
      rondasGanadas['Jugador$j'] = 0;
    }
  }


  //Widget (UI) Del Juego

  @override
  Widget build(BuildContext context) {
    //Una vez que se da click en empezar el juego, se genera la interfaz del juego.
    Column juego = widget.activado ? Column(
      children: <Widget>[
        //Ronda Actual
        Text(
          'Ronda $ronda_actual',
          style: TextStyle(
            fontSize: 32.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        //Dados
        Row(
          children: <Widget>[
            //Dado Izquierdo
            Expanded(
              child: FlatButton(
                  onPressed: (){
                    setState(() {
                      cambiarDados();
                    });
                  },
                  child: Image.asset('images/dice$dado_izquierdo.png')
              ),
            ),
            //Dado Derecho
            Expanded(
              child: FlatButton(
                  onPressed: (){
                    setState(() {
                      cambiarDados();
                    });
                  },
                  child: Image.asset('images/dice$dado_derecho.png')
              ),
            ),
          ],
        ),
        SizedBox(
          height: 50.0,
        ),
        //Jugadores
        Row(
          children: <Widget>[
            //Jugador1
            Expanded(
              child: Container(
                height: 70.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      puntuacion['Jugador1'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 25.0,
                      ),
                    ),
                    Text(
                      'Score: ' + rondasGanadas['Jugador1'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Jugador2
            Expanded(
              child: Container(
                height: 70.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      puntuacion['Jugador2'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 25.0,
                      ),
                    ),
                    Text(
                      'Score: ' + rondasGanadas['Jugador2'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Jugador3
            Expanded(
              child: Container(
                height: 70.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      puntuacion['Jugador3'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 25.0,
                      ),
                    ),
                    Text(
                      'Score: ' + rondasGanadas['Jugador3'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Jugador4
            Expanded(
              child: Container(
                height: 70.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      puntuacion['Jugador4'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 25.0,
                      ),
                    ),
                    Text(
                      'Score: ' + rondasGanadas['Jugador4'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    )
        :
        //Si no se ha iniciado el juego, regresar una columna vacia.
    Column();
    return juego;
  }
}

//StateFul Widget, representando al menu inicial del Juego.

class DicePage extends StatefulWidget {
  @override
  _DicePageState createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  //Declaracion de variables, los cuales pasaran como parametros para el juego en si.
  int rondas = 1;
  int jugadores = 2;
  bool _active = false;
  bool deshabilitar = false;

  //Funcion para Activar el Juego
  void _activarJuego(bool newValue){
    setState(() {
      _active = newValue;
      deshabilitar = !deshabilitar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: deshabilitar ? 0.0 : 1.0,
            child: Text(
              'Numero de Rondas',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Opacity(
            opacity: deshabilitar ? 0.0 : 1.0,
            //Numero de Rondas por escoger
            child: Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButton<int>(
                  value: rondas,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                  elevation: 4,
                  style: TextStyle(
                    backgroundColor: Colors.white,
                    color: Colors.black,
                  ),
                  onChanged: (int nuevoValor) {
                    setState(() {
                      rondas = nuevoValor;
                    });
                  },
                  items: deshabilitar ? null : <int>[1, 3, 5, 7].map<DropdownMenuItem<int>>((int valor) {
                    return DropdownMenuItem<int>(
                      value: valor,
                      child: Text(valor.toString()),
                    );
                  })
                      .toList()
              ),
            ),
          ),
          Opacity(
            opacity: deshabilitar ? 0.0 : 1.0,
            child: Text(
              'Numero de Jugadores',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Opacity(
            opacity: deshabilitar ? 0.0 : 1.0,
            //Numero de Jugadores por escoger
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
              padding: EdgeInsets.all(8.0),
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButton<int>(
                  value: jugadores,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                  elevation: 4,
                  style: TextStyle(
                    backgroundColor: Colors.white,
                    color: Colors.black,
                  ),
                  onChanged: (int nuevoValor) {
                    setState(() {
                      jugadores = nuevoValor;
                    });
                  },
                  items: deshabilitar ? null : <int>[2, 3, 4].map<DropdownMenuItem<int>>((int valor) {
                    return DropdownMenuItem<int>(
                      value: valor,
                      child: Text(valor.toString()),
                    );
                  })
                      .toList()
              ),
            ),
          ),
          Opacity(
            opacity: deshabilitar ? 0.0 : 1.0,
            //Boton para Empezar el Juego
            child: RaisedButton(
              onPressed: (){
                deshabilitar ? null :
                _activarJuego(true);
              },
              color: Colors.blue.shade700,
              focusColor: Colors.blue.shade900,
              child: Text(
                'Empezar',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          //Widget de Juego en sí
          Game(
            activado: _active,
            empezar: _activarJuego,
            rondas: rondas,
            jugadores: jugadores,
          ),
        ],
      ),
    );
  }
}
