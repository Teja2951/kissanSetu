import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CropDoctorScreen extends StatefulWidget {
  @override
  _CropDoctorScreenState createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends State<CropDoctorScreen> {
  File? _image;
  bool _isLoading = false;
  Map<String, String> _diagnosisData = {};
  final ImagePicker _picker = ImagePicker();
  final String _apiKey = "AIzaSyCTqxkN8zKTNlXXc6PLTbO1CPc1DfLKfeA"; // Replace with your actual API key

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _diagnosisData.clear(); // Clear previous results
      });
    }
  }

  Future<void> _analyzeImage() async {
  if (_image == null) return;

  setState(() {
    _isLoading = true;
    _diagnosisData.clear(); // Clear previous results
  });

  try {
    String base64Image = base64Encode(_image!.readAsBytesSync());
    var url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey");

    var headers = {"Content-Type": "application/json"};
    var body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"inlineData": {"mimeType": "image/jpeg", "data": base64Image}},
            {
              "text":
                  "Analyze this crop image and respond in the following structured format:"
                  "\n**Diagnosis:** <brief diagnosis>"
                  "\n**Symptoms:** <list of symptoms>"
                  "\n**Possible Causes:** <possible causes>"
                  "\n**Treatment & Solution:** <recommended treatments>"
                  "\n**Prevention Tips:** <how to prevent this in the future>"
            }
          ]
        }
      ]
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      String rawText = jsonResponse["candidates"]?[0]["content"]["parts"][0]["text"] ??
          "Unable to diagnose the crop.";

      if (rawText.contains("**Diagnosis:**") || rawText.contains("**Symptoms:**")) {
        _parseDiagnosisResponse(rawText);
      } else {
        setState(() {
          _diagnosisData["Error"] = "The uploaded image does not appear to be a plant. Please try again with a valid crop image.";
        });
      }
    } else {
      setState(() {
        _diagnosisData["Error"] = "Error: ${response.body}";
      });
    }
  } catch (e) {
    setState(() {
      _diagnosisData["Error"] = "Error diagnosing the crop.";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _parseDiagnosisResponse(String responseText) {
    Map<String, String> data = {};
    List<String> sections = responseText.split("\n**");

    for (String section in sections) {
      if (section.contains(":")) {
        List<String> parts = section.split(":");
        String key = parts[0].trim().replaceAll("**", "");
        String value = parts.sublist(1).join(":").trim();
        data[key] = value;
      }
    }

    setState(() {
      _diagnosisData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Doctor"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "*Upload a clear image of the affected crop for diagnosis.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red[800]),
              ),
              SizedBox(height: 15),
        
              // Image Display
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: _image == null
                    ? Center(child: Icon(Icons.image, size: 100, color: Colors.grey))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
              SizedBox(height: 20),
        
              // Upload Image Buttons (Gallery & Camera)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.photo_library, color: Colors.green),
                      label: Text("Gallery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.camera_alt, color: Colors.green),
                      label: Text("Camera", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
        
              // Analyze Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: Icon(Icons.search, color: Colors.white),
                label: Text("Analyze", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _analyzeImage,
              ),
              SizedBox(height: 20),
        
              if (_isLoading) CircularProgressIndicator(),
        
              // Diagnosis Result
              if (!_isLoading && _diagnosisData.isNotEmpty) _buildDiagnosisCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Single Card for All Diagnosis Data
  Widget _buildDiagnosisCard() {
    return Card(
      margin: EdgeInsets.only(top: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _diagnosisData.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  ),
                  SizedBox(height: 5),
                  Text(entry.value, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
