import 'package:flutter/material.dart';
import 'Preview.dart';

class Customize extends StatefulWidget {
  final String product;
  const Customize({super.key, required this.product});

  @override
  State<Customize> createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  Color selectedColor = Colors.purple[200]!;
  String material = 'Lana bambino';
  int size = 15;
  String character = '';

  @override
  Widget build(BuildContext context) {
    bool isAmigurumi = widget.product.toLowerCase() == 'amigurumi';
    bool isPapercraft = widget.product.toLowerCase() == 'papercraft';
    bool isPulsera = widget.product.toLowerCase() == 'pulsera';

    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizar ${widget.product}'),
        backgroundColor: Colors.purple[200],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: selectedColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Vista previa de ${widget.product}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🎨 SECCIÓN DE COLOR
          const Text(
            'Color base',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
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
                      color: Colors.purple,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 🧶 OPCIONES PARA AMIGURUMIS
          if (isAmigurumi) ...[
            const Text(
              'Material',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: material,
              items: ['Lana bambino', 'Lana jazmín']
                  .map((m) => DropdownMenuItem<String>(
                        value: m,
                        child: Text(m),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => material = value!),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tamaño (cm)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Disponemos personalizados de 14, 21 y 30 cm 💕',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [15, 21, 30].map((s) {
                return ChoiceChip(
                  label: Text('$s cm'),
                  selected: size == s,
                  onSelected: (_) => setState(() => size = s),
                  selectedColor: Colors.purple[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // 💫 PERSONAJE (para ambos tipos)
          Text(
            'Personaje ${isPapercraft ? "(obligatorio)" : "(opcional)"}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: (value) => character = value,
            decoration: InputDecoration(
              hintText: 'Nombre o descripción del personaje',
              filled: true,
              fillColor: Colors.purple[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 🌟 BOTÓN DE VISTA PREVIA
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[200],
            ),
            onPressed: () {
              if (isPapercraft && character.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Por favor ingresa un personaje'),
                    backgroundColor: Colors.purple[200],
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Preview(
                    product: widget.product,
                    color: selectedColor,
                    character: character,
                    size: size,
                  ),
                ),
              );
            },
            child: const Text('Ver vista previa ✨'),
          ),
        ],
      ),
    );
  }
}
