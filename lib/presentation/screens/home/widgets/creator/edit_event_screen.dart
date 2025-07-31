import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String eventId;
  final String userId;

  const EditEventScreen({
    super.key,
    required this.eventData,
    required this.eventId,
    required this.userId,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _categories = ['Music', 'Sports', 'Food', 'Art', 'Business'];
  final List<String> _types = ['Physical', 'Virtual', 'In-person']; // Updated types

  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _ticketPriceController;
  late final TextEditingController _totalTicketsController;

  // Form values
  late String _selectedCategory;
  late String _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isFree;

  @override
  void initState() {
    super.initState();
    
    // Initialize form with existing data
    _titleController = TextEditingController(text: widget.eventData['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.eventData['description'] ?? '');
    _locationController = TextEditingController(text: widget.eventData['location'] ?? '');
    
    final eventDateTime = (widget.eventData['datetime'] as Timestamp).toDate();
    _selectedDate = eventDateTime;
    _selectedTime = TimeOfDay.fromDateTime(eventDateTime);
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(eventDateTime));
    _timeController = TextEditingController(text: DateFormat('HH:mm').format(eventDateTime));
    
    _ticketPriceController = TextEditingController(
      text: (widget.eventData['price'] ?? 0).toString()
    );
    _totalTicketsController = TextEditingController(
      text: (widget.eventData['totalTickets'] ?? '').toString()
    );
    
    _selectedCategory = widget.eventData['category'] ?? 'Music';
    
    // Handle type with proper validation
    final rawType = widget.eventData['type'] ?? 'Physical';
    _selectedType = _types.firstWhere(
      (type) => type.toLowerCase() == rawType.toString().toLowerCase(),
      orElse: () => 'Physical'
    );
    
    _isFree = (widget.eventData['price'] ?? 0) == 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _ticketPriceController.dispose();
    _totalTicketsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'datetime': dateTime,
      'category': _selectedCategory,
      'type': _selectedType, // Now uses standardized value
      'price': _isFree ? 0 : double.parse(_ticketPriceController.text),
      'totalTickets': _totalTicketsController.text.isEmpty 
          ? null 
          : int.parse(_totalTicketsController.text),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('events').doc(widget.eventId).update(updatedData);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location/Venue',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isFree,
                    onChanged: (bool? value) {
                      setState(() {
                        _isFree = value!;
                      });
                    },
                  ),
                  const Text('Free Event'),
                ],
              ),
              if (!_isFree) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ticketPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Ticket Price',
                    border: OutlineInputBorder(),
                    prefixText: 'Kes ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!_isFree && (value == null || value.isEmpty)) {
                      return 'Please enter a price';
                    }
                    if (!_isFree && double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalTicketsController,
                decoration: const InputDecoration(
                  labelText: 'Total Tickets (Leave empty for unlimited)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('UPDATE EVENT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}