import 'package:flutter/material.dart';

class Customize extends StatefulWidget {
  final String product;
  Customize({required this.product});

  @override
  _CustomizeState createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  Color selectedColor = Colors.purple[200]!;
  String material = 'Hilo elástico';
  double size = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizar ${widget.product}'),
        backgroundColor: Colors.purple[200],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Vista previa simple
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: selectedColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Vista previa de ${widget.product}',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Selección de color
          Text('Color base'),
          Wrap(
            spacing: 8,
            children: [
              Colors.purple[200]!,
              Colors.blue[200]!,
              Colors.pink[200]!,
              Colors.orange[200]!
            ].map((color) {
              return GestureDetector(
                onTap: () => setState(() => selectedColor = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                        width: selectedColor == color ? 3 : 1,
                        color: Colors.purple),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          // Selección de material
          Text('Material'),
          DropdownButton<String>(
            value: material,
            items: ['Hilo elástico', 'Cuerda', 'Cuentas brillantes']
                .map((m) => DropdownMenuItem(child: Text(m), value: m))
                .toList(),
            onChanged: (value) => setState(() => material = value!),
          ),
          SizedBox(height: 20),

          // Selección de tamaño
          Text('Tamaño (cm): ${size.toInt()}'),
          Slider(
            value: size,
            min: 15,
            max: 25,
            divisions: 10,
            label: size.toInt().toString(),
            activeColor: Colors.purple[200],
            inactiveColor: Colors.purple[100],
            onChanged: (value) => setState(() => size = value),
          ),
          SizedBox(height: 20),

          // Botón para ir a Preview
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
                minimumSize: Size(double.infinity, 50)),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/preview',
                arguments: {
                  'product': widget.product,
                  'color': selectedColor,
                  'material': material,
                  'size': size,
                },
              );
            },
            child: Text('Ver vista previa ✨'),
          ),
        ],
      ),
    );
  }
}
