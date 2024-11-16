import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  final TextEditingController? controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<String>? onChanged;
  const DatePickerField({
    Key? key,
    this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = widget.controller ?? TextEditingController();
    // _dateController.text = DateTime.now().toString().split(" ")[0];
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _dateController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate: widget.lastDate ?? DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toString().split(" ")[0];
      });
      widget.onChanged?.call(_dateController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Colors.blue,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      readOnly: true,
      onTap: _selectDate,
    );
  }
}
