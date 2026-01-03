import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../../core/constants/app_constants.dart';

class ChatbotRepository {
  final LocalStorageService _storageService;
  final GenerativeModel _model;

  ChatbotRepository(this._storageService)
      : _model = GenerativeModel(
          model: AppConstants.geminiModelName,
          apiKey: AppConstants.geminiApiKey,
        );

  GenerativeModel _createModelWithPrompt(String systemPrompt) {
    return GenerativeModel(
      model: AppConstants.geminiModelName,
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.text(systemPrompt),
    );
  }

  List<ChatMessage> getChatHistory() {
    final jsonList = _storageService.getJsonList(AppConstants.chatHistoryKey);
    if (jsonList != null) {
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> saveChatHistory(List<ChatMessage> messages) async {
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    return await _storageService.saveJsonList(
      AppConstants.chatHistoryKey,
      jsonList,
    );
  }

  Future<bool> addMessage(ChatMessage message) async {
    final history = getChatHistory();
    history.add(message);
    return await saveChatHistory(history);
  }

  Future<String> sendMessage(
    String message, {
    UserProfile? userProfile,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(userProfile);

      final history = getChatHistory();
      final recentHistory = history.length > 10 
          ? history.sublist(history.length - 10) 
          : history;


      final modelWithPrompt = _createModelWithPrompt(systemPrompt);

      final chat = modelWithPrompt.startChat();

      final response = await chat.sendMessage(Content.text(message));

      return response.text ?? 'Yanıt alınamadı.';
    } catch (e) {
      throw Exception('Gemini API hatası: $e');
    }
  }

  Future<String> sendImageMessage(
    File imageFile, {
    UserProfile? userProfile,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final systemPrompt = _buildFoodAnalysisPrompt(userProfile);

      final visionModel = GenerativeModel(
        model: AppConstants.geminiModelName,
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.text(systemPrompt),
      );

      final prompt = TextPart(
        'Bu fotoğraftaki yemeği detaylı analiz et. '
        'Lütfen şunları belirt:\n'
        '1. Yemeğin adı ve tahmini porsiyon boyutu\n'
        '2. Kalori miktarı (kcal)\n'
        '3. Protein miktarı (gram)\n'
        '4. Karbonhidrat miktarı (gram)\n'
        '5. Yağ miktarı (gram)\n'
        '6. Sağlık değerlendirmesi ve öneriler\n'
        'Sayısal değerleri net belirt.',
      );
      
      final imagePart = DataPart('image/jpeg', imageBytes);
      
      final response = await visionModel.generateContent([
        Content.multi([prompt, imagePart]),
      ]);
      
      return response.text ?? 'Fotoğraf analiz edilemedi.';
    } catch (e) {
      throw Exception('Gemini Vision API hatası: $e');
    }
  }

  String _buildSystemPrompt(UserProfile? userProfile) {
    final buffer = StringBuffer();
    
    buffer.writeln('Sen FitLife uygulamasının AI Sağlık Koçusun. ');
    buffer.writeln('Görevin kullanıcılara sağlık, beslenme ve fitness konularında yardımcı olmaktır.\n');
    
    buffer.writeln('Yanıtlarında şu konulara odaklan:');
    buffer.writeln('- Besin değerleri ve kalori hesaplamaları');
    buffer.writeln('- Antrenmanlara göre yakılan kalori miktarları');
    buffer.writeln('- Kişi özelliklerine göre (boy, kilo, yaş, cinsiyet) günlük kalori ihtiyacı');
    buffer.writeln('- Makro besin değerleri (protein, karbonhidrat, yağ)');
    buffer.writeln('- Sağlıklı beslenme önerileri');
    buffer.writeln('- Egzersiz programları ve antrenman tavsiyeleri\n');
    
    if (userProfile != null) {
      buffer.writeln('Kullanıcı Bilgileri:');
      buffer.writeln('- İsim: ${userProfile.name}');
      if (userProfile.age != null) {
        buffer.writeln('- Yaş: ${userProfile.age}');
      }
      if (userProfile.height != null) {
        buffer.writeln('- Boy: ${userProfile.height} cm');
      }
      if (userProfile.weight != null) {
        buffer.writeln('- Kilo: ${userProfile.weight} kg');
      }
      if (userProfile.gender != null) {
        buffer.writeln('- Cinsiyet: ${userProfile.gender}');
      }
      buffer.writeln('- Günlük Kalori Hedefi: ${userProfile.dailyCalorieGoal} kcal\n');

      if (userProfile.height != null && userProfile.weight != null) {
        final heightInMeters = userProfile.height! / 100;
        final bmi = userProfile.weight! / (heightInMeters * heightInMeters);
        buffer.writeln('- BMI: ${bmi.toStringAsFixed(1)}\n');
      }
    }
    
    buffer.writeln('Yanıtlarını Türkçe ver, kısa ve öz tut, pratik bilgiler sun. ');
    buffer.writeln('Sayısal değerler verirken net ol (kalori, gram, dakika vb.).');
    
    return buffer.toString();
  }

  String _buildFoodAnalysisPrompt(UserProfile? userProfile) {
    final buffer = StringBuffer();
    
    buffer.writeln('Sen bir beslenme uzmanısın. Fotoğraftaki yemeği analiz edeceksin.\n');
    
    buffer.writeln('Analizinde şunları mutlaka belirt:');
    buffer.writeln('1. Yemeğin adı ve tahmini porsiyon boyutu');
    buffer.writeln('2. Kalori miktarı (kcal)');
    buffer.writeln('3. Protein miktarı (gram)');
    buffer.writeln('4. Karbonhidrat miktarı (gram)');
    buffer.writeln('5. Yağ miktarı (gram)');
    buffer.writeln('6. Sağlık değerlendirmesi ve öneriler\n');
    
    if (userProfile != null) {
      buffer.writeln('Kullanıcı Bilgileri:');
      if (userProfile.height != null && userProfile.weight != null) {
        buffer.writeln('- Boy: ${userProfile.height} cm, Kilo: ${userProfile.weight} kg');
      }
      buffer.writeln('- Günlük Kalori Hedefi: ${userProfile.dailyCalorieGoal} kcal\n');
      
      buffer.writeln('Bu yemeğin kullanıcının günlük hedefine göre uygun olup olmadığını değerlendir.');
    }
    
    buffer.writeln('Yanıtını Türkçe ver, sayısal değerleri net belirt.');
    
    return buffer.toString();
  }

  Future<bool> clearHistory() async {
    return await _storageService.remove(AppConstants.chatHistoryKey);
  }
}
